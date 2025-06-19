package router_pkg;

  import uvm_pkg::*;                 // Import UVM base library
  `include "uvm_macros.svh"         // Include UVM macros (e.g., `uvm_info, `uvm_error)

  //----------------------------
  // Configuration Classes
  //----------------------------
  `include "src_agent_config.sv"    // Source agent configuration (s_cfg)
  `include "dst_agent_config.sv"    // Destination agent configuration (d_cfg)
  `include "env_config.sv"          // Environment-level configuration (env_cfg)

  //----------------------------
  // Source Agent Components
  //----------------------------
  `include "src_xtns.sv"            // Source transaction (s_trans)
  `include "src_driver.sv"          // Source driver (s_drv)
  `include "src_monitor.sv"         // Source monitor (s_mon)
  `include "src_sequencer.sv"       // Source sequencer (s_seqr)
  `include "src_agent.sv"           // Source agent (s_agent)
  `include "src_agt_top.sv"         // Source agent top (s_agt_top)
  `include "src_seqs.sv"            // Source sequences (small_pkt, med_pkt, big_pkt)

  //----------------------------
  // Destination Agent Components
  //----------------------------
  `include "dst_xtns.sv"            // Destination transaction (d_trans)
  `include "dst_driver.sv"          // Destination driver (d_drv)
  `include "dst_monitor.sv"         // Destination monitor (d_mon)
  `include "dst_sequencer.sv"       // Destination sequencer (d_seqr)
  `include "dst_agent.sv"           // Destination agent (d_agent)
  `include "dst_agt_top.sv"         // Destination agent top (d_agt_top)
  `include "dst_seqs.sv"            // Destination sequences (d_seq1, reset_seq, etc.)

  //----------------------------
  // Virtual Sequencer & Sequences
  //----------------------------
  `include "virtual_sequencer.sv"   // Virtual sequencer (v_seqr)
  `include "virtual_sequence.sv"    // Virtual sequences (s_vseq, m_vseq, b_vseq)

  //----------------------------
  // Scoreboard
  //----------------------------
  `include "router_scoreboard.sv"   // Scoreboard to compare source vs dest

  //----------------------------
  // Environment & Base Test
  //----------------------------
  `include "router_env.sv"          // Top environment class (env)
  `include "base_test.sv"           // Base test and derived tests (router_test, small_pkt_test, etc.)

endpackage
