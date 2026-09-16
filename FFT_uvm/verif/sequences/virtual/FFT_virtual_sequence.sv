package FFT_virtual_sequence_pkg;

import uvm_pkg::*;

import FFT_virtual_sequencer_pkg::*;
import FFT_Reset_sequence_pkg::*;
import FFT_Continuous_Frames_sequence_pkg::*;
import FFT_Small_Break_Bewteen_Frames_sequence_pkg::*;
import FFT_Large_Break_Bewteen_Frames_sequence_pkg::*;

`include "uvm_macros.svh"

class FFT_virtual_sequence extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(FFT_virtual_sequence)
  `uvm_declare_p_sequencer(FFT_virtual_sequencer)

  // Class All Sequences
     FFT_Reset_sequence                       Reset_sequence                      ;
     FFT_Continuous_Frames_sequence           Continuous_Frames_sequence          ;
     FFT_Small_Break_Bewteen_Frames_sequence  Small_Break_Bewteen_Frames_sequence ;
     FFT_Large_Break_Bewteen_Frames_sequence  Large_Break_Bewteen_Frames_sequence ;




  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new(string name = "FFT_virtual_sequence");
    super.new(name);
  endfunction



  //------------------------------------------------------------
  // Body
  //------------------------------------------------------------
  virtual task body();

    if (p_sequencer == null)
      `uvm_fatal("body", "Virtual Sequence - p_sequencer is not set")

    // All Sequences
       Reset_sequence                      =    FFT_Reset_sequence::                      type_id:: create("Reset_sequence"                     );
       Continuous_Frames_sequence          =    FFT_Continuous_Frames_sequence::          type_id:: create("Continuous_Frames_sequence"         );
       Small_Break_Bewteen_Frames_sequence =    FFT_Small_Break_Bewteen_Frames_sequence:: type_id:: create("Small_Break_Bewteen_Frames_sequence");
       Large_Break_Bewteen_Frames_sequence =    FFT_Large_Break_Bewteen_Frames_sequence:: type_id:: create("Large_Break_Bewteen_Frames_sequence");


    // Adapt Repeation of each sequence
       Reset_sequence.repeat_number                      = 1     ;
       Continuous_Frames_sequence.repeat_number          = 8192  ;
       Small_Break_Bewteen_Frames_sequence.repeat_number = 8195  ;
       Large_Break_Bewteen_Frames_sequence.repeat_number = 20480 ;

    


    // Reset sequence
       `uvm_info("run_phase", "Reset Asserted"                        , UVM_LOW)
        Reset_sequence.start(p_sequencer.sequencer);     
       `uvm_info("run_phase", "Reset Deasserted"                      , UVM_LOW)

    // Continuous_Frames sequence
       `uvm_info("run_phase", "Continuous_Frames Asserted"            , UVM_LOW)
        Continuous_Frames_sequence.start(p_sequencer.sequencer);     
       `uvm_info("run_phase", "Continuous_Frames Deasserted"          , UVM_LOW)

    // Small_Break_Bewteen_Frames sequence
       `uvm_info("run_phase", "Small_Break_Bewteen_Frames Asserted"   , UVM_LOW)
        Small_Break_Bewteen_Frames_sequence.start(p_sequencer.sequencer);     
       `uvm_info("run_phase", "Small_Break_Bewteen_Frames Deasserted" , UVM_LOW)

    // Large_Break_Bewteen_Frames sequence
       `uvm_info("run_phase", "Large_Break_Bewteen_Frames Asserted"   , UVM_LOW)
        Large_Break_Bewteen_Frames_sequence.start(p_sequencer.sequencer);     
       `uvm_info("run_phase", "Large_Break_Bewteen_Frames Deasserted" , UVM_LOW)


  endtask
endclass

endpackage


