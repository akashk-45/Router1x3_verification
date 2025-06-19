//------------------------------------------------------------------------------
// Title      : Environment Configuration Class
// Project    : UVM-Based Verification Environment
// Description: Stores configuration for environment-level components,
//              such as number of source/destination agents and flags for optional components.
//------------------------------------------------------------------------------

class env_cfg extends uvm_object;
  // Register this class with the UVM factory
  `uvm_object_utils(env_cfg)

  //--------------------------------------------------------------------------
  // Member Variables
  //--------------------------------------------------------------------------

  // Number of source agents in the environment
  int no_of_sagents;

  // Number of destination agents in the environment
  int no_of_dagents;

  // Flag to indicate if scoreboard is present in environment (0 = No, 1 = Yes)
  int has_scoreboard;

  // Flag to indicate if virtual sequencer is used (0 = No, 1 = Yes)
  int has_virtual_sequencer;

  // Configuration handles for each source agent
  s_cfg scfg[];

  // Configuration handles for each destination agent
  d_cfg dcfg[];

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------

  // Constructor - gives default name to this config object
  function new(string name = "env_cfg");
    super.new(name);
  endfunction

endclass
