//------------------------------------------------------------------------------
// Source Transaction Class: s_trans
// Represents a packet with header, payload data, parity, and error flag
//------------------------------------------------------------------------------

class s_trans extends uvm_sequence_item;
  `uvm_object_utils(s_trans)

  //--------------------------------------------------------------------------
  // Properties
  //--------------------------------------------------------------------------
  rand bit [7:0] header;       // 8-bit header: upper 6 bits = payload size, lower 2 bits = address
  rand bit [7:0] pl_data[];    // Dynamic payload array (size determined by header[7:2])
       bit [7:0] parity;       // Computed parity (header ⊕ all payload)
       bit       error;        // Error flag set by DUT

  //--------------------------------------------------------------------------
  // Constraints
  //--------------------------------------------------------------------------
  constraint c1 { pl_data.size == header[7:2]; }   // Payload size matches header[7:2]
  constraint c2 { header[7:2] != 0; }              // Non-zero payload length
  constraint c3 { header[1:0] != 3; }              // Invalid address 3 is excluded
  //constraint c4 { header[1:2] inside {0,1,2}; }   // Optional: allow only addresses 0,1,2

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------
  function new(string name = "s_trans");
    super.new(name);
  endfunction

  //--------------------------------------------------------------------------
  // Custom Print for Debugging
  //--------------------------------------------------------------------------
  function void do_print (uvm_printer printer);
    printer.print_field("header", this.header, 8, UVM_BIN);
    foreach (pl_data[i])
      printer.print_field($sformatf("pl_data[%0d]", i), pl_data[i], 8, UVM_HEX);
    printer.print_field("parity", this.parity, 8, UVM_HEX);
  endfunction

  //--------------------------------------------------------------------------
  // Post-Randomize Hook to Calculate Parity
  //--------------------------------------------------------------------------
  function void post_randomize();
    parity = 0 ^ header;
    foreach (pl_data[i])
      parity = parity ^ pl_data[i];
  endfunction

endclass
