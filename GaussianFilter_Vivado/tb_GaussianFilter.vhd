----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Muhammed KOCAOGLU
-- 
-- Create Date: 12/18/2021 02:16:00 PM
-- Design Name: 
-- Module Name: tb_GaussianFilter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE std.textio.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY tb_GaussianFilter IS
END tb_GaussianFilter;
ARCHITECTURE Behavioral OF tb_GaussianFilter IS

    COMPONENT design_GaussianFilter_wrapper IS
        PORT (
            ap_clk_0        : IN STD_LOGIC;
            ap_ctrl_0_done  : OUT STD_LOGIC;
            ap_ctrl_0_idle  : OUT STD_LOGIC;
            ap_ctrl_0_ready : OUT STD_LOGIC;
            ap_ctrl_0_start : IN STD_LOGIC;
            ap_return_0     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            ap_rst_0        : IN STD_LOGIC;
            data_in_0_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_1_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_2_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_3_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_4_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;

    PROCEDURE FILTERDATA (
        FILE RawImageHex_file  : text;
        SIGNAL CLK             : IN STD_LOGIC;
        SIGNAL ap_ctrl_0_start : OUT STD_LOGIC;
        SIGNAL data_in_0_0     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        SIGNAL data_in_1_0     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        SIGNAL data_in_2_0     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        SIGNAL data_in_3_0     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        SIGNAL data_in_4_0     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    ) IS
        VARIABLE RawImageHex_current_line  : line;
        VARIABLE RawImageHex_current_field : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        WAIT UNTIL falling_edge(CLK);

        readline(RawImageHex_file, RawImageHex_current_line);
        hread(RawImageHex_current_line, RawImageHex_current_field);
        data_in_0_0 <= RawImageHex_current_field;

        readline(RawImageHex_file, RawImageHex_current_line);
        hread(RawImageHex_current_line, RawImageHex_current_field);
        data_in_1_0 <= RawImageHex_current_field;

        readline(RawImageHex_file, RawImageHex_current_line);
        hread(RawImageHex_current_line, RawImageHex_current_field);
        data_in_2_0 <= RawImageHex_current_field;

        readline(RawImageHex_file, RawImageHex_current_line);
        hread(RawImageHex_current_line, RawImageHex_current_field);
        data_in_3_0 <= RawImageHex_current_field;

        readline(RawImageHex_file, RawImageHex_current_line);
        hread(RawImageHex_current_line, RawImageHex_current_field);
        data_in_4_0 <= RawImageHex_current_field;
        WAIT UNTIL falling_edge(CLK);
        ap_ctrl_0_start <= '1';
        WAIT UNTIL falling_edge(CLK);
        ap_ctrl_0_start <= '0';

    END PROCEDURE;
    SIGNAL CLK             : STD_LOGIC                      := '1';
    SIGNAL ap_ctrl_0_done  : STD_LOGIC                      := '0';
    SIGNAL ap_ctrl_0_idle  : STD_LOGIC                      := '0';
    SIGNAL ap_ctrl_0_ready : STD_LOGIC                      := '0';
    SIGNAL ap_ctrl_0_start : STD_LOGIC                      := '0';
    SIGNAL ap_return_0     : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ap_rst_0        : STD_LOGIC                      := '0';
    SIGNAL data_in_0_0     : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL data_in_1_0     : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL data_in_2_0     : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL data_in_3_0     : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL data_in_4_0     : STD_LOGIC_VECTOR (7 DOWNTO 0)  := (OTHERS => '0');

    SIGNAL Diff           : INTEGER                       := 0;
    SIGNAL addrGoldenCntr : INTEGER                       := 0;
    SIGNAL doutGolden     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    CLK <= NOT CLK AFTER 5 ns;

    dut : PROCESS
        VARIABLE GoldenResult_file_current_line : line;
        FILE RawImageHex_file                   : text OPEN read_mode IS "C:\Users\Muhammed\OneDrive\FPGA_Projects\GaussianFilterHLS\GaussianFilterHLS.srcs\sim_1\new\ImageMeRawArrayHex.txt";
        FILE GoldenResult_file                  : text OPEN read_mode IS "C:\Users\Muhammed\OneDrive\FPGA_Projects\GaussianFilterHLS\GaussianFilterHLS.srcs\sim_1\new\GoldenImageHexVec.txt";
        FILE test_vector                        : text OPEN write_mode IS "C:\Users\Muhammed\OneDrive\FPGA_Projects\GaussianFilterHLS\GaussianFilterHLS.srcs\sim_1\new\filteredImageHexMe.txt";
        VARIABLE row                            : line;
        VARIABLE GoldenData_current_field       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        WHILE NOT endfile(RawImageHex_file) LOOP
            FILTERDATA(RawImageHex_file, CLK, ap_ctrl_0_start, data_in_0_0, data_in_1_0, data_in_2_0, data_in_3_0, data_in_4_0);
            WAIT UNTIL ap_ctrl_0_ready = '1';

            readline(GoldenResult_file, GoldenResult_file_current_line);
            hread(GoldenResult_file_current_line, GoldenData_current_field);
            doutGolden <= GoldenData_current_field;

            WAIT UNTIL falling_edge(CLK);
            WAIT UNTIL falling_edge(CLK);
            Diff <= ABS(conv_integer(GoldenData_current_field) - conv_integer(ap_return_0));
            WAIT UNTIL falling_edge(CLK);
            hwrite(row, ap_return_0);
            writeline(test_vector, row);

           -- REPORT "The index of data is " & INTEGER'image(addrGoldenCntr);
            --ASSERT Diff < 4 OR GoldenData_current_field = x"00000000"
            --REPORT "Diff must be smaller than 3"
            --    SEVERITY failure;

            addrGoldenCntr <= addrGoldenCntr + 1;

        END LOOP;

        file_close(test_vector);
        file_close(RawImageHex_file);
        file_close(GoldenResult_file);
        WAIT FOR 50 ns;
        REPORT "Simulation completed successfully.";
        std.env.finish;
    END PROCESS;

    design_GaussianFilter_wrapper_Inst : design_GaussianFilter_wrapper
    PORT MAP(
        ap_clk_0        => CLK,
        ap_ctrl_0_done  => ap_ctrl_0_done,
        ap_ctrl_0_idle  => ap_ctrl_0_idle,
        ap_ctrl_0_ready => ap_ctrl_0_ready,
        ap_ctrl_0_start => ap_ctrl_0_start,
        ap_return_0     => ap_return_0,
        ap_rst_0        => ap_rst_0,
        data_in_0_0     => data_in_0_0,
        data_in_1_0     => data_in_1_0,
        data_in_2_0     => data_in_2_0,
        data_in_3_0     => data_in_3_0,
        data_in_4_0     => data_in_4_0
    );

END Behavioral;