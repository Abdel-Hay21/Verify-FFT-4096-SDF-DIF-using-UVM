package FFT_sequencer_pkg;

  import uvm_pkg::*;
  import FFT_sequence_item_pkg::*;

  `include "uvm_macros.svh"

  class FFT_sequencer extends uvm_sequencer #(FFT_sequence_item);
    `uvm_component_utils(FFT_sequencer);

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new (string name = "FFT_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass

endpackage