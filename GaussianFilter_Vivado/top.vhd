----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2021 10:35:18 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY top IS
    GENERIC (
        c_clkfreq  : INTEGER := 100_000_000;
        c_baudrate : INTEGER := 115_200;
        c_stopbit  : INTEGER := 2
    );
    PORT (
        CLK  : IN STD_LOGIC;
        tx_o : OUT STD_LOGIC;
        rx_i : IN STD_LOGIC
    );
END top;

ARCHITECTURE Behavioral OF top IS

    COMPONENT design_GaussianFilter IS
        PORT (
            ap_clk_0        : IN STD_LOGIC;
            ap_return_0     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            ap_rst_0        : IN STD_LOGIC;
            data_in_0_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_1_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_2_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_3_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_in_4_0     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            ap_ctrl_0_start : IN STD_LOGIC;
            ap_ctrl_0_done  : OUT STD_LOGIC;
            ap_ctrl_0_idle  : OUT STD_LOGIC;
            ap_ctrl_0_ready : OUT STD_LOGIC
        );
    END COMPONENT design_GaussianFilter;
    SIGNAL ap_return_0     : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ap_ctrl_0_start : STD_LOGIC                      := '0';
    SIGNAL ap_ctrl_0_done  : STD_LOGIC                      := '0';
    SIGNAL ap_ctrl_0_idle  : STD_LOGIC                      := '0';
    SIGNAL ap_ctrl_0_ready : STD_LOGIC                      := '0';
    COMPONENT uart_tx IS
        GENERIC (
            c_clkfreq  : INTEGER := 100_000_000;
            c_baudrate : INTEGER := 115_200;
            c_stopbit  : INTEGER := 2
        );
        PORT (
            clk            : IN STD_LOGIC;
            din_i          : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            tx_start_i     : IN STD_LOGIC;
            tx_o           : OUT STD_LOGIC;
            tx_done_tick_o : OUT STD_LOGIC
        );
    END COMPONENT;
    -- uart tx
    SIGNAL din_i          : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tx_start_i     : STD_LOGIC                     := '0';
    SIGNAL tx_done_tick_o : STD_LOGIC                     := '0';
    COMPONENT uart_rx IS
        GENERIC (
            c_clkfreq  : INTEGER := 100_000_000;
            c_baudrate : INTEGER := 115_200
        );
        PORT (
            clk            : IN STD_LOGIC;
            rx_i           : IN STD_LOGIC;
            dout_o         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            rx_done_tick_o : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL dout_o         : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rx_done_tick_o : STD_LOGIC                     := '0';
    TYPE Mem2D IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL GaussianFiltered : Mem2D(0 TO 3) := (OTHERS => (OTHERS => '0'));
    SIGNAL GaussianIn       : Mem2D(0 TO 4) := (OTHERS => (OTHERS => '0'));
    SIGNAL cntrReceiver     : INTEGER       := 0;
    SIGNAL cntrTransmitter  : INTEGER       := 0;

    SIGNAL transmit_start : STD_LOGIC := '0';
BEGIN

    P_RECEIVE : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            ap_ctrl_0_start <= '0';
            IF cntrReceiver < 5 THEN
                IF rx_done_tick_o = '1' THEN
                    GaussianIn(cntrReceiver) <= dout_o;
                    cntrReceiver             <= cntrReceiver + 1;
                END IF;
            ELSE
                cntrReceiver    <= 0;
                ap_ctrl_0_start <= '1';
            END IF;
        END IF;
    END PROCESS;

    P_TRANSMIT : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF ap_ctrl_0_ready = '1' THEN
                transmit_start <= '1';
            END IF;

            IF transmit_start = '1' THEN
                IF cntrTransmitter = 0 THEN
                    tx_start_i      <= '1';
                    din_i           <= ap_return_0(4 * 8 - 1 DOWNTO 3 * 8);
                    cntrTransmitter <= cntrTransmitter + 1;
                ELSIF cntrTransmitter = 1 THEN
                    din_i <= ap_return_0(3 * 8 - 1 DOWNTO 2 * 8);
                    IF tx_done_tick_o = '1' THEN
                        cntrTransmitter <= cntrTransmitter + 1;
                    END IF;
                ELSIF cntrTransmitter = 2 THEN
                    din_i <= ap_return_0(2 * 8 - 1 DOWNTO 1 * 8);
                    IF tx_done_tick_o = '1' THEN
                        cntrTransmitter <= cntrTransmitter + 1;
                    END IF;
                ELSIF cntrTransmitter = 3 THEN
                    din_i <= ap_return_0(1 * 8 - 1 DOWNTO 0 * 8);
                    IF tx_done_tick_o = '1' THEN
                        cntrTransmitter <= cntrTransmitter + 1;
                    END IF;
                ELSIF cntrTransmitter = 4 THEN
                    tx_start_i <= '0';
                    IF tx_done_tick_o = '1' THEN
                        cntrTransmitter <= 0;
                        transmit_start  <= '0';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    design_GaussianFilter_i : design_GaussianFilter
    PORT MAP(
        ap_clk_0                 => CLK,
        ap_ctrl_0_done           => ap_ctrl_0_done,
        ap_ctrl_0_idle           => ap_ctrl_0_idle,
        ap_ctrl_0_ready          => ap_ctrl_0_ready,
        ap_ctrl_0_start          => ap_ctrl_0_start,
        ap_return_0(31 DOWNTO 0) => ap_return_0,
        ap_rst_0                 => '0',
        data_in_0_0(7 DOWNTO 0)  => GaussianIn(0),
        data_in_1_0(7 DOWNTO 0)  => GaussianIn(1),
        data_in_2_0(7 DOWNTO 0)  => GaussianIn(2),
        data_in_3_0(7 DOWNTO 0)  => GaussianIn(3),
        data_in_4_0(7 DOWNTO 0)  => GaussianIn(4)
    );
    uart_tx_Inst : uart_tx
    GENERIC MAP(
        c_clkfreq  => c_clkfreq,
        c_baudrate => c_baudrate,
        c_stopbit  => c_stopbit
    )
    PORT MAP(
        clk            => clk,
        din_i          => din_i,
        tx_start_i     => tx_start_i,
        tx_o           => tx_o,
        tx_done_tick_o => tx_done_tick_o
    );
    uart_rx_Inst : uart_rx
    GENERIC MAP(
        c_clkfreq  => c_clkfreq,
        c_baudrate => c_baudrate
    )
    PORT MAP(
        clk            => clk,
        rx_i           => rx_i,
        dout_o         => dout_o,
        rx_done_tick_o => rx_done_tick_o
    );

END Behavioral;