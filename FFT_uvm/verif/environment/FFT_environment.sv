package FFT_environment_pkg;

  import uvm_pkg::*;
  import FFT_virtual_sequencer_pkg::*;
  import FFT_agent_pkg::*;
  import FFT_predictor_pkg::*;
  import FFT_scoreboard_pkg::*;
  import FFT_coverage_pkg::*;   
  
  `include "uvm_macros.svh"

  class FFT_environment extends uvm_env;
     `uvm_component_utils(FFT_environment)
   
     // Create Objects
        FFT_agent              agent             ;
        FFT_virtual_sequencer  virtual_sequencer ;
        FFT_predictor          predictor         ;
        FFT_scoreboard         scoreboard        ;
        FFT_coverage           coverage          ; 

      //------------------------------------------------------------
      // Constructor
      //------------------------------------------------------------
      function new(string name = "FFT_environment", uvm_component parent = null);
       super.new(name,parent);    
      endfunction



      //------------------------------------------------------------
      // Build phase
      //------------------------------------------------------------
      function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent             =  FFT_agent::               type_id:: create("agent"              , this);
        virtual_sequencer =  FFT_virtual_sequencer::   type_id:: create("virtual_sequencer"  , this);
        predictor         =  FFT_predictor::           type_id:: create("predictor"          , this);
        scoreboard        =  FFT_scoreboard::          type_id:: create("scoreboard"         , this);
        coverage          =  FFT_coverage::            type_id:: create("coverage"           , this);
      endfunction

      //------------------------------------------------------------
      // Connect phase
      //------------------------------------------------------------
      function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // connect virtual sequencer to each agent sequencer
           virtual_sequencer.sequencer = agent.sequencer;
           
        // Predictor: Connect Monitor to Predictor
           agent.DUT_analysis_port.connect(predictor.analysis_export);

        // Scoreboard: Connect Monitor to Scoreboard (DUT/Actual)
           agent.DUT_analysis_port.connect(scoreboard.DUT_export);

        // Scoreboard: Connect Predictor to Scoreboard (REF/Expected)
           predictor.expected_port.connect(scoreboard.REF_export);

        // Coverage: connect Monitor to Coverage
           agent.DUT_analysis_port.connect(coverage.Seq_export  );
      endfunction
  endclass

endpackage

