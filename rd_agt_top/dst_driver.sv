//------------------------------------------------------------------------------
// Class: d_drv
// Description: This is the driver class responsible for driving transactions
//              onto the DUT interface using the virtual interface. It gets
//              sequence items from the sequencer and drives the DUT accordingly.
//------------------------------------------------------------------------------

class d_drv extends uvm_driver #(d_trans);

  // Register this component with the UVM factory
  `uvm_component_utils(d_drv)

  // Configuration object handle (contains vif and other parameters)
  d_cfg cfg;

  // Virtual interface specific to this driver
  virtual router_if.DDRV_MP vif;

  //------------------------------------------------------------------------------
  // Constructor: new
  //------------------------------------------------------------------------------
  function new(string name = "d_drv", uvm_component parent);
    super.new(name, parent);
  endfunction

  //------------------------------------------------------------------------------
  // Function: build_phase
  // Retrieves the configuration object from the config DB
  //------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(d_cfg)::get(this, "", "d_cfg", cfg)) begin
      `uvm_fatal("DDRV", "Can't get d_cfg from uvm_config_db")
    end
  endfunction

  //------------------------------------------------------------------------------
  // Function: connect_phase
  // Gets the virtual interface from the configuration
  //------------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    vif = cfg.vif;
  endfunction

  //------------------------------------------------------------------------------
  // Task: run_phase
  // Repeatedly receives transaction from sequencer, drives it to DUT, and notifies completion
  //------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    forever begin
      // Get the next transaction from the sequencer
      seq_item_port.get_next_item(req);

      // Call task to drive the transaction to DUT
      send_to_dut(req);

      // Notify sequencer that the transaction is done
      seq_item_port.item_done();
    end
  endtask

  //------------------------------------------------------------------------------
  // Task: send_to_dut
  // Drives the transaction onto DUT signals using the interface
  //------------------------------------------------------------------------------
  task send_to_dut(d_trans d_xtn);
    // Optionally print transaction details for debugging
    // `uvm_info("D_DRV", $sformatf("Printing from driver \n%s", d_xtn.sprint()), UVM_LOW)

    // Wait for clocking block edge
    @(vif.d_drv_cb);

    // Wait until DUT is ready (valid signal is high)
    wait (vif.d_drv_cb.vld_out == 1);

    // Delay driving based on the transaction field
    repeat (d_xtn.delay)
      @(vif.d_drv_cb);

    // Start driving read enable signal
    vif.d_drv_cb.read_eb <= 1'b1;

    // Wait one clock cycle
    @(vif.d_drv_cb);

    // Wait until DUT deasserts vld_out
    wait (vif.d_drv_cb.vld_out == 0);

    // Deassert read enable
    vif.d_drv_cb.read_eb <= 1'b0;

    // Final synchronization
    @(vif.d_drv_cb);
  endtask

endclass
