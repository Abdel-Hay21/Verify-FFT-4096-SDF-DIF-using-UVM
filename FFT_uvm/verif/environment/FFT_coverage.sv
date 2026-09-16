package FFT_coverage_pkg;

  import uvm_pkg::*;
  import FFT_sequence_item_pkg::*;

  `include "uvm_macros.svh"


  class FFT_coverage extends uvm_component;
    `uvm_component_utils(FFT_coverage)

    // Define analysis export & tlm_fifo
       uvm_analysis_export   #(FFT_sequence_item) Seq_export ;
       uvm_tlm_analysis_fifo #(FFT_sequence_item) fifo       ;

    // sequence_item
       FFT_sequence_item sequence_item;
    
    // coverage group
       covergroup cover_group;
         option.per_instance = 1;
         option.goal         = 100;
         option.comment      = "FFT Functional Coverage";

         // ── Input Signal Coverpoints ──────────────────────────────────────
         cp_rst_n: coverpoint sequence_item.rst_n {
           bins reset_active   = {0};
           bins reset_inactive = {1};
         }

         cp_valid_in: coverpoint sequence_item.valid_in {
           bins inactive = {0};
           bins active   = {1};
           bins trans_inactive_to_active = (0 => 1);
           bins trans_active_to_inactive = (1 => 0);
         }

         // ── Output / Status Signal Coverpoints ───────────────────────────
         cp_valid_out: coverpoint sequence_item.valid_out {
           bins inactive = {0};
           bins active   = {1};
           bins trans_inactive_to_active = (0 => 1);
         }

         cp_frame_done: coverpoint sequence_item.frame_done {
           bins inactive = {0};
           bins active   = {1};
           bins trans_inactive_to_active = (0 => 1);
           bins trans_active_to_inactive = (1 => 0);
         }


         cp_out_index: coverpoint sequence_item.out_index {
           bins index_zero = {0};
           bins index_low  = {[1 : 1023]};
           bins index_mid  = {[1024 : 3071]};
           bins index_high = {[3072 : 4094]};
           bins index_max  = {4095};
           bins wrap_around = (4095 => 0);
         }

         // ── Cross Coverage ────────────────────────────────────────────────
         cross_valid_in_rst_n:       cross cp_valid_in,  cp_rst_n {
          ignore_bins rst_n_is_Active =
              binsof(cp_rst_n.reset_active);
         }

         cross_valid_out_index:      cross cp_valid_out, cp_out_index {
          ignore_bins valid_out_transitions =
              binsof(cp_valid_out.trans_inactive_to_active) ||
              binsof(cp_valid_out.inactive);
         }

         cross_valid_out_frame_done: cross cp_valid_out, cp_frame_done {
          ignore_bins valid_out_transitions =
              binsof(cp_valid_out.trans_inactive_to_active) ||
              binsof(cp_valid_out.inactive);
         }

       endgroup







    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "FFT_coverage", uvm_component parent = null);
     super.new(name, parent);
     cover_group = new;
    endfunction
    


    //------------------------------------------------------------
    // Build phase
    //------------------------------------------------------------
    function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     Seq_export = new("Seq_export", this);
     fifo       = new("fifo"      , this);
    endfunction
     


    //------------------------------------------------------------
    // Connect phase
    //------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     Seq_export.connect(fifo.analysis_export);
    endfunction



    //------------------------------------------------------------
    // Run phase
    //------------------------------------------------------------
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
       fifo.get(sequence_item);
       cover_group.sample();
      end
    endtask
  endclass
endpackage