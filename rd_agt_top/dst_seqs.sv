//------------------------------------------------------------------------------
// Class: d_seqs
// Description: Base sequence class for sequences that generate d_trans items.
//------------------------------------------------------------------------------
class d_seqs extends uvm_sequence #(d_trans);

  // Register with factory
  `uvm_object_utils(d_seqs)

  // Constructor
  function new(string name = "d_seqs");
    super.new(name);
  endfunction

endclass

//------------------------------------------------------------------------------
// Class: d_seq1
// Description: A simple sequence that generates one randomized d_trans item
//              with a delay less than 29.
//------------------------------------------------------------------------------
class d_seq1 extends d_seqs;

  // Register with factory
  `uvm_object_utils(d_seq1)

  // Constructor
  function new(string name = "d_seq1");
    super.new(name);
  endfunction

  // Task: body
  // Core of the sequence where the transaction is generated and randomized
  task body();
    // Create and start transaction
    req = d_trans::type_id::create("req");

    // Start interaction with sequencer
    start_item(req);

    // Apply constraint: delay must be less than 29
    assert(req.randomize() with { delay < 29; });

    // End interaction with sequencer
    finish_item(req);
  endtask

endclass

//------------------------------------------------------------------------------
// Class: sft_rst_seq
// Description: A soft reset sequence that generates one d_trans with delay > 30.
//              Inherits from d_seq1 to reuse structure.
//------------------------------------------------------------------------------
class sft_rst_seq extends d_seq1;

  // Register with factory
  `uvm_object_utils(sft_rst_seq)

  // Constructor
  function new(string name = "sft_rst_seq");
    super.new(name);
  endfunction

  // Override Task: body
  // Applies a different constraint: delay must be greater than 30
  task body();
    // Create and start transaction
    req = d_trans::type_id::create("req");

    // Start interaction with sequencer
    start_item(req);

    // Apply constraint: delay must be greater than 30
    assert(req.randomize() with { delay > 30; });

    // End interaction with sequencer
    finish_item(req);
  endtask

endclass
