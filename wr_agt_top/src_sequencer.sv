//------------------------------------------------------------------------------
// Source Sequencer
// Handles sequencing of source transactions (s_trans)
//------------------------------------------------------------------------------

class s_seqr extends uvm_sequencer #(s_trans);
  `uvm_component_utils(s_seqr)

  // Constructor
  function new(string name = "s_seqr", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
