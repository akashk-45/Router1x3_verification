//----------------------------------------------------------------------------
// Source Agent Configuration (s_cfg)
// Stores configuration details for the source agent including interface handle,
// active/passive mode, and optional static counters.
//----------------------------------------------------------------------------

class s_cfg extends uvm_object;
  `uvm_object_utils(s_cfg)

  // Virtual interface handle for connecting to DUT
  virtual router_if vif;

  // Indicates if the agent is active or passive (default is ACTIVE)
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Static counters for driver and monitor (shared across all instances)
  static int drv_data_cnt; // Tracks how many transactions driver processed
  static int mon_data_cnt; // Tracks how many transactions monitor observed

  // Constructor
  function new(string name = "s_cfg");
    super.new(name);
  endfunction

endclass
