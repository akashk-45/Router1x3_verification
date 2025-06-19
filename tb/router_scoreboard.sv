//------------------------------------------------------------------------------
// Title      : Scoreboard
// Description: Compares source and destination transactions and collects coverage
//------------------------------------------------------------------------------

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  // Configuration object handle
  env_cfg e_cfg;

  // Transaction handles for analysis and coverage
  s_trans s_xtn;
  d_trans d_xtn;
  s_trans s_cov_data;
  d_trans d_cov_data;

  // TLM FIFOs
  uvm_tlm_analysis_fifo #(s_trans) fifo_src;
  uvm_tlm_analysis_fifo #(d_trans) fifo_dest[];

  // Address for comparison (optional usage)
  bit [1:0] address;

  // Coverage counters
  int data_verified_count;

  //--------------------------------------------------------------------------
  // Covergroups
  //--------------------------------------------------------------------------

  covergroup router_source;
    option.per_instance = 1;

    ADDR : coverpoint s_cov_data.header[1:0] {
      bins h0 = {2'b00};
      bins h1 = {2'b01};
      bins h2 = {2'b10};
    }

    PAYLOAD_SIZE : coverpoint s_cov_data.header[7:2] {
      bins small_pkt = {[1:20]};
      bins medium_pkt = {[21:40]};
      bins big_pkt = {[41:63]};
    }

    BAD_PKT : coverpoint s_cov_data.error {
      bins bad_pkt = {1'b1};
      bins good_pkt = {1'b0};
    }

    ADDR_PAYLOAD_SIZE : cross ADDR, PAYLOAD_SIZE;
    ADDR_PAYLOAD_SIZE_BAD_PKT : cross ADDR, PAYLOAD_SIZE, BAD_PKT;

  endgroup

  covergroup router_dest;
    option.per_instance = 1;

    ADDR : coverpoint d_cov_data.header[1:0] {
      bins h0 = {2'b00};
      bins h1 = {2'b01};
      bins h2 = {2'b10};
    }

    PAYLOAD_SIZE : coverpoint d_cov_data.header[7:2] {
      bins small_pkt = {[1:20]};
      bins medium_pkt = {[21:40]};
      bins big_pkt = {[41:63]};
    }

    ADDR_PAYLOAD_SIZE : cross ADDR, PAYLOAD_SIZE;

  endgroup

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------

  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    router_source = new();
    router_dest   = new();
  endfunction

  //--------------------------------------------------------------------------
  // Build Phase
  //--------------------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(env_cfg)::get(this, "", "env_cfg", e_cfg))
      `uvm_fatal("SCOREBOARD", "Cannot get env_cfg")

    fifo_src = new("fifo_src", this);
    fifo_dest = new[e_cfg.no_of_dagents];

    foreach (fifo_dest[i]) begin
      fifo_dest[i] = new($sformatf("fifo_dest[%0d]", i), this);
    end
  endfunction

  //--------------------------------------------------------------------------
  // Run Phase
  //--------------------------------------------------------------------------

  task run_phase(uvm_phase phase);
    forever begin
      fork
        begin
          fifo_src.get(s_xtn);
          s_cov_data = s_xtn;
          `uvm_info("SCOREBOARD_SRC", $sformatf("SOURCE:\n%s", s_xtn.sprint()), UVM_LOW)
          router_source.sample();
        end

        begin
          fork
            begin
              fifo_dest[0].get(d_xtn);
              d_cov_data = d_xtn;
              `uvm_info("SCOREBOARD_DEST0", $sformatf("DEST0:\n%s", d_xtn.sprint()), UVM_LOW)
              router_dest.sample();
            end
            begin
              fifo_dest[1].get(d_xtn);
              d_cov_data = d_xtn;
              `uvm_info("SCOREBOARD_DEST1", $sformatf("DEST1:\n%s", d_xtn.sprint()), UVM_LOW)
              router_dest.sample();
            end
            begin
              fifo_dest[2].get(d_xtn);
              d_cov_data = d_xtn;
              `uvm_info("SCOREBOARD_DEST2", $sformatf("DEST2:\n%s", d_xtn.sprint()), UVM_LOW)
              router_dest.sample();
            end
          join_any
          disable fork;
        end
      join

      compare(s_xtn, d_xtn);
    end
  endtask

  //--------------------------------------------------------------------------
  // Comparison Logic
  //--------------------------------------------------------------------------

  task compare(s_trans s_xtn, d_trans d_xtn);
    if (s_xtn.header == d_xtn.header)
      `uvm_info("SB_HEADER", "Header matches", UVM_LOW)
    else
      `uvm_error("SB_HEADER", "Header mismatch")

    if (s_xtn.pl_data == d_xtn.pl_data)
      `uvm_info("SB_PAYLOAD", "Payload matches", UVM_LOW)
    else
      `uvm_error("SB_PAYLOAD", "Payload mismatch")

    if (s_xtn.parity == d_xtn.parity)
      `uvm_info("SB_PARITY", "Parity matches", UVM_LOW)
    else
      `uvm_error("SB_PARITY", "Parity mismatch")

    data_verified_count++;
  endtask

endclass
