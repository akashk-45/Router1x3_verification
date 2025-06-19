//------------------------------------------------------------------------------
// Source Monitor (s_mon)
// Observes transactions at the DUT input and broadcasts them via analysis port
//------------------------------------------------------------------------------

class s_mon extends uvm_monitor;
  `uvm_component_utils(s_mon)

  // Configuration handle
  s_cfg cfg;

  // Virtual interface for monitor
  virtual router_if.SMON_MP vif;

  // Analysis port to send observed transactions
  uvm_analysis_port #(s_trans) monitor_port;

  // Constructor
  function new(string name = "s_mon", uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  // Build phase: get configuration
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(s_cfg)::get(this, "", "s_cfg", cfg))
      `uvm_fatal("SMON", "Can't get s_cfg!")
  endfunction

  // Connect phase: connect virtual interface
  function void connect_phase(uvm_phase phase);
    vif = cfg.vif;
  endfunction

  // Run phase: keep collecting packets from DUT
  task run_phase(uvm_phase phase);
    forever
      collect_data();
  endtask

  // Task to capture one transaction from the interface
  task collect_data();
    s_trans s_xtn;

    s_xtn = s_trans::type_id::create("s_xtn");

    // Wait until a valid packet starts (busy low and pkt_vld high)
    @(vif.s_mon_cb);
    wait(vif.s_mon_cb.busy == 0 && vif.s_mon_cb.pkt_vld == 1)

    // Capture header
    s_xtn.header = vif.s_mon_cb.data_in;

    // Extract payload length from header and allocate memory
    s_xtn.pl_data = new[s_xtn.header[7:2]];

    @(vif.s_mon_cb);

    // Capture payload
    foreach (s_xtn.pl_data[i]) begin
      while (vif.s_mon_cb.busy)
        @(vif.s_mon_cb);
      s_xtn.pl_data[i] = vif.s_mon_cb.data_in;
      @(vif.s_mon_cb);
    end

    // Wait until busy goes low
    while (vif.s_mon_cb.busy)
      @(vif.s_mon_cb);

    // Wait until pkt_vld goes low (end of packet)
    while (vif.s_mon_cb.pkt_vld)
      @(vif.s_mon_cb);

    // Read parity
    s_xtn.parity = vif.s_mon_cb.data_in;

    // Wait for DUT stabilization
    repeat (2)
      @(vif.s_mon_cb);

    // Sample error signal
    s_xtn.error = vif.s_mon_cb.error;

    // Increment monitored transaction count
    cfg.mon_data_cnt++;

    // Print and broadcast the transaction
    `uvm_info("S_MON", $sformatf("Printing from source monitor:\n%s", s_xtn.sprint()), UVM_LOW)
    monitor_port.write(s_xtn);
  endtask

endclass
