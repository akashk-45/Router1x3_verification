//------------------------------------------------------------------------------
// Title      : Environment Class
// Project    : UVM-Based Verification Environment
// Description: This class builds and connects the major components such as
//              agent tops, virtual sequencer, and scoreboard based on configuration.
//------------------------------------------------------------------------------

class env extends uvm_env;

  // Register the class with UVM factory
  `uvm_component_utils(env)

  //--------------------------------------------------------------------------
  // Member Variables
  //--------------------------------------------------------------------------

  // Handle to environment configuration object
  env_cfg e_cfg;

  // Scoreboard instance (optional)
  scoreboard sb;

  // Virtual sequencer instance (optional)
  v_seqr vseqr;

  // Top-level agent container for source agents
  s_agt_top s_top;

  // Top-level agent container for destination agents
  d_agt_top d_top;

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------

  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction

  //--------------------------------------------------------------------------
  // Build Phase
  //--------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the environment configuration from the config DB
    if (!uvm_config_db #(env_cfg)::get(this, "", "env_cfg", e_cfg))
      `uvm_fatal("ENV", "Can't get env_cfg")

    // Conditionally create scoreboard if enabled in configuration
    if (e_cfg.has_scoreboard)
      sb = scoreboard::type_id::create("sb", this);

    // Conditionally create virtual sequencer if enabled
    if (e_cfg.has_virtual_sequencer)
      vseqr = v_seqr::type_id::create("vseqr", this);

    // Create top modules for source and destination agents
    s_top = s_agt_top::type_id::create("s_top", this);
    d_top = d_agt_top::type_id::create("d_top", this);
  endfunction

  //--------------------------------------------------------------------------
  // Connect Phase
  //--------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect agent sequencers to virtual sequencer if enabled
    if (e_cfg.has_virtual_sequencer) begin
      foreach (vseqr.s_seqrh[i])
        vseqr.s_seqrh[i] = s_top.agenth[i].seqrh;

      foreach (vseqr.d_seqrh[i])
        vseqr.d_seqrh[i] = d_top.agenth[i].seqrh;
    end

    // Connect monitor analysis ports to scoreboard if enabled
    if (e_cfg.has_scoreboard) begin
      foreach (s_top.agenth[i])
        s_top.agenth[i].monh.monitor_port.connect(sb.fifo_src.analysis_export);

      foreach (d_top.agenth[i])
        d_top.agenth[i].monh.monitor_port.connect(sb.fifo_dest[i].analysis_export);
    end
  endfunction

endclass
