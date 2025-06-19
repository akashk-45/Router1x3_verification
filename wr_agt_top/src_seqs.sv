//------------------------------------------------------------------------------
// Base sequence for source agent
//------------------------------------------------------------------------------
class s_seqs extends uvm_sequence #(s_trans);
  `uvm_object_utils(s_seqs)

  // Constructor
  function new(string name = "s_seqs");
    super.new(name);
  endfunction

endclass


//------------------------------------------------------------------------------
// Small packet sequence
// Payload size: header[7:2] between 1 to 20
// Destination address: passed via config DB
//------------------------------------------------------------------------------
class small_pkt extends s_seqs;
  `uvm_object_utils(small_pkt)

  bit [1:0] address;

  function new(string name = "small_pkt");
    super.new(name);
  endfunction

  task body();
    // Get destination address from config DB
    if (!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "bit[1:0]", address))
      `uvm_fatal("S_SEQS", "Can't get address")

    // Create and send one randomized transaction
    req = s_trans::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      header[7:2] inside {[1:20]};
      header[1:0] == address;
    });
    `uvm_info("S_SEQ", $sformatf("Printing from small_pkt sequence:\n%s", req.sprint()), UVM_HIGH)
    finish_item(req);
  endtask
endclass


//------------------------------------------------------------------------------
// Medium packet sequence
// Payload size: header[7:2] between 21 to 40
// Destination address: passed via config DB
//------------------------------------------------------------------------------
class medium_pkt extends s_seqs;
  `uvm_object_utils(medium_pkt)

  bit [1:0] address;

  function new(string name = "medium_pkt");
    super.new(name);
  endfunction

  task body();
    // Get destination address from config DB
    if (!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "bit[1:0]", address))
      `uvm_fatal("S_SEQS", "Can't get address")

    // Create and send one randomized transaction
    req = s_trans::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      header[7:2] inside {[21:40]};
      header[1:0] == address;
    });
    `uvm_info("S_SEQ", $sformatf("Printing from medium_pkt sequence:\n%s", req.sprint()), UVM_HIGH)
    finish_item(req);
  endtask
endclass


//------------------------------------------------------------------------------
// Big packet sequence
// Payload size: header[7:2] between 41 to 63
// Destination address: passed via config DB
//------------------------------------------------------------------------------
class big_pkt extends s_seqs;
  `uvm_object_utils(big_pkt)

  bit [1:0] address;

  function new(string name = "big_pkt");
    super.new(name);
  endfunction

  task body();
    // Get destination address from config DB
    if (!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "bit[1:0]", address))
      `uvm_fatal("S_SEQ", "Can't get address")

    // Create and send one randomized transaction
    req = s_trans::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      header[7:2] inside {[41:63]};
      header[1:0] == address;
    });
    `uvm_info("S_SEQ", $sformatf("Printing from big_pkt sequence:\n%s", req.sprint()), UVM_HIGH)
    finish_item(req);
  endtask
endclass
