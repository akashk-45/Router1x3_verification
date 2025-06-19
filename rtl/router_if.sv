interface router_if(input bit clock);
	
	//==========================================================================
	// Interface Signals
	//==========================================================================
	logic [7:0] data_in;     // Input data from source to router
	logic       pkt_vld;     // Packet valid signal from source
	logic       rstn;        // Active-low reset
	logic       error;       // Error signal (possibly for parity or framing error)
	logic       busy;        // Router busy signal (backpressure to source)
	logic       read_eb;     // Read enable from destination
	logic [7:0] data_out;    // Output data from router to destination
	logic       vld_out;     // Output data valid signal

	//==========================================================================
	// Clocking Blocks
	// Used for signal synchronization in UVM TBs
	//==========================================================================

	// Source Driver Clocking Block
	clocking s_drv_cb @(posedge clock);
		default input #1 output #1;
		input  busy;           // Monitor backpressure
		input  error;          // Error status for diagnostics
		output data_in;        // Drive data to DUT
		output pkt_vld;        // Indicate start/validity of packet
		output rstn;           // Reset control
	endclocking

	// Source Monitor Clocking Block
	clocking s_mon_cb @(posedge clock);
		default input #1 output #1;
		input data_in;         // Sample data being driven
		input pkt_vld;         // Sample packet validity
		input error;           // Sample error condition
		input busy;            // Sample busy signal
		input rstn;            // Sample reset
	endclocking

	// Destination Driver Clocking Block
	clocking d_drv_cb @(posedge clock);
		default input #1 output #1;
		input  vld_out;        // Sample valid output from router
		output read_eb;        // Drive read enable to router
	endclocking

	// Destination Monitor Clocking Block
	clocking d_mon_cb @(posedge clock);
		default input #1 output #1;
		input data_out;        // Sample output data from router
		input read_eb;         // Sample read enable
		input vld_out;         // Sample data valid signal
	endclocking

	//==========================================================================
	// Modports
	// Used to bind components (driver/monitor) to appropriate clocking blocks
	//==========================================================================

	modport SDRV_MP (clocking s_drv_cb);   // Source Driver Modport
	modport SMON_MP (clocking s_mon_cb);   // Source Monitor Modport
	modport DDRV_MP (clocking d_drv_cb);   // Destination Driver Modport
	modport DMON_MP (clocking d_mon_cb);   // Destination Monitor Modport

endinterface
