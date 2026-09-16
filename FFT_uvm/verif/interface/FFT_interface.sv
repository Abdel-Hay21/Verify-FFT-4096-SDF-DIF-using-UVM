interface FFT_interface(clk);

  input bit clk;

  bit        rst_n      ;
  bit        valid_in   ;
  bit [11:0] in_r       ;
  bit [11:0] in_i       ;
  bit [11:0] out_r      ;
  bit [11:0] out_i      ;
  bit        valid_out  ;
  bit        frame_done ;
  bit [11:0] out_index  ;


  modport DUT(
    input  clk          ,
    input  rst_n        ,
    input  valid_in     ,
    input  in_r         ,
    input  in_i         ,
    output out_r        ,
    output out_i        ,
    output valid_out    ,
    output frame_done   ,
    output out_index 
  );

  modport TEST(
    output clk          ,
    output rst_n        ,
    output valid_in     ,
    output in_r         ,
    output in_i         ,
    input  out_r        ,
    input  out_i        ,
    input  valid_out    ,
    input  frame_done   ,
    input  out_index 
  );

endinterface

