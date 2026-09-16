package FFT_virtual_sequencer_pkg;

  import uvm_pkg::*;
  import FFT_sequencer_pkg::*;

  `include "uvm_macros.svh"

  class FFT_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(FFT_virtual_sequencer)
  
    FFT_sequencer sequencer;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "FFT_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
  endclass

endpackage