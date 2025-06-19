//------------------------------------------------------------------------------
// Source Driver (s_drv)
// Drives stimulus from source sequence to the DUT using virtual interface.
//------------------------------------------------------------------------------

class s_drv extends uvm_driver #(s_trans);
  `uvm_component_utils(s_drv)

  // Handle to source agent config
  s_cfg cfg;

  // Virtual interface for driving signals
  virtual router_if.SDRV_MP vif;

  // Constructor
  function new(string name = "s_drv", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Fetch the agent config
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(s_cfg)::get(this, "", "s_cfg", cfg))
      `uvm_fatal("SDRV", "can't get s_cfg!")
  endfunction

  // Connect phase: Assign virtual interface from config
  function void connect_phase(uvm_phase phase);
    vif = cfg.vif;
  endfunction

  // Run phase: Reset and drive sequence items to DUT
  task run_phase(uvm_phase phase);
    // Apply reset
    @(vif.s_drv_cb);
    vif.s_drv_cb.rstn <= 0;
    @(vif.s_drv_cb);
    vif.s_drv_cb.rstn <= 1;

    // Main driver loop
    forever begin
      // Get sequence item from sequencer
      seq_item_port.get_next_item(req);

      // Send it to DUT
      send_to_dut(req);

      // Indicate completion
      seq_item_port.item_done();
    end
  endtask

  // Task to drive a single transaction to the DUT
  task send_to_dut(s_trans s_xtn);
    `uvm_info("S_DRV", $sformatf("Printing from driver:\n%s", s_xtn.sprint()), UVM_LOW)

    // Wait for non-busy cycle
    @(vif.s_drv_cb);
    while (vif.s_drv_cb.busy)
      @(vif.s_drv_cb);

    // Send header and assert pkt_vld
    vif.s_drv_cb.pkt_vld <= 1;
    vif.s_drv_cb.data_in <= s_xtn.header;
    @(vif.s_drv_cb);

    // Send payload data
    foreach (s_xtn.pl_data[i]) begin
      while (vif.s_drv_cb.busy)
        @(vif.s_drv_cb);
      vif.s_drv_cb.data_in <= s_xtn.pl_data[i];
      @(vif.s_drv_cb);
    end

    // Wait if busy before sending parity
    while (vif.s_drv_cb.busy)
      @(vif.s_drv_cb);

    // Deassert pkt_vld and send parity
    vif.s_drv_cb.pkt_vld <= 0;
    vif.s_drv_cb.data_in <= s_xtn.parity;

    // Wait 2 cycles after sending
    repeat (2)
      @(vif.s_drv_cb);

    // Capture error signal from DUT
    s_xtn.error = vif.s_drv_cb.error;

    // Increment driver's transaction count
    cfg.drv_data_cnt++;
  endtask

endclass
