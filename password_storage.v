module password_storage(
    output reg [3:0] preset_password0, preset_password1, preset_password2, preset_password3 // 预设的四位密码
);

    initial begin
        preset_password0 = 4'b1010; // 假设密码是1010
        preset_password1 = 4'b1100;
        preset_password2 = 4'b0011;
        preset_password3 = 4'b1111;
    end
endmodule