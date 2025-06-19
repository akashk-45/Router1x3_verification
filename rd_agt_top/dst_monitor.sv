//------------------------------------------------------------------------------
// Class: d_mon
// Description: This is the UVM monitor for observing the DUT interface. It
//              samples the DUT outputs using the virtual interface and sends
//              transactions to analysis components (e.g., scoreboard, coverage).
//------------------------------------------------------------------------------

class d_mon extends uvm_monitor;

  // Register the monitor with the UVM factory
  `uvm_component_utils(d_mon)

  // Configuration object handle (contains vif and mode settings)
  d_cfg cfg;

  // Virtual interface handle for monitoring DUT signals
  virtual router_if.DMON_MP vif;

  // Analysis port to send observed transactions to other components
  uvm_analysis_port #(d_trans) monitor_port;

  // Handle for the transaction being built during collection
  d_trans d_xtn;

  //------------------------------------------------------------------------------
  // Constructor: new
  // Initializes the monitor and its analysis port
  //------------------------------------------------------------------------------
  function new(string name = "d_mon", uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  //------------------------------------------------------------------------------
  // Function: build_phase
  // Retrieves the configuration object from the UVM config database
  //------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(d_cfg)::get(this, "", "d_cfg", cfg)) begin
      `uvm_fatal("DMON", "Can't get d_cfg from uvm_config_db")
    end
  endfunction

  //------------------------------------------------------------------------------
  // Function: connect_phase
  // Assigns the virtual interface from the configuration
  //------------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    vif = cfg.vif;
  endfunction

  //------------------------------------------------------------------------------
  // Task: run_phase
  // Continuously samples the DUT output and collects transactions
  //------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    forever begin
      collect_data();
    end
  endtask

  //------------------------------------------------------------------------------
  // Task: collect_data
  // Monitors the DUT signals and constructs a d_trans transaction object.
  // Once complete, the transaction is sent via the analysis port.
  //------------------------------------------------------------------------------
  task collect_data();
    // Create a new transaction object
    d_xtn = d_trans::type_id::create("d_xtn");

    // Wait for read enable and valid output to go high
    wait (vif.d_mon_cb.read_eb == 1 && vif.d_mon_cb.vld_out == 1);

    // First clock: capture header
    @(vif.d_mon_cb);
    d_xtn.header = vif.d_mon_cb.data_out;

    // Allocate payload array based on header bits [7:2] (indicates length)
    d_xtn.pl_data = new[d_xtn.header[7:2]];

    // Second clock: sync and prepare for payload
    @(vif.d_mon_cb);

    // Capture payload over subsequent clock cycles
    foreach (d_xtn.pl_data[i]) begin
      d_xtn.pl_data[i] = vif.d_mon_cb.data_out;
      @(vif.d_mon_cb);
    end

    // Capture parity value
    d_xtn.parity = vif.d_mon_cb.data_out;

    // Optionally print transaction for debugging
    `uvm_info("D_MON", $sformatf("Printing from dest monitor \n%s", d_xtn.sprint()), UVM_LOW)

    // Write the transaction to the analysis port
    monitor_port.write(d_xtn);
  endtask

endclass
