package FFT_driver_pkg;

  import uvm_pkg::*;
  import FFT_sequence_item_pkg::*;

  `include "uvm_macros.svh"

  class FFT_driver extends uvm_driver #(FFT_sequence_item);
   `uvm_component_utils(FFT_driver)

    // virtual interface to DUT
       virtual FFT_interface DUT_virtual_interface ;

    // sequence item 
       FFT_sequence_item sequence_item;
  
    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "FFT_driver", uvm_component parent = null);
      super.new(name,parent);    
    endfunction

    //------------------------------------------------------------
    // Run phase
    //------------------------------------------------------------
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        sequence_item = FFT_sequence_item::type_id::create("sequence_item"); 
        seq_item_port.get_next_item(sequence_item);
        
           DUT_virtual_interface.rst_n    = sequence_item.rst_n    ;
           DUT_virtual_interface.valid_in = sequence_item.valid_in ;
           DUT_virtual_interface.in_r     = sequence_item.in_r     ;
           DUT_virtual_interface.in_i     = sequence_item.in_i     ;



        @(negedge DUT_virtual_interface.clk);
        seq_item_port.item_done();
      end
    endtask

  endclass
endpackage