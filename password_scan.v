module password_scan(
    input [3:0] pass_buf0, pass_buf1, pass_buf2, pass_buf3, // 输入的四位密码
    input [3:0] preset_password0, preset_password1, preset_password2, preset_password3, // 预设的密码
    output reg match // 密码匹配结果
);

    always @(*) begin
        if (pass_buf0 == preset_password0 &&
            pass_buf1 == preset_password1 &&
            pass_buf2 == preset_password2 &&
            pass_buf3 == preset_password3) 
            match = 1; // 密码匹配
        else
            match = 0; // 密码不匹配
    end
endmodule