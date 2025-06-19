//------------------------------------------------------------------------------
// Class: d_cfg
// Description: Configuration object for the data agent (d_agent). 
//              It stores interface handles and active/passive mode settings.
//------------------------------------------------------------------------------

class d_cfg extends uvm_object;

  // Register the object with the factory
  `uvm_object_utils(d_cfg)

  // Virtual interface handle to connect DUT interface with driver/monitor
  virtual router_if vif;

  // Enum to specify whether the agent is active or passive
  // UVM_ACTIVE: agent has driver + sequencer + monitor
  // UVM_PASSIVE: agent has only monitor
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  //------------------------------------------------------------------------------
  // Constructor: new
  // Initializes the configuration object with a given name
  //------------------------------------------------------------------------------
  function new(string name = "d_cfg");
    super.new(name);
  endfunction

endclass
