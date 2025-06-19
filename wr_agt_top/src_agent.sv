//----------------------------------------------------------------------------
// Source Agent (s_agent)
// This class defines the UVM active/passive agent structure for the source side.
// It includes driver, monitor, and sequencer based on configuration.
//----------------------------------------------------------------------------

class s_agent extends uvm_agent;
  `uvm_component_utils(s_agent)

  // Configuration handle for source agent
  s_cfg cfg;

  // Component handles
  s_drv  drvh;    // Driver
  s_mon  monh;    // Monitor
  s_seqr seqrh;   // Sequencer

  // Constructor
  function new(string name = "s_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Instantiate sub-components based on configuration
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get configuration from uvm_config_db
    if (!uvm_config_db #(s_cfg)::get(this, "", "s_cfg", cfg))
      `uvm_fatal("S_AGENT", "Can't get s_cfg!")

    // Always create the monitor (both active and passive modes)
    monh = s_mon::type_id::create("monh", this);

    // Create driver and sequencer only if agent is active
    if (cfg.is_active == UVM_ACTIVE) begin
      drvh  = s_drv::type_id::create("drvh", this);
      seqrh = s_seqr::type_id::create("seqrh", this);
    end
  endfunction

  // Connect phase: Connect driver to sequencer in active mode
  function void connect_phase(uvm_phase phase);
    if (cfg.is_active == UVM_ACTIVE) begin
      drvh.seq_item_port.connect(seqrh.seq_item_export);
    end
  endfunction

endclass
