//------------------------------------------------------------------------------
// Class: d_agt_top
// Description: This class is the top-level environment for managing an array 
//              of data agents (d_agent). It uses an environment configuration
//              object (env_cfg) to configure multiple instances of d_agent.
//------------------------------------------------------------------------------

class d_agt_top extends uvm_env;

  // Register the environment with the factory
  `uvm_component_utils(d_agt_top)

  // Array of handles to data agents
  d_agent agenth[];

  // Handle to environment-level configuration
  env_cfg e_cfg;

  // Array of individual agent configuration objects
  d_cfg dcfg[];

  //------------------------------------------------------------------------------
  // Constructor: new
  // Initializes the d_agt_top component with a given name and parent
  //------------------------------------------------------------------------------
  function new(string name = "d_agt_top", uvm_component parent);
    super.new(name, parent);
  endfunction

  //------------------------------------------------------------------------------
  // Function: build_phase
  // Purpose: Build multiple instances of d_agent using env_cfg and set
  //          their respective configurations.
  //------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve environment configuration object from config DB
    if (!uvm_config_db #(env_cfg)::get(this, "", "env_cfg", e_cfg)) begin
      `uvm_fatal("DAGT_TOP", "Can't get env_cfg from uvm_config_db")
    end

    // Dynamically allocate the agent array based on number of agents specified
    agenth = new[e_cfg.no_of_dagents];

    // Loop through and create each agent, set individual config for each
    foreach (agenth[i]) begin
      // Factory create each agent instance
      agenth[i] = d_agent::type_id::create($sformatf("agenth[%0d]", i), this);

      // Set d_cfg for each agent instance using config DB
      uvm_config_db #(d_cfg)::set(
        this,
        $sformatf("agenth[%0d]*", i),
        "d_cfg",
        e_cfg.dcfg[i]
      );
    end
  endfunction

endclass
