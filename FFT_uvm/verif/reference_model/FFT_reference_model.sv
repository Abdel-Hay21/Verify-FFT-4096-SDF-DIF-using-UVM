package FFT_reference_model_pkg;
   import uvm_pkg::*;
   import FFT_sequence_item_pkg::*;
   `include "uvm_macros.svh"

   class FFT_reference_model extends uvm_object;
   
       `uvm_object_utils(FFT_reference_model)
    
       // Class-level state variables
       int unsigned raw_count;
       int unsigned read_index;
       bit          file_loaded;
       
       logic [11:0] exp_out_r_q [$];
       logic [11:0] exp_out_i_q [$];

       //------------------------------------------------------------
       // Constructor
       //------------------------------------------------------------
       function new(string name = "FFT_reference_model");
           super.new(name);
           raw_count   = 0;
           read_index  = 0;
           file_loaded = 1'b0;
       endfunction
   
       //------------------------------------------------------------
       // Load File
       //------------------------------------------------------------
       function void load_file();
           int file_h;
           logic [11:0] val;
           file_h = $fopen("output_data_scrambled.txt", "r");
           if (file_h == 0) begin
               `uvm_error("REF_MODEL", "Failed to open output_data_scrambled.txt")
               return;
           end
           while (!$feof(file_h)) begin
               if ($fscanf(file_h, "%b\n", val) == 1) begin
                   exp_out_r_q.push_back(val);
                   if ($fscanf(file_h, "%b\n", val) == 1) begin
                       exp_out_i_q.push_back(val);
                   end else begin
                       `uvm_warning("REF_MODEL", "Odd row missing or mismatch in output_data_scrambled.txt")
                   end
               end
           end
           $fclose(file_h);
           file_loaded = 1'b1;
           `uvm_info("REF_MODEL", $sformatf("Successfully loaded %0d samples from output_data_scrambled.txt", exp_out_r_q.size()), UVM_LOW)
       endfunction
   
       //------------------------------------------------------------
       // Execute
       //------------------------------------------------------------
       function FFT_sequence_item execute
       (
           input FFT_sequence_item request
       );
           FFT_sequence_item response;
           logic [11:0] reversed_index;
           
           // Create Item
           response = FFT_sequence_item::type_id::create("response");

           // Load reference file on first active request
           if (!file_loaded) begin
               load_file();
           end

           // Handle active-low reset
           if (!request.rst_n) begin
               raw_count           = 0;
               read_index          = 0;
               response.valid_in   = request.valid_in;
               response.in_r       = request.in_r;
               response.in_i       = request.in_i;
               response.out_r      = 0;
               response.out_i      = 0;
               response.valid_out  = 0;
               response.frame_done = 0;
               response.out_index  = 0;
               return response;
           end

           // Pass-through inputs
           response.valid_in = request.valid_in;
           response.in_r     = request.in_r;
           response.in_i     = request.in_i;

           // Pass-through control outputs
           response.valid_out  = request.valid_out;
           response.frame_done = request.frame_done;

           // Compute out_index based on current raw_count (bit-reversal of 12-bit count)
           for (int i = 0; i < 12; i++) begin
               reversed_index[11 - i] = raw_count[i];
           end
           response.out_index = reversed_index;

           // Compute out_r and out_i
           if (request.valid_out) begin
               if (read_index < exp_out_r_q.size()) begin
                   response.out_r = exp_out_r_q[read_index];
                   response.out_i = exp_out_i_q[read_index];
                   read_index++;
               end else begin
                   `uvm_warning("REF_MODEL", "Read index exceeded available samples in queue. Wrapping to 0.")
                   read_index = 0;
                   if (exp_out_r_q.size() > 0) begin
                       response.out_r = exp_out_r_q[0];
                       response.out_i = exp_out_i_q[0];
                       read_index = 1;
                   end else begin
                       response.out_r = 0;
                       response.out_i = 0;
                   end
               end
               // Advance raw_count modulo 4096
               raw_count = (raw_count + 1) % 4096;
           end else begin
               response.out_r = 0;
               response.out_i = 0;
           end

           return response;
       endfunction
   endclass
endpackage