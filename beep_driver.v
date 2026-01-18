module beep_driver(
    input match,
    output reg beep // 蜂鸣器输出
);

    always @(*) begin
        if (match) 
            beep = 1; // 密码匹配，蜂鸣器响
        else
            beep = 0; // 密码不匹配，蜂鸣器不响
    end
endmodule