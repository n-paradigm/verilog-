module key_matrix_4x4(
    input wire clk,       // 低频扫描时钟（模板用的100Hz）
    input wire rst_n,           // 低电平复位
    input wire [3:0] key_col,   // 列信号输入（无按键：4'b1111，有按键：某一位低）
    output reg [3:0] key_row,   // 行信号输出
    output reg [3:0] key_value, // 按键值输出（0~F）
    output reg key_valid        // 按键有效脉冲（单个时钟周期高电平）
);

// -------------------------- 1. 极简防抖逻辑（保留，匹配硬件电平） --------------------------
reg [3:0] key_col_r1, key_col_r2; // 列信号两级打拍（防抖+消亚稳态）
wire [3:0] key_col_debounce;     // 防抖后的稳定列信号

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_col_r1 <= 4'b1111; // 初始值：无按键的全高电平
        key_col_r2 <= 4'b1111;
    end else begin
        key_col_r1 <= key_col;       // 第一级打拍
        key_col_r2 <= key_col_r1;    // 第二级打拍（稳定后的信号）
    end
end
assign key_col_debounce = key_col_r2;

// -------------------------- 2. 状态定义（保留） --------------------------
localparam S_IDLE        = 2'b00;  // 空闲状态：循环扫描行
localparam S_CONFIRM     = 2'b10;  // 确认状态：检测到按键，锁存按键值
localparam S_WAIT_RELEASE= 2'b11;  // 等待释放状态：等待按键松开

// -------------------------- 3. 内部寄存器（新增：行扫描延迟计数器，解决时序问题） --------------------------
reg [1:0] current_state = S_IDLE;
reg [1:0] scan_row = 2'd0;
reg [1:0] pressed_row = 2'd0;
reg [3:0] key_value_latch = 4'd0;
reg [1:0] scan_delay_cnt; // 新增：扫描延迟计数器，等待列信号稳定（0~3，4个时钟周期）

// -------------------------- 4. 状态机主逻辑（核心修复：时序+初始化+扫描延迟） --------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // 修复1：补全所有寄存器的初始化，包括key_row和scan_delay_cnt
        current_state <= S_IDLE;
        scan_row <= 2'd0;
        pressed_row <= 2'd0;
        key_row <= 4'b1111; // 初始化：所有行拉高（低电平有效，初始无行被拉低）
        key_value <= 4'h0;
        key_value_latch <= 4'h0;
        key_valid <= 1'b0;
        scan_delay_cnt <= 2'd0; // 初始化延迟计数器
    end else begin
        key_valid <= 1'b0; // 默认值：脉冲复位
        case (current_state)
            // 状态1：空闲（S_IDLE）：先延迟等待列信号稳定，再检测按键，最后更新扫描行
            S_IDLE: begin
                // 步骤1：设置当前扫描行的输出（先拉低行，等待列信号稳定）
                key_row <= ~(1 << scan_row);
                // 步骤2：延迟计数器计数（等待4个时钟周期，列信号完全稳定）
                if (scan_delay_cnt < 2'd3) begin
                    scan_delay_cnt <= scan_delay_cnt + 1'b1;
                end else begin
                    // 步骤3：列信号稳定后，检测是否有按键
                    if (key_col_debounce != 4'b1111) begin
                        pressed_row <= scan_row;  // 锁存按下的行号
                        current_state <= S_CONFIRM; // 进入确认状态
                        scan_delay_cnt <= 2'd0; // 重置延迟计数器
                    end else begin
                        // 无按键：更新扫描行（0→1→2→3→0）
                        scan_row <= (scan_row == 2'd3) ? 2'd0 : scan_row + 1'b1;
                        scan_delay_cnt <= 2'd0; // 重置延迟计数器
                    end
                end
            end

            // 状态2：确认（S_CONFIRM）：再次确认按键值，生成有效脉冲
            S_CONFIRM: begin
                key_row <= ~(1 << pressed_row); // 保持拉低按下的行
                // 再次确认按键值（防止偶然触发）
                case (pressed_row)
                    2'd0: case (key_col_debounce)
                        4'b1110: key_value <= 4'd0;
                        4'b1101: key_value <= 4'd1;
                        4'b1011: key_value <= 4'd2;
                        4'b0111: key_value <= 4'd3;
                        default: key_value <= key_value_latch;
                    endcase
                    2'd1: case (key_col_debounce)
                        4'b1110: key_value <= 4'd4;
                        4'b1101: key_value <= 4'd5;
                        4'b1011: key_value <= 4'd6;
                        4'b0111: key_value <= 4'd7;
                        default: key_value <= key_value_latch;
                    endcase
                    2'd2: case (key_col_debounce)
                        4'b1110: key_value <= 4'd8;
                        4'b1101: key_value <= 4'd9;
                        4'b1011: key_value <= 4'd10;
                        4'b0111: key_value <= 4'd11;
                        default: key_value <= key_value_latch;
                    endcase
                    2'd3: case (key_col_debounce)
                        4'b1110: key_value <= 4'd12;
                        4'b1101: key_value <= 4'd13;
                        4'b1011: key_value <= 4'd14;
                        4'b0111: key_value <= 4'd15;
                        default: key_value <= key_value_latch;
                    endcase
                    default: key_value <= key_value_latch;
                endcase
                key_valid <= 1'b1; // 生成单个时钟周期的有效脉冲
                key_value_latch <= key_value;
                current_state <= S_WAIT_RELEASE; // 进入等待释放状态
            end

            // 状态3：等待释放（S_WAIT_RELEASE）：等待按键完全松开，增加防抖确认
            S_WAIT_RELEASE: begin
                key_row <= ~(1 << pressed_row); // 保持拉低按下的行
                // 确认列信号回到全高（无按键），才回到空闲状态
                if (key_col_debounce == 4'b1111) begin
                    current_state <= S_IDLE;
                    scan_row <= (pressed_row == 2'd3) ? 2'd0 : pressed_row + 1'b1; // 从下一行开始扫描，避免重复
                end
            end

            // 默认状态：异常处理，回到空闲
            default: begin
                current_state <= S_IDLE;
                key_row <= 4'b1111;
                scan_row <= 2'd0;
                scan_delay_cnt <= 2'd0;
                key_valid <= 1'b0;
            end
        endcase
    end
end

endmodule