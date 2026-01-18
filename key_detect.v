module key_detect(
    input clk,
    input rst_n,
    input key_in,   // 按键输入
    output reg key_pressed // 按键检测输出
);
    reg key_reg, key_reg_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_reg <= 0;
            key_reg_d <= 0;
            key_pressed <= 0;
        end else begin
            key_reg <= key_in;
            key_reg_d <= key_reg;
            if (key_reg && !key_reg_d) // 检测按键的上升沿
                key_pressed <= 1;
            else
                key_pressed <= 0;
        end
    end
endmodule