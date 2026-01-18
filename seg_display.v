module seg_display(
    input clk,          // 100Hz显示时钟
    input rst_n,
    input [15:0] input_pwd, // 4位输入密码（16位）
	 input  show_erro,
    output reg [6:0] seg,   // 段选（共阴）
    output reg [3:0] dig    // 位选
);

parameter [6:0] SEG_0 = 7'b1111110;
parameter [6:0] SEG_1 = 7'b0110000;
parameter [6:0] SEG_2 = 7'b1101101;
parameter [6:0] SEG_3 = 7'b1111001;
parameter [6:0] SEG_4 = 7'b0110011;
parameter [6:0] SEG_5 = 7'b1011011;
parameter [6:0] SEG_6 = 7'b1011111;
parameter [6:0] SEG_7 = 7'b1110000;
parameter [6:0] SEG_8 = 7'b1111111;
parameter [6:0] SEG_9 = 7'b1111011;
parameter [6:0] SEG_E = 7'b1001111; // 'E'
parameter [6:0] SEG_r = 7'b0000101; // 小写 'r'（通常用小写形态）
parameter [6:0] SEG_o = 7'b0011101; // 小写 'o'

// 位选计数器（0-3，对应4位数码管）
reg [1:0] dig_cnt=2'b0;
// 当前显示的数字
reg [3:0] num;

// 位选计数逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dig_cnt <= 2'd0;
    end else begin
        dig_cnt <= dig_cnt + 1'b1;
    end
end

// 段选逻辑：根据 show_erro 决定显示内容
always @(*) begin
    if (show_erro) begin
        // 显示 "E r r o"
        case (dig_cnt)
            2'd0: seg = SEG_E; // 第1位：E
            2'd1: seg = SEG_r; // 第2位：r
            2'd2: seg = SEG_r; // 第3位：r
            2'd3: seg = SEG_o; // 第4位：o
            default: seg = 7'b0000000;
        endcase
    end else begin
        // 正常显示数字
        reg [3:0] num;
        case (dig_cnt)
            2'd0: num = input_pwd[15:12];
            2'd1: num = input_pwd[11:8];
            2'd2: num = input_pwd[7:4];
            2'd3: num = input_pwd[3:0];
            default: num = 4'd0;
        endcase

        case (num)
            4'd0: seg = SEG_0;
            4'd1: seg = SEG_1;
            4'd2: seg = SEG_2;
            4'd3: seg = SEG_3;
            4'd4: seg = SEG_4;
            4'd5: seg = SEG_5;
            4'd6: seg = SEG_6;
            4'd7: seg = SEG_7;
            4'd8: seg = SEG_8;
            4'd9: seg = SEG_9;
            default: seg = 7'b0000000; // 非法数字灭
        endcase
    end
end
// 位选赋值（每次只亮一位）
always @(*) begin
    case(dig_cnt)
        2'd3: dig = 4'b1110; // 第1位（最左）
        2'd2: dig = 4'b1101; // 第2位
        2'd1: dig = 4'b1011; // 第3位
        2'd0: dig = 4'b0111; // 第4位（最右）
        default: dig = 4'b0000;
    endcase
end

endmodule