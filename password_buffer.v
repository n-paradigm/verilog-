module password_buffer(
    input clk,
    input rst_n,
    input key_pressed,
    input [3:0] key_value, // 假设键值为4位
    output reg [3:0] pass_buf0, // 第一位密码
    output reg [3:0] pass_buf1, // 第二位密码
    output reg [3:0] pass_buf2, // 第三位密码
    output reg [3:0] pass_buf3  // 第四位密码
);
    reg [1:0] cnt; // 计数器，控制输入的次数

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            pass_buf0 <= 0;
            pass_buf1 <= 0;
            pass_buf2 <= 0;
            pass_buf3 <= 0;
        end else if (key_pressed && cnt < 4) begin
            case (cnt)
                2'd0: pass_buf0 <= key_value; // 存储第1位密码
                2'd1: pass_buf1 <= key_value; // 存储第2位密码
                2'd2: pass_buf2 <= key_value; // 存储第3位密码
                2'd3: pass_buf3 <= key_value; // 存储第4位密码
            endcase
            cnt <= cnt + 1; // 增加计数器，控制密码输入次数
        end
    end
endmodule