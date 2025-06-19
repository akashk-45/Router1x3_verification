//------------------------------------------------------------------------------
// Class: d_seqr
// Description: Sequencer for driving d_trans sequence items to the driver.
//              It acts as the communication bridge between sequence and driver.
//------------------------------------------------------------------------------

class d_seqr extends uvm_sequencer #(d_trans);

  // Register the sequencer with the factory
  `uvm_component_utils(d_seqr)

  //------------------------------------------------------------------------------
  // Constructor: new
  // Initializes the sequencer with a name and parent component
  //------------------------------------------------------------------------------
  function new(string name = "d_seqr", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
