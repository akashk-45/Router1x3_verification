//------------------------------------------------------------------------------
// Base test for router environment with env_cfg, agents, scoreboard, etc.
//------------------------------------------------------------------------------
class router_test extends uvm_test;
  `uvm_component_utils(router_test)

  env_cfg e_cfg;
  s_cfg scfg[];    // Source agent configs
  d_cfg dcfg[];    // Destination agent configs

  // Test-level configuration
  int no_of_sagents = 1;
  int no_of_dagents = 3;
  int has_scoreboard = 1;
  int has_virtual_sequencer = 1;

  env envh;

  function new(string name = "router_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create and initialize configurations
    scfg = new[no_of_sagents];
    dcfg = new[no_of_dagents];
    e_cfg = env_cfg::type_id::create("e_cfg");
    e_cfg.scfg = new[no_of_sagents];
    e_cfg.dcfg = new[no_of_dagents];

    // Source agent config setup
    foreach (scfg[i]) begin
      scfg[i] = s_cfg::type_id::create($sformatf("scfg[%0d]", i));
      if (!uvm_config_db #(virtual router_if)::get(this, "", "vif", scfg[i].vif))
        `uvm_fatal("TEST", "Can't find vif");
      scfg[i].is_active = UVM_ACTIVE;
      e_cfg.scfg[i] = scfg[i];
    end

    // Destination agent config setup
    foreach (dcfg[i]) begin
      dcfg[i] = d_cfg::type_id::create($sformatf("dcfg[%0d]", i));
      if (!uvm_config_db #(virtual router_if)::get(this, "", $sformatf("vif_%0d", i), dcfg[i].vif))
        `uvm_fatal("TEST", "Can't find vif_%0d", i);
      dcfg[i].is_active = UVM_ACTIVE;
      e_cfg.dcfg[i] = dcfg[i];
    end

    // Set test-wide config parameters
    e_cfg.no_of_sagents = no_of_sagents;
    e_cfg.no_of_dagents = no_of_dagents;
    e_cfg.has_scoreboard = has_scoreboard;
    e_cfg.has_virtual_sequencer = has_virtual_sequencer;

    // Share env_cfg across environment
    uvm_config_db #(env_cfg)::set(this, "*", "env_cfg", e_cfg);

    // Create environment
    envh = env::type_id::create("envh", this);
  endfunction

  // Print the UVM topology for debug visibility
  task run_phase(uvm_phase phase);
    uvm_top.print_topology();
  endtask
endclass

class small_pkt_test extends router_test;
  `uvm_component_utils(small_pkt_test)

  s_vseq vseq;
  bit [1:0] address;

  function new(string name = "small_pkt_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Randomly pick destination address (0 to 2)
    address = $random % 3;
    uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", address);

    // Create and start virtual sequence
    vseq = s_vseq::type_id::create("vseq");
    vseq.start(envh.vseqr);

    #100;
    phase.drop_objection(this);
  endtask
endclass

class med_pkt_test extends router_test;
  `uvm_component_utils(med_pkt_test)

  m_vseq vseq;
  bit [1:0] address;

  function new(string name = "med_pkt_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    address = $random % 3;
    uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", address);

    vseq = m_vseq::type_id::create("vseq");
    vseq.start(envh.vseqr);

    #100;
    phase.drop_objection(this);
  endtask
endclass

class big_pkt_test extends router_test;
  `uvm_component_utils(big_pkt_test)

  b_vseq vseq;
  bit [1:0] address;

  function new(string name = "big_pkt_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    address = $random % 3;
    uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", address);

    vseq = b_vseq::type_id::create("vseq");
    vseq.start(envh.vseqr);

    #100;
    phase.drop_objection(this);
  endtask
endclass




