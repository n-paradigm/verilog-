// buzzer.v
module buzzer (
    input wire clk,        // 系统时钟，比如 50MHz
    input wire rst,        // 复位信号
    input wire buzz,
    output reg buzzer_out	 // 控制信号，来自 main_ctrl
);
    
           
   // 蜂鸣器驱动（clk=1kHz，无冗余计数器）
always @(posedge clk or posedge rst) begin
    if (rst) begin
        buzzer_out <= 1'b0;
    end else begin
        buzzer_out <= (buzz == 1'b1) ? ~buzzer_out : 1'b0;
    end
end
   

endmodule