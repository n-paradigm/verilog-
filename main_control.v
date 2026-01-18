module main_control(
    input clk,                // 50MHz 主时钟
    input rst_n,
    input [3:0] key_value,
    input key_valid,          // 来自100Hz时钟域的按键有效信号
    input pwd_match,
    input key_lock,
    input setting_done,
    output reg[2:0] flag,
    output reg led1,
    output reg led2,
    output reg led3,
    output reg buzzer,
    output reg safe_open,
    output reg setting_en,
    output reg error_flag,
    output reg show_erro
);

// 状态定义
reg [3:0] state;
parameter IDLE = 4'b0000;
parameter INPUT = 4'b0001;
parameter CORRECT = 4'b0010;
parameter ERROR = 4'b0011;
parameter SETTING = 4'b0100;
parameter SET_SUCCESS = 4'b0101;
parameter SET_ERROR = 4'b0110;
parameter SET_freeze = 4'b0111;
parameter KEYA = 4'b1010;
parameter KEYB = 4'b1011;
parameter KEYC = 4'b1101;
parameter KEYD = 4'b1110;

// ========== 跨时钟域同步 key_valid ==========
reg key_valid_d1, key_valid_d2, key_valid_d3;
wire key_valid_sync;  // 同步后的按键有效脉冲

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key_valid_d1 <= 1'b0;
        key_valid_d2 <= 1'b0;
        key_valid_d3 <= 1'b0;
    end else begin
        key_valid_d1 <= key_valid;
        key_valid_d2 <= key_valid_d1;
        key_valid_d3 <= key_valid_d2;
    end
end

// 检测上升沿，生成单周期脉冲
assign key_valid_sync = key_valid_d2 & ~key_valid_d3;

// ========== 按键音相关 ==========
reg [19:0] beep_cnt;
wire beep_active;
parameter BEEP_DURATION = 20'd500; // 50MHz下约10ms

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        beep_cnt <= 20'd0;
    end else if (key_valid_sync && state != SET_freeze) begin
        beep_cnt <= BEEP_DURATION;
    end else if (beep_cnt > 0) begin
        beep_cnt <= beep_cnt - 1'b1;
    end
end

assign beep_active = (beep_cnt > 0);

// 错误/冻结状态蜂鸣器标志
reg buzzer_error;

// 蜂鸣器输出逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        buzzer <= 1'b0;
    end else begin
        if (state == SET_freeze)
            buzzer <= 1'b1;
        else if (buzzer_error)
            buzzer <= 1'b1;
        else if (beep_active)
            buzzer <= 1'b1;
        else
            buzzer <= 1'b0;
    end
end

// ========== 状态机逻辑（使用同步后的 key_valid_sync）==========
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        led1 <= 1'b1;
        led2 <= 1'b1;
        led3 <= 1'b1;
        buzzer_error <= 1'b0;
        safe_open <= 1'b0;
        setting_en <= 1'b0;
        error_flag <= 1'b0;
        show_erro <= 1'b0;
        flag <= 3'b000;
    end else begin
        case(state)
            IDLE: begin
                if(key_valid_sync && (key_value >= 4'b0000 && key_value <= 4'b1001)) begin
                    state <= INPUT;
                    error_flag <= 1'b0;
                end else if(key_valid_sync && key_value == KEYD) begin
                    state <= SETTING;
                    setting_en <= 1'b1;
                    led3 <= 1'b0;
                end else begin
                    state <= IDLE;
                end
                led1 <= 1'b1;
                led2 <= 1'b1;
                buzzer_error <= 1'b0;
                safe_open <= 1'b0;
                show_erro <= 1'b0;
            end
            
            INPUT: begin
                if(key_valid_sync && key_value == KEYA && ~setting_en) begin
                    if(pwd_match) begin
                        state <= CORRECT;
                        led1 <= 1'b0;
                        led2 <= 1'b1;
                        buzzer_error <= 1'b0;
                    end else begin
                        state <= ERROR;
                        led1 <= 1'b1;
                        led2 <= 1'b0;
                        buzzer_error <= 1'b1;
                        error_flag <= 1'b1;
                        show_erro <= 1'b1;
                    end
                end else if(key_valid_sync && key_value == KEYC) begin
                    state <= IDLE;
                end else begin
                    state <= INPUT;
                end
                safe_open <= 1'b0;
                setting_en <= 1'b0;
                led3 <= 1'b1;
            end
            
            CORRECT: begin
                if(key_lock) begin
                    safe_open <= 1'b1;
                end else begin
                    safe_open <= 1'b0;
                end
                if(key_valid_sync && key_value == KEYC) begin
                    state <= IDLE;
                    led1 <= 1'b1;
                    show_erro <= 1'b0;
                end else begin
                    state <= CORRECT;
                end
                led2 <= 1'b1;
                buzzer_error <= 1'b0;
                setting_en <= 1'b0;
                led3 <= 1'b1;
            end
            
            ERROR: begin
                if(key_valid_sync && (key_value == KEYC || key_value == KEYB)) begin
                    state <= IDLE;
                    led2 <= 1'b1;
                    buzzer_error <= 1'b0;
                    show_erro <= 1'b1;
                    flag <= flag + 1;
                end else if(flag >= 3'h3) begin
                    state <= SET_freeze;
                end else begin
                    state <= ERROR;
                end
                led1 <= 1'b1;
                safe_open <= 1'b0;
                setting_en <= 1'b0;
                led3 <= 1'b1;
            end
            
            SETTING: begin
                setting_en <= 1'b1;
                buzzer_error <= 1'b0;
                if(setting_done == 1'b1)
                    state <= IDLE;
            end
            
            SET_freeze: begin
                led1 <= ~led1;
                led2 <= ~led2;
                led3 <= ~led3;
                show_erro <= 1'b1;
                state <= SET_freeze;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule