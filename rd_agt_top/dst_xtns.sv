//------------------------------------------------------------------------------
// Class: d_trans
// Description: Sequence item used by the driver and monitor. Represents a 
//              single data transaction with header, payload, parity, and delay.
//------------------------------------------------------------------------------

class d_trans extends uvm_sequence_item;

  // Register this class with the UVM factory
  `uvm_object_utils(d_trans)

  //--------------------------------------------------------------------------
  // Properties (transaction fields)
  //--------------------------------------------------------------------------

  // Header byte (8-bit), often used to encode packet info like payload length
  bit [7:0] header;

  // Dynamic array of payload data bytes (each 8-bit)
  bit [7:0] pl_data[];

  // Parity byte
  bit [7:0] parity;

  // Optional signal fields for observation/debug (not typically used in driver)
  bit read_eb, vld_out;

  // Randomizable delay to add variability in driving behavior
  rand bit [5:0] delay;

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------
  function new(string name = "d_trans");
    super.new(name);
  endfunction

  //--------------------------------------------------------------------------
  // Function: do_print
  // Custom print function to visualize the transaction in UVM reports
  //--------------------------------------------------------------------------
  function void do_print(uvm_printer printer);

    // Print header in binary format
    printer.print_field("header", this.header, 8, UVM_BIN);

    // Print each payload byte in hexadecimal
    foreach (pl_data[i])
      printer.print_field($sformatf("pl_data[%0d]", i), this.pl_data[i], 8, UVM_HEX);

    // Print parity in hexadecimal
    printer.print_field("parity", this.parity, 8, UVM_HEX);

    // Optional signal debug printing — uncomment if needed
    /*
    printer.print_field("read_eb", this.read_eb, 1, UVM_BIN);
    printer.print_field("vld_out", this.vld_out, 1, UVM_BIN);
    */
    
  endfunction

endclass
