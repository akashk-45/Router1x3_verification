// Virtual sequencer class to coordinate source and destination sequencers
class v_seqr extends uvm_sequencer #(uvm_sequence_item);
  `uvm_component_utils(v_seqr)

  // Arrays to hold handles for all source and destination sequencers
  s_seqr s_seqrh[];       // Source sequencer handles array
  d_seqr d_seqrh[];       // Destination sequencer handles array

  // Environment configuration handle
  env_cfg e_cfg;

  // Constructor
  function new(string name = "v_seqr", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Get environment config and initialize sequencer arrays
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the environment configuration from config DB
    if (!uvm_config_db #(env_cfg)::get(this, "", "env_cfg", e_cfg))
      `uvm_fatal("VSEQR", "Can't get env_cfg!!")

    // Allocate arrays based on the number of agents from env_cfg
    s_seqrh = new[e_cfg.no_of_sagents];
    d_seqrh = new[e_cfg.no_of_dagents];
  endfunction

endclass
