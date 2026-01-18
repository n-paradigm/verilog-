module admin_detector(
    input clk,                  // 系统时钟
    input rst_n,                // 低电平有效复位
    input [3:0] key_value,      // 按键值（0~9/A/B/C/D）
    input key_valid,            // 按键有效标志
    input setting_en,           // 密码设置使能（来自主状态机）
    input [15:0] input_pwd,     // 输入的4位密码（来自密码处理模块，仅作参考，内部用buf缓存）
    output reg [15:0] new_pwd,  // 新设置的密码（输出到密码处理模块）
    output reg pwd_save,        // 密码保存触发信号
    output reg setting_done,     // 密码设置完成信号
	 output reg counter           //输入次数计数器
);

// 状态参数定义（仅保留核心状态，删除冗余）
localparam IDLE      = 3'b000; // 空闲状态（等待setting_en触发）
localparam INPUT_NEW = 3'b010; // 密码输入状态（记录前4位数字）
localparam TEMP      = 3'b011; // 

// 按键值定义（与需求匹配）
localparam KEYA = 4'b1010; // 确认键（A）
localparam KEYB = 4'b1011; // 退格键（B）
localparam KEYC = 4'b1101; // 取消键（C）

// 内部寄存器声明
reg [2:0] setting_state;       // 子状态机状态寄存器
reg [2:0] pwd_cnt;             // 密码输入计数（0~3，仅记录前4位）
reg [15:0] input_pwd_buf;      // 内部缓存输入的密码（替代input_pwd赋值，解决端口方向错误）
reg [15:0] new_pwd_temp;

// 状态机核心逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        setting_state  <= IDLE;
        new_pwd        <= 16'hFFFF;     // 建议初始值明显一点，方便调试
        pwd_save       <= 1'b0;
        setting_done   <= 1'b0;
        pwd_cnt        <= 3'd0;
        input_pwd_buf  <= 16'h0000;
    end 
    else begin
        // 默认把脉冲信号打0
        pwd_save       <= 1'b0;
        setting_done   <= 1'b0;

        case (setting_state)
            IDLE: begin
                pwd_cnt       <= 3'd0;
                input_pwd_buf <= 16'h0000;
                if (setting_en) begin
                    setting_state <= INPUT_NEW;
                end
            end

            INPUT_NEW: begin
                // 数字键 - 建议正序输入（先按的高位）
                if (key_valid && key_value <= 4'd9) begin
                    if (pwd_cnt < 4) begin
                        // 正序：每次左移4位，把新数字放低4位
                        input_pwd_buf <= {input_pwd_buf[11:0], key_value};
                        //input_pwd_buf <= {key_value, input_pwd_buf[15:4]};  
                        pwd_cnt <= pwd_cnt + 1'b1;
                    end
                end

                // 退格
                else if (key_valid && key_value == KEYB) begin
                    if (pwd_cnt > 0) begin
                        pwd_cnt <= pwd_cnt - 1'b1;
                        input_pwd_buf <= {4'h0, input_pwd_buf[15:4]};  // 右移丢掉最低4位
                    end
                end

                // 确认（A键）
                else if (key_valid && key_value == KEYA) begin
                    if (pwd_cnt == 4) begin      // 强烈建议：只有输满4位才允许确认
                        new_pwd      <= input_pwd_buf;
                        pwd_save     <= 1'b1;
                        setting_done <= 1'b1;
                        setting_state<= IDLE;     // 直接回IDLE，不要TEMP中间状态
                        // 注意：这里不清 input_pwd_buf，让用户能看到最后输入的密码
                    end
                    // 如果不满4位，可以不做事，或蜂鸣器提醒
                end

                // 取消（C键） - 这次真的要跳！
                else if (key_valid && key_value == KEYC) begin
                    setting_state <= IDLE;
                    // pwd_cnt 和 input_pwd_buf 在 IDLE 里会被自动清
                end

                // 其他情况保持
                else begin
                    setting_state <= INPUT_NEW;
                end
            end

            // 可以删掉 TEMP 状态了

            default: setting_state <= IDLE;
        endcase
    end
end
endmodule