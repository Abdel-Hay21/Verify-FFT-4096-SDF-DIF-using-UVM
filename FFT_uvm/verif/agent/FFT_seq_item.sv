package FFT_sequence_item_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


  class FFT_sequence_item extends uvm_sequence_item;

      rand bit         rst_n      ;
      rand bit         valid_in   ;
      rand bit  [11:0] in_r       ;
      rand bit  [11:0] in_i       ;
           bit  [11:0] out_r      ;
           bit  [11:0] out_i      ;
           bit         valid_out  ;
           bit         frame_done ;
           bit  [11:0] out_index  ;

      // Static variables to persist tracking of simulation cycles, file handle, and the last read sample pair
      static int        cycle_cnt   = 0;
      static int        file_desc   = 0;
      static bit        file_opened = 0;
      static bit [11:0] last_in_r   = 12'b0;
      static bit [11:0] last_in_i   = 12'b0;

     `uvm_object_utils_begin(FFT_sequence_item)

         `uvm_field_int(rst_n     , UVM_ALL_ON)
         `uvm_field_int(valid_in  , UVM_ALL_ON)
         `uvm_field_int(in_r      , UVM_ALL_ON)
         `uvm_field_int(in_i      , UVM_ALL_ON)

         `uvm_field_int(out_r     , UVM_ALL_ON)
         `uvm_field_int(out_i     , UVM_ALL_ON)
         `uvm_field_int(valid_out , UVM_ALL_ON)
         `uvm_field_int(frame_done, UVM_ALL_ON)
         `uvm_field_int(out_index , UVM_ALL_ON)

     `uvm_object_utils_end


     function string convert2string();
        string s;
        s = super.convert2string();
        s = { s, $sformatf("\n=================================================\n" ) };
        s = { s, $sformatf("  Inputs:\n"                                           ) };
        s = { s, $sformatf("    rst_n      = 'b%0b\n", rst_n                       ) };
        s = { s, $sformatf("    valid_in   = 'b%0b\n", valid_in                    ) };
        s = { s, $sformatf("    in_r       = 'h%0x\n", in_r                        ) };
        s = { s, $sformatf("    in_i       = 'h%0x\n", in_i                        ) };
        s = { s, $sformatf("  Outputs:\n"                                          ) };
        s = { s, $sformatf("    out_r      = 'h%0x\n", out_r                       ) };
        s = { s, $sformatf("    out_i      = 'h%0x\n", out_i                       ) };
        s = { s, $sformatf("    valid_out  = 'b%0b\n", valid_out                   ) };
        s = { s, $sformatf("    frame_done = 'b%0b\n", frame_done                  ) };
        s = { s, $sformatf("    out_index  = 'h%0x\n", out_index                   ) };
        s = { s, $sformatf("=================================================\n"   ) };
        return s;
     endfunction


     // Here write your Global constraints 
     // Global_Constraint means the constraints that you want to apply to all the sequences
        constraint Global_Constraint{
           soft rst_n == 1'b1;
           soft valid_in == 1'b1;
        }

     // Here write your Reset constraints
     // Reset_Constraint means the constraints that you want to apply to this sequence only
        constraint Reset_Constraint{
           rst_n == 1'b0;
           valid_in == 1'b0;
        }

     // Here write your Continuous_Frames constraints
     // Continuous_Frames_Constraint means the constraints that you want to apply to this sequence only
        constraint Continuous_Frames_Constraint{
           rst_n == 1'b1;
           valid_in == 1'b1;
        }

     // Here write your Small_Break_Bewteen_Frames constraints
     // Small_Break_Bewteen_Frames_Constraint means the constraints that you want to apply to this sequence only
        constraint Small_Break_Bewteen_Frames_Constraint{
           rst_n == 1'b1;
           if ((cycle_cnt) < 4096) {
              valid_in == 1'b1;
           } else if ((cycle_cnt) >= 4096 && (cycle_cnt) < 4099) {
              valid_in == 1'b0;
           } else {
              valid_in == 1'b1;
           }
        }

     // Here write your Large_Break_Bewteen_Frames constraints
     // Large_Break_Bewteen_Frames_Constraint means the constraints that you want to apply to this sequence only
        constraint Large_Break_Bewteen_Frames_Constraint{
           rst_n == 1'b1;
           if ((cycle_cnt) < 4096) {
              valid_in == 1'b1;
           } else if ((cycle_cnt) >= 4096 && (cycle_cnt) < 12288) {
              valid_in == 1'b0;
           } else if ((cycle_cnt) >= 12288 && (cycle_cnt) < 16384) {
              valid_in == 1'b1;
           } else {
              valid_in == 1'b0;
           }
        }

     //------------------------------------------------------------
     // post_randomize
     //------------------------------------------------------------
     function void post_randomize();
        cycle_cnt++;
        if (rst_n == 1'b0) begin
            in_r = 12'b0;
            in_i = 12'b0;
        end else if (valid_in == 1'b1) begin
            if (!file_opened) begin
                file_desc = $fopen("input_data_scrambled.txt", "r");
                if (file_desc == 0) begin
                    `uvm_fatal("FILE_OPEN_ERR", "Failed to open input_data_scrambled.txt")
                end
                file_opened = 1;
            end

            if (!$feof(file_desc)) begin
                integer r_status, i_status;
                
                r_status = $fscanf(file_desc, "%b\n", in_r);
                if (r_status != 1) begin
                    void'($fseek(file_desc, 0, 0));
                    r_status = $fscanf(file_desc, "%b\n", in_r);
                end
                
                if (!$feof(file_desc)) begin
                    i_status = $fscanf(file_desc, "%b\n", in_i);
                    if (i_status != 1) begin
                        in_i = 12'b0;
                    end
                end else begin
                    in_i = 12'b0;
                end
            end else begin
                void'($fseek(file_desc, 0, 0));
                void'($fscanf(file_desc, "%b\n", in_r));
                void'($fscanf(file_desc, "%b\n", in_i));
            end
            last_in_r = in_r;
            last_in_i = in_i;
        end else begin
            in_r = last_in_r;
            in_i = last_in_i;
        end
     endfunction

     //------------------------------------------------------------
     // Constructor
     //------------------------------------------------------------
     function new(string name = "FFT_sequence_item");
        super.new(name);
     endfunction

  endclass
endpackage