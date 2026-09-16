package FFT_config_pkg;

  import uvm_pkg::*;
  
  `include "uvm_macros.svh"

  class FFT_config extends uvm_object;
    `uvm_object_utils(FFT_config)

    // virtual interface to DUT
       virtual FFT_interface DUT_virtual_interface ;
       
    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
     function new(string name = "FFT_config");
       super.new(name);
     endfunction
  endclass

endpackage