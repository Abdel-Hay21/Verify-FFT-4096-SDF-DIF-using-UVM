`timescale 1ns/1ps

import uvm_pkg::*;
import FFT_test_pkg::*;

`include "uvm_macros.svh"

module FFT_top;
  localparam time CLK_PERIOD = 2ns;

  // Prepare SYSTEM CLOCK
     bit clk;
     initial clk = 0;
     always #(CLK_PERIOD/2) clk = ~clk;
  
  // Interfaces
     FFT_interface     DUT_interface    (      clk      ) ;   // create FFT interface of DUT

  // DUT and Assertions 
     fft_4096_dif    FFT_DUT          (
       .clk        ( DUT_interface.clk        ) ,
       .rst_n      ( DUT_interface.rst_n      ) ,
       .valid_in   ( DUT_interface.valid_in   ) ,
       .in_r       ( DUT_interface.in_r       ) ,
       .in_i       ( DUT_interface.in_i       ) ,
       .out_r      ( DUT_interface.out_r      ) ,
       .out_i      ( DUT_interface.out_i      ) ,
       .valid_out  ( DUT_interface.valid_out  ) ,
       .frame_done ( DUT_interface.frame_done ) ,
       .out_index  ( DUT_interface.out_index  )
     ) ;   // connect FFT interface to DUT


  initial begin
    uvm_config_db#(virtual FFT_interface)::set(null, "*", "FFT_DUT_interface", DUT_interface);

    run_test("FFT_test");
  end
endmodule