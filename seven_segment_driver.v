module seven_segment_driver (
    input [3:0] num,         // 输入的数字 0-9
    output reg [6:0] seg,    // 七段数码管的显示（A-G）
    input [3:0] digit_sel    // 选择当前显示的数码管
);

    // 根据输入的数字选择对应的七段数码管编码
    always @(*) begin
        case (num)
            4'd0: seg = 7'b1111110; // 0
            4'd1: seg = 7'b0110000; // 1
            4'd2: seg = 7'b1101101; // 2
            4'd3: seg = 7'b1111001; // 3
            4'd4: seg = 7'b0110011; // 4
            4'd5: seg = 7'b1011011; // 5
            4'd6: seg = 7'b1011111; // 6
            4'd7: seg = 7'b1110000; // 7
            4'd8: seg = 7'b1111111; // 8
            4'd9: seg = 7'b1111011; // 9
            default: seg = 7'b0000000; // 默认显示为空
        endcase
    end

    // 位选控制逻辑
    always @(*) begin
        case (digit_sel)
            4'b0001: seg = seg;   // 控制显示第1位
            4'b0010: seg = seg;   // 控制显示第2位
            4'b0100: seg = seg;   // 控制显示第3位
            4'b1000: seg = seg;   // 控制显示第4位
            default: seg = 7'b0000000;
        endcase
    end
endmodule