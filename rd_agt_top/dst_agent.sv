//------------------------------------------------------------------------------
// Class: d_agent
// Description: This is a UVM agent class that encapsulates the driver,
//              sequencer, and monitor. It can be configured as either 
//              active (contains driver and sequencer) or passive (monitor only).
//------------------------------------------------------------------------------

class d_agent extends uvm_agent;

  // Register the component with the factory
  `uvm_component_utils(d_agent)
  
  // Configuration object handle
  d_cfg cfg;

  // Handles for driver, monitor, and sequencer components
  d_drv   drvh;
  d_mon   monh;
  d_seqr  seqrh;

  //------------------------------------------------------------------------------
  // Constructor: new
  // Initializes the agent with a given name and parent
  //------------------------------------------------------------------------------
  function new(string name = "d_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  //------------------------------------------------------------------------------
  // Function: build_phase
  // Purpose: Build and configure all agent sub-components based on the config
  //------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve configuration object from config DB
    if (!uvm_config_db #(d_cfg)::get(this, "", "d_cfg", cfg)) begin
      `uvm_fatal("D_AGENT", "Can't get d_cfg from uvm_config_db")
    end

    // Create monitor - always present regardless of agent activity
    monh = d_mon::type_id::create("monh", this);

    // Create driver and sequencer only if agent is active
    if (cfg.is_active == UVM_ACTIVE) begin
      drvh  = d_drv::type_id::create("drvh", this);
      seqrh = d_seqr::type_id::create("seqrh", this);
    end
  endfunction

  //------------------------------------------------------------------------------
  // Function: connect_phase
  // Purpose: Connects driver’s seq_item_port to the sequencer’s seq_item_export
  //------------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    if (cfg.is_active == UVM_ACTIVE) begin
      drvh.seq_item_port.connect(seqrh.seq_item_export);
    end
  endfunction

endclass
