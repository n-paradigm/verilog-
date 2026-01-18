module frequency_divider(
    input        sys_clk,    // 基准时钟
    input        rst_n,        // 新增：异步复位（低有效）
    output reg   clk_1khz,      // 1kHz输出
    output reg   clk_100hz,    // 100Hz输出
    output reg   clk_1hz      // 1Hz输出
);

// 计数器定义（位宽根据分频系数调整）
reg [24:0] cnt_1hz;   // 1Hz计数器
reg [20:0] cnt_100hz; // 100Hz计数器
reg [17:0] cnt_1khz;  // 1kHz计数器


// 1kHz分频逻辑（带复位）
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin         // 复位时：计数器清零，输出时钟置0
        cnt_1khz <= 17'd0;
        clk_1khz <= 1'b0;
    end else if (cnt_1khz >= 17'd24999) begin  // 原分频逻辑
        cnt_1khz <= 17'd0;
        clk_1khz <= ~clk_1khz;
    end else begin
        cnt_1khz <= cnt_1khz + 1'b1;
    end
end


// 100Hz分频逻辑（带复位）
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_100hz <= 20'd0;
        clk_100hz <= 1'b0;
    end else if (cnt_100hz >= 20'd249999) begin
        cnt_100hz <= 20'd0;
        clk_100hz <= ~clk_100hz;
    end else begin
        cnt_100hz <= cnt_100hz + 1'b1;
    end
end

// 1Hz分频逻辑（带复位）
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_1hz <= 24'd0;
        clk_1hz <= 1'b0;
    end else if (cnt_1hz >= 24'd24999999) begin
        cnt_1hz <= 24'd0;
        clk_1hz <= ~clk_1hz;
    end else begin
        cnt_1hz <= cnt_1hz + 1'b1;
    end
end

endmodule