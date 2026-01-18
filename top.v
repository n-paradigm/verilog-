module top(
    input clk,
    input rst_n,
    input swc3,   // Row 3
    input swc2,   // Row 2
    input swc1,   // Row 1
    input swc0,   // Row 0
    output reg [6:0] seg,  // Current 7-segment display
    output beep          // Beep signal
);

    // Wires for 4x4 keyboard scan
    wire key_pressed;
    wire [3:0] key_value;
    
    // Wires for password buffer and scan
    wire [3:0] pass_buf0, pass_buf1, pass_buf2, pass_buf3;
    wire match;
    wire [3:0] preset_password0, preset_password1, preset_password2, preset_password3;
    
    // Keypad scan module
    key_matrix_4x4 u_keypad_scan(
        .clk(clk),
        .rst_n(rst_n),
        .swc3(swc3), 
        .swc2(swc2),
        .swc1(swc1),
        .swc0(swc0),
        .key_value(key_value),
        .key_valid(key_pressed)
    );

    // Password buffer module
    password_buffer u_password_buffer(
        .clk(clk),
        .rst_n(rst_n),
        .key_pressed(key_pressed),
        .key_value(key_value),
        .pass_buf0(pass_buf0),
        .pass_buf1(pass_buf1),
        .pass_buf2(pass_buf2),
        .pass_buf3(pass_buf3)
    );

    // Password storage (preset password)
    password_storage u_password_storage(
        .preset_password0(preset_password0),
        .preset_password1(preset_password1),
        .preset_password2(preset_password2),
        .preset_password3(preset_password3)
    );

    // Password scan (compare input password with preset)
    password_scan u_password_scan(
        .pass_buf0(pass_buf0),
        .pass_buf1(pass_buf1),
        .pass_buf2(pass_buf2),
        .pass_buf3(pass_buf3),
        .preset_password0(preset_password0),
        .preset_password1(preset_password1),
        .preset_password2(preset_password2),
        .preset_password3(preset_password3),
        .match(match)
    );

    // Beep driver (if passwords match)
    beep_driver u_beep_driver(
        .match(match),
        .beep(beep)
    );

    // Digit select signal to control the current active digit (used for time-multiplexed display)
    reg [3:0] digit_sel;  // 4-bit for selecting which digit to display
    reg [1:0] digit_idx;  // Digit index to cycle through (0 to 3)
    reg [3:0] pass_buf[3:0]; // Store password in a register

    // Display logic for time-multiplexed 7-segment display
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_sel <= 4'b0001;  // Start with the first digit
            digit_idx <= 2'b00;
        end else begin
            // Cycle through the digits to create a multiplexing effect
            if (digit_idx < 2'd3) begin
                digit_idx <= digit_idx + 1;
                digit_sel <= 4'b0001 << digit_idx;  // Shift to next digit
            end else begin
                digit_idx <= 2'd0;  // Reset digit index after showing all digits
            end
        end
    end

    // Pass each buffer's data to the 7-segment driver based on digit select
    always @(*) begin
        case (digit_sel)
            4'b0001: seg = pass_buf0;  // Display first digit
            4'b0010: seg = pass_buf1;  // Display second digit
            4'b0100: seg = pass_buf2;  // Display third digit
            4'b1000: seg = pass_buf3;  // Display fourth digit
            default: seg = 7'b0000000;  // Default to empty
        endcase
    end

endmodule
