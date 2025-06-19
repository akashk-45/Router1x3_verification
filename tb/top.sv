`timescale 1ns/1ps

module top;
  
  // Import UVM and user-defined package
  import router_pkg::*;
  import uvm_pkg::*;

  // Clock declaration
  bit clock;

  // Clock generation: 50 MHz (period = 20ns)
  always #10 clock = !clock;

  // Interface instances for DUT connection
  router_if in(clock);   // Source interface
  router_if in0(clock);  // Destination 0 interface
  router_if in1(clock);  // Destination 1 interface
  router_if in2(clock);  // Destination 2 interface

  // DUT instantiation with mapped ports
  top_module DUV (
    .clk(clock),
    .rstn(in.rstn),
    .pkt_vd(in.pkt_vld),
    .re0(in0.read_eb),
    .re1(in1.read_eb),
    .re2(in2.read_eb),
    .din(in.data_in),
    .vo0(in0.vld_out),
    .vo1(in1.vld_out),
    .vo2(in2.vld_out),
    .busy(in.busy),
    .error(in.error),
    .dout0(in0.data_out),
    .dout1(in1.data_out),
    .dout2(in2.data_out)
  );

  // Initial block to start the simulation
  initial begin
    `ifdef VCS
      $fsdbDumpvars(0, top); // For waveform dump
    `endif

    // Setting virtual interfaces via UVM config DB
    uvm_config_db#(virtual router_if)::set(null, "*", "vif",   in);
    uvm_config_db#(virtual router_if)::set(null, "*", "vif_0", in0);
    uvm_config_db#(virtual router_if)::set(null, "*", "vif_1", in1);
    uvm_config_db#(virtual router_if)::set(null, "*", "vif_2", in2);

    run_test(); // Start UVM test
  end

  //------------------------------------------
  // SystemVerilog Assertions and Coverage
  //------------------------------------------

  // Assertion: If busy is high, input data must remain stable
  property stable_data;
    @(posedge clock) in.busy |=> $stable(in.data_in);
  endproperty

  // Assertion: On pkt_vld rising edge, busy should be high next cycle
  property busy_check;
    @(posedge clock) $rose(in.pkt_vld) |=> in.busy;
  endproperty

  // Assertion: After pkt_vld rises, some output valid signal should rise within 3 cycles
  property valid_signal;
    @(posedge clock) $rose(in.pkt_vld) |-> ##3 (in0.vld_out || in1.vld_out || in2.vld_out);
  endproperty

  // Assertions: Read enable should occur 1–29 cycles after vld_out is asserted
  property rd_enb0;
    @(posedge clock) in0.vld_out |-> ##[1:29] in0.read_eb;
  endproperty

  property rd_enb1;
    @(posedge clock) in1.vld_out |-> ##[1:29] in1.read_eb;
  endproperty

  property rd_enb2;
    @(posedge clock) in2.vld_out |-> ##[1:29] in2.read_eb;
  endproperty

  // Assertions: When vld_out falls, read enable must fall too
  property rd_enb0_low;
    @(posedge clock) $fell(in0.vld_out) |=> $fell(in0.read_eb);
  endproperty

  property rd_enb1_low;
    @(posedge clock) $fell(in1.vld_out) |=> $fell(in1.read_eb);
  endproperty

  property rd_enb2_low;
    @(posedge clock) $fell(in2.vld_out) |=> $fell(in2.read_eb);
  endproperty

  // Assertions and Coverage Mapping

  A1: assert property(stable_data)
        $display("Assertion passed: stable data during busy");
      else
        $display("Assertion failed: data not stable during busy");
  C1: cover property(stable_data);

  A2: assert property(busy_check)
        $display("Assertion passed: busy raised after pkt_vld");
      else
        $display("Assertion failed: busy not raised after pkt_vld");
  C2: cover property(busy_check);

  A3: assert property(valid_signal)
        $display("Assertion passed: valid output seen after pkt_vld");
      else
        $display("Assertion failed: no valid output after pkt_vld");
  C3: cover property(valid_signal);

  A4: assert property(rd_enb0)
        $display("Assertion passed: read enable 0 timing OK");
      else
        $display("Assertion failed: read enable 0 timing error");
  C4: cover property(rd_enb0);

  A5: assert property(rd_enb1)
        $display("Assertion passed: read enable 1 timing OK");
      else
        $display("Assertion failed: read enable 1 timing error");
  C5: cover property(rd_enb1);

  A6: assert property(rd_enb2)
        $display("Assertion passed: read enable 2 timing OK");
      else
        $display("Assertion failed: read enable 2 timing error");
  C6: cover property(rd_enb2);

  A7: assert property(rd_enb0_low)
        $display("Assertion passed: read enable 0 deasserted after vld_out0 low");
      else
        $display("Assertion failed: read enable 0 stuck after vld_out0 low");
  C7: cover property(rd_enb0_low);

  A8: assert property(rd_enb1_low)
        $display("Assertion passed: read enable 1 deasserted after vld_out1 low");
      else
        $display("Assertion failed: read enable 1 stuck after vld_out1 low");
  C8: cover property(rd_enb1_low);

  A9: assert property(rd_enb2_low)
        $display("Assertion passed: read enable 2 deasserted after vld_out2 low");
      else
        $display("Assertion failed: read enable 2 stuck after vld_out2 low");
  C9: cover property(rd_enb2_low);

endmodule
