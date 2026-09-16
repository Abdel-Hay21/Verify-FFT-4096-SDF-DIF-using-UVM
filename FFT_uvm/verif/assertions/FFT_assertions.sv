`define DUT FFT_top.FFT_DUT
module FFT_assertions;

  // properties
     property check_reset;
     @(posedge `DUT.clk)
      (!`DUT.rst_n)
      |=> (`DUT.out_r == 0 && `DUT.out_i == 0 && `DUT.valid_out == 0 && `DUT.frame_done == 0 && `DUT.out_index == 0);
     endproperty

     property check_valid_latency;
     @(posedge `DUT.clk) disable iff (!`DUT.rst_n)
      (`DUT.valid_in [*4096])
      |=> if (`DUT.ORDERED_OUTPUT == 1) 
            (##4096 `DUT.valid_out [*4096]) 
          else 
            (`DUT.valid_out [*4096]);
     endproperty
      
     int frame_cnt;
     always_ff @(posedge `DUT.clk or negedge `DUT.rst_n) begin
         if (!`DUT.rst_n)
             frame_cnt <= 0;
         else if (`DUT.valid_out)
             frame_cnt <= (frame_cnt == 4095) ? 0 : frame_cnt + 1;
     end

     property check_frame_done;
     @(posedge `DUT.clk) disable iff (!`DUT.rst_n)
      (`DUT.valid_out && (frame_cnt == 4095))
      |=> `DUT.frame_done;
     endproperty

     property check_frame_done_pulse;
     @(posedge `DUT.clk) disable iff (!`DUT.rst_n)
      `DUT.frame_done
      |=> !`DUT.frame_done;
     endproperty

     property check_out_index_format;
     @(posedge `DUT.clk) disable iff (!`DUT.rst_n)
      (`DUT.valid_out)
      |-> if (`DUT.ORDERED_OUTPUT == 1) 
            (`DUT.out_index == `DUT.raw_count) 
          else 
            (`DUT.out_index == {`DUT.raw_count[0], `DUT.raw_count[1], `DUT.raw_count[2], `DUT.raw_count[3], `DUT.raw_count[4], `DUT.raw_count[5], `DUT.raw_count[6], `DUT.raw_count[7], `DUT.raw_count[8], `DUT.raw_count[9], `DUT.raw_count[10], `DUT.raw_count[11]});
     endproperty


  // assert property
     assert property (  check_reset                 ) else $error( "Reset failed: outputs did not clear to zero"                      );
     assert property (  check_valid_latency         ) else $error( "Latency failed: valid_out did not match expected 4096-cycle window" );
     assert property (  check_frame_done            ) else $error( "Frame done failed: frame_done not asserted on 4096th valid cycle"  );
     assert property (  check_frame_done_pulse      ) else $error( "Frame done pulse failed: frame_done held high for multiple cycles" );
     assert property (  check_out_index_format      ) else $error( "Index failed: out_index format does not match raw count/ordering"  );


  // cover property
     cover property (  check_reset                 );
     cover property (  check_valid_latency         );
     cover property (  check_frame_done            );
     cover property (  check_frame_done_pulse      );
     cover property (  check_out_index_format      );

endmodule