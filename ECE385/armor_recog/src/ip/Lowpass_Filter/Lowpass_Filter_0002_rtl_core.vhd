-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 18.1 (Release Build #625)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2018 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from Lowpass_Filter_0002_rtl_core
-- VHDL created on Fri Dec 14 16:42:55 2018


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity Lowpass_Filter_0002_rtl_core is
    port (
        xIn_v : in std_logic_vector(0 downto 0);  -- sfix1
        xIn_c : in std_logic_vector(7 downto 0);  -- sfix8
        xIn_0 : in std_logic_vector(8 downto 0);  -- sfix9
        xOut_v : out std_logic_vector(0 downto 0);  -- ufix1
        xOut_c : out std_logic_vector(7 downto 0);  -- ufix8
        xOut_0 : out std_logic_vector(16 downto 0);  -- sfix17
        clk : in std_logic;
        areset : in std_logic
    );
end Lowpass_Filter_0002_rtl_core;

architecture normal of Lowpass_Filter_0002_rtl_core is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_memread_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_13_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_wi0_r0_phasedelay0_q_12_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr2_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr3_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr4_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_q : STD_LOGIC_VECTOR (8 downto 0);
    signal d_u0_m0_wo0_wi0_r0_delayr5_q_11_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr6_q : STD_LOGIC_VECTOR (8 downto 0);
    signal u0_m0_wo0_mtree_add0_0_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_add0_0_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_add0_0_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_add0_0_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_add0_1_a : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_1_b : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_1_o : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_1_q : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_2_a : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_2_b : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_2_o : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add0_2_q : STD_LOGIC_VECTOR (13 downto 0);
    signal u0_m0_wo0_mtree_add1_0_a : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_add1_0_b : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_add1_0_o : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_add1_0_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_add1_1_a : STD_LOGIC_VECTOR (14 downto 0);
    signal u0_m0_wo0_mtree_add1_1_b : STD_LOGIC_VECTOR (14 downto 0);
    signal u0_m0_wo0_mtree_add1_1_o : STD_LOGIC_VECTOR (14 downto 0);
    signal u0_m0_wo0_mtree_add1_1_q : STD_LOGIC_VECTOR (14 downto 0);
    signal u0_m0_wo0_mtree_add2_0_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_mtree_add2_0_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_mtree_add2_0_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_mtree_add2_0_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_oseq_gated_reg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_add_1_a : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_add_1_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_add_1_o : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_add_1_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_sub_1_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_sub_1_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_sub_1_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_sub_1_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_add_1_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_add_1_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_add_1_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_add_1_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_sub_1_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_sub_1_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_sub_1_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_sub_1_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_add_1_a : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_add_1_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_add_1_o : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_add_1_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_shift0_q : STD_LOGIC_VECTOR (10 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_shift0_qint : STD_LOGIC_VECTOR (10 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_shift0_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_shift0_qint : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_shift0_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_shift0_qint : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_shift0_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_shift0_qint : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_shift0_q : STD_LOGIC_VECTOR (10 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_shift0_qint : STD_LOGIC_VECTOR (10 downto 0);

begin


    -- VCC(CONSTANT,1)@0
    VCC_q <= "1";

    -- d_u0_m0_wo0_wi0_r0_phasedelay0_q_12(DELAY,68)@10 + 2
    d_u0_m0_wo0_wi0_r0_phasedelay0_q_12 : dspba_delay
    GENERIC MAP ( width => 9, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_0, xout => d_u0_m0_wo0_wi0_r0_phasedelay0_q_12_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_mult1_5_shift0(BITSHIFT,55)@10
    u0_m0_wo0_mtree_mult1_5_shift0_qint <= u0_m0_wo0_wi0_r0_delayr1_q & "00";
    u0_m0_wo0_mtree_mult1_5_shift0_q <= u0_m0_wo0_mtree_mult1_5_shift0_qint(10 downto 0);

    -- u0_m0_wo0_wi0_r0_delayr1(DELAY,20)@10
    u0_m0_wo0_wi0_r0_delayr1 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_0, xout => u0_m0_wo0_wi0_r0_delayr1_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_mult1_5_add_1(ADD,56)@10 + 1
    u0_m0_wo0_mtree_mult1_5_add_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 9 => u0_m0_wo0_wi0_r0_delayr1_q(8)) & u0_m0_wo0_wi0_r0_delayr1_q));
    u0_m0_wo0_mtree_mult1_5_add_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 11 => u0_m0_wo0_mtree_mult1_5_shift0_q(10)) & u0_m0_wo0_mtree_mult1_5_shift0_q));
    u0_m0_wo0_mtree_mult1_5_add_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_mult1_5_add_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_mult1_5_add_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_mult1_5_add_1_a) + SIGNED(u0_m0_wo0_mtree_mult1_5_add_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_mult1_5_add_1_q <= u0_m0_wo0_mtree_mult1_5_add_1_o(11 downto 0);

    -- u0_m0_wo0_wi0_r0_delayr2(DELAY,21)@10
    u0_m0_wo0_wi0_r0_delayr2 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr1_q, xout => u0_m0_wo0_wi0_r0_delayr2_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_mult1_4_shift0(BITSHIFT,57)@10
    u0_m0_wo0_mtree_mult1_4_shift0_qint <= u0_m0_wo0_wi0_r0_delayr2_q & "000";
    u0_m0_wo0_mtree_mult1_4_shift0_q <= u0_m0_wo0_mtree_mult1_4_shift0_qint(11 downto 0);

    -- u0_m0_wo0_mtree_mult1_4_sub_1(SUB,58)@10 + 1
    u0_m0_wo0_mtree_mult1_4_sub_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_mtree_mult1_4_shift0_q(11)) & u0_m0_wo0_mtree_mult1_4_shift0_q));
    u0_m0_wo0_mtree_mult1_4_sub_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 9 => u0_m0_wo0_wi0_r0_delayr2_q(8)) & u0_m0_wo0_wi0_r0_delayr2_q));
    u0_m0_wo0_mtree_mult1_4_sub_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_mult1_4_sub_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_mult1_4_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_mult1_4_sub_1_a) - SIGNED(u0_m0_wo0_mtree_mult1_4_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_mult1_4_sub_1_q <= u0_m0_wo0_mtree_mult1_4_sub_1_o(12 downto 0);

    -- u0_m0_wo0_mtree_add0_2(ADD,45)@11 + 1
    u0_m0_wo0_mtree_add0_2_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((13 downto 13 => u0_m0_wo0_mtree_mult1_4_sub_1_q(12)) & u0_m0_wo0_mtree_mult1_4_sub_1_q));
    u0_m0_wo0_mtree_add0_2_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((13 downto 12 => u0_m0_wo0_mtree_mult1_5_add_1_q(11)) & u0_m0_wo0_mtree_mult1_5_add_1_q));
    u0_m0_wo0_mtree_add0_2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_2_a) + SIGNED(u0_m0_wo0_mtree_add0_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_2_q <= u0_m0_wo0_mtree_add0_2_o(13 downto 0);

    -- u0_m0_wo0_mtree_add1_1(ADD,47)@12 + 1
    u0_m0_wo0_mtree_add1_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((14 downto 14 => u0_m0_wo0_mtree_add0_2_q(13)) & u0_m0_wo0_mtree_add0_2_q));
    u0_m0_wo0_mtree_add1_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((14 downto 9 => d_u0_m0_wo0_wi0_r0_phasedelay0_q_12_q(8)) & d_u0_m0_wo0_wi0_r0_phasedelay0_q_12_q));
    u0_m0_wo0_mtree_add1_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_1_a) + SIGNED(u0_m0_wo0_mtree_add1_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_1_q <= u0_m0_wo0_mtree_add1_1_o(14 downto 0);

    -- u0_m0_wo0_mtree_mult1_3_shift0(BITSHIFT,59)@10
    u0_m0_wo0_mtree_mult1_3_shift0_qint <= u0_m0_wo0_wi0_r0_delayr3_q & "000";
    u0_m0_wo0_mtree_mult1_3_shift0_q <= u0_m0_wo0_mtree_mult1_3_shift0_qint(11 downto 0);

    -- u0_m0_wo0_wi0_r0_delayr3(DELAY,22)@10
    u0_m0_wo0_wi0_r0_delayr3 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr2_q, xout => u0_m0_wo0_wi0_r0_delayr3_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_mult1_3_add_1(ADD,60)@10 + 1
    u0_m0_wo0_mtree_mult1_3_add_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 9 => u0_m0_wo0_wi0_r0_delayr3_q(8)) & u0_m0_wo0_wi0_r0_delayr3_q));
    u0_m0_wo0_mtree_mult1_3_add_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_mtree_mult1_3_shift0_q(11)) & u0_m0_wo0_mtree_mult1_3_shift0_q));
    u0_m0_wo0_mtree_mult1_3_add_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_mult1_3_add_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_mult1_3_add_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_mult1_3_add_1_a) + SIGNED(u0_m0_wo0_mtree_mult1_3_add_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_mult1_3_add_1_q <= u0_m0_wo0_mtree_mult1_3_add_1_o(12 downto 0);

    -- u0_m0_wo0_wi0_r0_delayr4(DELAY,23)@10
    u0_m0_wo0_wi0_r0_delayr4 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr3_q, xout => u0_m0_wo0_wi0_r0_delayr4_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_mult1_2_shift0(BITSHIFT,61)@10
    u0_m0_wo0_mtree_mult1_2_shift0_qint <= u0_m0_wo0_wi0_r0_delayr4_q & "000";
    u0_m0_wo0_mtree_mult1_2_shift0_q <= u0_m0_wo0_mtree_mult1_2_shift0_qint(11 downto 0);

    -- u0_m0_wo0_mtree_mult1_2_sub_1(SUB,62)@10 + 1
    u0_m0_wo0_mtree_mult1_2_sub_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_mtree_mult1_2_shift0_q(11)) & u0_m0_wo0_mtree_mult1_2_shift0_q));
    u0_m0_wo0_mtree_mult1_2_sub_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 9 => u0_m0_wo0_wi0_r0_delayr4_q(8)) & u0_m0_wo0_wi0_r0_delayr4_q));
    u0_m0_wo0_mtree_mult1_2_sub_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_mult1_2_sub_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_mult1_2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_mult1_2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_mult1_2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_mult1_2_sub_1_q <= u0_m0_wo0_mtree_mult1_2_sub_1_o(12 downto 0);

    -- u0_m0_wo0_mtree_add0_1(ADD,44)@11 + 1
    u0_m0_wo0_mtree_add0_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((13 downto 13 => u0_m0_wo0_mtree_mult1_2_sub_1_q(12)) & u0_m0_wo0_mtree_mult1_2_sub_1_q));
    u0_m0_wo0_mtree_add0_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((13 downto 13 => u0_m0_wo0_mtree_mult1_3_add_1_q(12)) & u0_m0_wo0_mtree_mult1_3_add_1_q));
    u0_m0_wo0_mtree_add0_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_1_a) + SIGNED(u0_m0_wo0_mtree_add0_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_1_q <= u0_m0_wo0_mtree_add0_1_o(13 downto 0);

    -- u0_m0_wo0_mtree_mult1_1_shift0(BITSHIFT,63)@10
    u0_m0_wo0_mtree_mult1_1_shift0_qint <= u0_m0_wo0_wi0_r0_delayr5_q & "00";
    u0_m0_wo0_mtree_mult1_1_shift0_q <= u0_m0_wo0_mtree_mult1_1_shift0_qint(10 downto 0);

    -- u0_m0_wo0_wi0_r0_delayr5(DELAY,24)@10
    u0_m0_wo0_wi0_r0_delayr5 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr4_q, xout => u0_m0_wo0_wi0_r0_delayr5_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_mult1_1_add_1(ADD,64)@10 + 1
    u0_m0_wo0_mtree_mult1_1_add_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 9 => u0_m0_wo0_wi0_r0_delayr5_q(8)) & u0_m0_wo0_wi0_r0_delayr5_q));
    u0_m0_wo0_mtree_mult1_1_add_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 11 => u0_m0_wo0_mtree_mult1_1_shift0_q(10)) & u0_m0_wo0_mtree_mult1_1_shift0_q));
    u0_m0_wo0_mtree_mult1_1_add_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_mult1_1_add_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_mult1_1_add_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_mult1_1_add_1_a) + SIGNED(u0_m0_wo0_mtree_mult1_1_add_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_mult1_1_add_1_q <= u0_m0_wo0_mtree_mult1_1_add_1_o(11 downto 0);

    -- d_u0_m0_wo0_memread_q_11(DELAY,65)@10 + 1
    d_u0_m0_wo0_memread_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_v, xout => d_u0_m0_wo0_memread_q_11_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_compute_q_11(DELAY,66)@10 + 1
    d_u0_m0_wo0_compute_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_v, xout => d_u0_m0_wo0_compute_q_11_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_wi0_r0_delayr5_q_11(DELAY,69)@10 + 1
    d_u0_m0_wo0_wi0_r0_delayr5_q_11 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr5_q, xout => d_u0_m0_wo0_wi0_r0_delayr5_q_11_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_wi0_r0_delayr6(DELAY,25)@11
    u0_m0_wo0_wi0_r0_delayr6 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => d_u0_m0_wo0_wi0_r0_delayr5_q_11_q, xout => u0_m0_wo0_wi0_r0_delayr6_q, ena => d_u0_m0_wo0_compute_q_11_q(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_add0_0(ADD,43)@11 + 1
    u0_m0_wo0_mtree_add0_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 9 => u0_m0_wo0_wi0_r0_delayr6_q(8)) & u0_m0_wo0_wi0_r0_delayr6_q));
    u0_m0_wo0_mtree_add0_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_mtree_mult1_1_add_1_q(11)) & u0_m0_wo0_mtree_mult1_1_add_1_q));
    u0_m0_wo0_mtree_add0_0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_0_a) + SIGNED(u0_m0_wo0_mtree_add0_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_0_q <= u0_m0_wo0_mtree_add0_0_o(12 downto 0);

    -- u0_m0_wo0_mtree_add1_0(ADD,46)@12 + 1
    u0_m0_wo0_mtree_add1_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((15 downto 13 => u0_m0_wo0_mtree_add0_0_q(12)) & u0_m0_wo0_mtree_add0_0_q));
    u0_m0_wo0_mtree_add1_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((15 downto 14 => u0_m0_wo0_mtree_add0_1_q(13)) & u0_m0_wo0_mtree_add0_1_q));
    u0_m0_wo0_mtree_add1_0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_0_a) + SIGNED(u0_m0_wo0_mtree_add1_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_0_q <= u0_m0_wo0_mtree_add1_0_o(15 downto 0);

    -- u0_m0_wo0_mtree_add2_0(ADD,48)@13 + 1
    u0_m0_wo0_mtree_add2_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_mtree_add1_0_q(15)) & u0_m0_wo0_mtree_add1_0_q));
    u0_m0_wo0_mtree_add2_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 15 => u0_m0_wo0_mtree_add1_1_q(14)) & u0_m0_wo0_mtree_add1_1_q));
    u0_m0_wo0_mtree_add2_0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add2_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add2_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add2_0_a) + SIGNED(u0_m0_wo0_mtree_add2_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add2_0_q <= u0_m0_wo0_mtree_add2_0_o(16 downto 0);

    -- GND(CONSTANT,0)@0
    GND_q <= "0";

    -- d_u0_m0_wo0_compute_q_13(DELAY,67)@11 + 2
    d_u0_m0_wo0_compute_q_13 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => d_u0_m0_wo0_compute_q_11_q, xout => d_u0_m0_wo0_compute_q_13_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_oseq_gated_reg(REG,49)@13 + 1
    u0_m0_wo0_oseq_gated_reg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= STD_LOGIC_VECTOR(d_u0_m0_wo0_compute_q_13_q);
        END IF;
    END PROCESS;

    -- xOut(PORTOUT,54)@14 + 1
    xOut_v <= u0_m0_wo0_oseq_gated_reg_q;
    xOut_c <= STD_LOGIC_VECTOR("0000000" & GND_q);
    xOut_0 <= u0_m0_wo0_mtree_add2_0_q;

END normal;
