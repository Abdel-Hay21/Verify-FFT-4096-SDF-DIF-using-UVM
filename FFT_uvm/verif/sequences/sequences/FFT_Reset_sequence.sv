package FFT_Reset_sequence_pkg;

  import uvm_pkg::*;
  import FFT_sequence_item_pkg::*;

  `include "uvm_macros.svh"
  
  class FFT_Reset_sequence extends uvm_sequence #(FFT_sequence_item);
    `uvm_object_utils(FFT_Reset_sequence)
     FFT_sequence_item sequence_item;

    // Num of Repeation
       int repeat_number = 1;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new (string name = "FFT_Reset_sequence");
      super.new(name);
    endfunction

    //------------------------------------------------------------
    // Body
    //------------------------------------------------------------
    task body;
     repeat(repeat_number) begin
       // Create a new sequence_item
          sequence_item = FFT_sequence_item::type_id::create("sequence_item");
           
       // Set the constraint mode
          sequence_item.Global_Constraint.constraint_mode(1);
          sequence_item.Reset_Constraint.constraint_mode(1);
          sequence_item.Continuous_Frames_Constraint.constraint_mode(0);
          sequence_item.Small_Break_Bewteen_Frames_Constraint.constraint_mode(0);
          sequence_item.Large_Break_Bewteen_Frames_Constraint.constraint_mode(0);
                  
       // Start, Randomize and Finish the sequence_item
          start_item  ( sequence_item             );
          assert      ( sequence_item.randomize() );
          finish_item ( sequence_item             );
     end
    endtask
  endclass

endpackage

