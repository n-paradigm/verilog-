library verilog;
use verilog.vl_types.all;
entity Block1 is
    port(
        led1            : out    vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        swc             : in     vl_logic_vector(3 downto 0);
        key_locker      : in     vl_logic;
        led2            : out    vl_logic;
        led3            : out    vl_logic;
        buzzer          : out    vl_logic;
        safe_open       : out    vl_logic;
        pin_name4       : out    vl_logic_vector(3 downto 0);
        seg             : out    vl_logic_vector(6 downto 0);
        sel             : out    vl_logic_vector(3 downto 0)
    );
end Block1;
