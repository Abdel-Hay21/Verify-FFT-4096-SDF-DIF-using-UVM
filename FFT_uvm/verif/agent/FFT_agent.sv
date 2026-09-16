package FFT_agent_pkg;

import uvm_pkg::*;
import FFT_sequence_item_pkg::*;
import FFT_config_pkg::*;
import FFT_sequencer_pkg::*;
import FFT_driver_pkg::*;
import FFT_monitor_pkg::*;

`include "uvm_macros.svh"

class FFT_agent extends uvm_agent;
  `uvm_component_utils(FFT_agent)
  
  // Active or Passive agent
     uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  // Create Object
     FFT_sequencer    sequencer ;
     FFT_driver       driver    ;
     FFT_monitor      monitor   ;
     FFT_config       cfg       ;

  // Analysis_port 
     uvm_analysis_port #(FFT_sequence_item) DUT_analysis_port;

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new (string name = "FFT_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction



  //------------------------------------------------------------
  // Build phase
  //------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if( !uvm_config_db #(FFT_config):: get(this,"","CFG", cfg) )
      `uvm_fatal("build_phase", "Agent - Unable to get the virtual interface");
    
    if( is_active == UVM_ACTIVE ) begin
      sequencer  = FFT_sequencer:: type_id:: create("sequencer",this);
      driver     = FFT_driver::    type_id:: create("driver"   ,this);
    end
      monitor    = FFT_monitor::   type_id:: create("monitor"  ,this);
    
    DUT_analysis_port    = new("DUT_analysis_port"   ,this);
  endfunction


  //------------------------------------------------------------
  // Connect phase
  //------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Monitor Connection
       // Interface
          monitor.DUT_virtual_interface = cfg.DUT_virtual_interface;
       // Transaction
          monitor.DUT_analysis_port.connect(DUT_analysis_port);

     // Driver and Sequencer Connection
       if(is_active == UVM_ACTIVE) begin
         // Interface
            driver.DUT_virtual_interface = cfg.DUT_virtual_interface;
         // Transaction   
            driver.seq_item_port.connect(sequencer.seq_item_export);
       end
  endfunction
  
endclass
endpackage