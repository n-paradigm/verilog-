library verilog;
use verilog.vl_types.all;
entity Block1_vlg_check_tst is
    port(
        buzzer          : in     vl_logic;
        led1            : in     vl_logic;
        led2            : in     vl_logic;
        led3            : in     vl_logic;
        pin_name4       : in     vl_logic_vector(3 downto 0);
        safe_open       : in     vl_logic;
        seg             : in     vl_logic_vector(6 downto 0);
        sel             : in     vl_logic_vector(3 downto 0);
        sampler_rx      : in     vl_logic
    );
end Block1_vlg_check_tst;
