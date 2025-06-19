//------------------------------------------------------------------------------
// Source Agent Top (s_agt_top)
// This environment-level component manages an array of source agents.
// It uses the environment configuration to create and configure each agent.
//------------------------------------------------------------------------------

class s_agt_top extends uvm_env;
  `uvm_component_utils(s_agt_top)

  // Array of source agents
  s_agent agenth[];

  // Handle to environment-level configuration object
  env_cfg e_cfg;

  // Constructor
  function new(string name = "s_agt_top", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Creates all source agents and sets their configuration
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the environment configuration from the config DB
    if (!uvm_config_db #(env_cfg)::get(this, "", "env_cfg", e_cfg))
      `uvm_fatal("SAGT_TOP", "Can't get e_cfg!")

    // Allocate and create the specified number of source agents
    agenth = new[e_cfg.no_of_sagents];

    foreach (agenth[i]) begin
      // Create each source agent
      agenth[i] = s_agent::type_id::create($sformatf("agenth[%0d]", i), this);

      // Set individual source config for each agent using wildcard match
      uvm_config_db #(s_cfg)::set(
        this, 
        $sformatf("agenth[%0d]*", i), 
        "s_cfg", 
        e_cfg.scfg[i]
      );
    end
  endfunction

endclass
