package FFT_test_pkg;

import uvm_pkg::*;

import FFT_environment_pkg::*;
import FFT_agent_pkg::*;
import FFT_sequencer_pkg::*;
import FFT_virtual_sequence_pkg::*;
import FFT_config_pkg::*;

`include "uvm_macros.svh"

class FFT_test extends uvm_test;
  `uvm_component_utils(FFT_test)
  
  // Class ENVIRONMENT
     FFT_environment            environment;
          
  // Class CONFIG           
     FFT_config                 cfg;

  // Virtual Sequence
     FFT_virtual_sequence       virtual_sequence;



  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new(string name = "FFT_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction



  //------------------------------------------------------------
  // Build phase
  //------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // CFG
       cfg         = FFT_config::      type_id:: create("cfg"           ,this);
   
    // Environment
       environment = FFT_environment:: type_id:: create("environment"   ,this);


    if(!uvm_config_db #(virtual FFT_interface)::get(this,"","FFT_DUT_interface", cfg.DUT_virtual_interface))
      `uvm_fatal("build_phase", "Test - unable to get the FFT DUT virtual interface from config");


    uvm_config_db #(FFT_config)::set(this,"*","CFG", cfg);
  endfunction



  //------------------------------------------------------------
  // Run phase
  //------------------------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase       ( phase );
    phase.raise_objection ( this  );

    virtual_sequence = FFT_virtual_sequence::type_id::create("virtual_sequence");
    virtual_sequence.start(environment.virtual_sequencer);

    phase.drop_objection(this);
  endtask
endclass

endpackage


