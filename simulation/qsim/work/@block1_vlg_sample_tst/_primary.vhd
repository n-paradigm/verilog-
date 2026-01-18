library verilog;
use verilog.vl_types.all;
entity Block1_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        key_locker      : in     vl_logic;
        rst_n           : in     vl_logic;
        swc             : in     vl_logic_vector(3 downto 0);
        sampler_tx      : out    vl_logic
    );
end Block1_vlg_sample_tst;
