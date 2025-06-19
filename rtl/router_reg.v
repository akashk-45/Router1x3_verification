`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:25:02 09/29/2024 
// Design Name:    Packet Register for Router
// Module Name:    register 
// Description:    Handles packet staging, header hold, parity computation,
//                 and error detection for router core.
//
// Revision: 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module register (
    input        clk, rstn, pkt_vd, fifo_full, rst_in_reg,
    input        detect_addr, ld_state, laf_state, full_state, lfd_state,
    input  [7:0] din,
    output reg   parity_done, low_pkt_vd, error,
    output reg [7:0] dout
);

    // Internal registers
    reg [7:0] hold_header_reg;     // Holds header when detected
    reg [7:0] fifo_full_reg;       // Temporary hold when FIFO is full
    reg [7:0] pkt_parity_reg;      // Parity received from packet
    reg [7:0] itrnl_parity_reg;    // Internal calculated parity

    //==========================================================================
    // Output Logic (dout)
    //==========================================================================

    always @(posedge clk) begin
        if (!rstn)
            dout <= 8'b0;
        else begin
            if (detect_addr && pkt_vd)
                hold_header_reg <= din;                   // Capture header
            else if (lfd_state)
                dout <= hold_header_reg;                  // Output header
            else if (ld_state && !fifo_full)
                dout <= din;                              // Output data directly
            else if (ld_state && fifo_full)
                fifo_full_reg <= din;                     // Store last data if FIFO full
            else if (laf_state)
                dout <= fifo_full_reg;                    // Output after FIFO full state
        end
    end

    //==========================================================================
    // Packet Parity Register (Holds parity byte)
    //==========================================================================

    always @(posedge clk) begin
        if (!rstn)
            pkt_parity_reg <= 8'b0;
        else if (!pkt_vd && ld_state)
            pkt_parity_reg <= din; // Capture parity byte when valid signal drops
    end

    //==========================================================================
    // Internal Parity Calculation
    //==========================================================================

    always @(posedge clk) begin
        if (!rstn)
            itrnl_parity_reg <= 8'b0;
        else if (detect_addr)
            itrnl_parity_reg <= 8'b0; // Reset parity at start of new packet
        else if (lfd_state)
            itrnl_parity_reg <= itrnl_parity_reg ^ hold_header_reg; // XOR header
        else if (ld_state && pkt_vd && !full_state)
            itrnl_parity_reg <= itrnl_parity_reg ^ din; // XOR incoming data
    end

    //==========================================================================
    // Error Detection Logic
    //==========================================================================

    always @(posedge clk) begin
        if (!rstn)
            error <= 1'b0;
        else if (parity_done) begin
            error <= (itrnl_parity_reg != pkt_parity_reg); // Set error if parity mismatch
        end
    end

    //==========================================================================
    // Parity Done Signal
    //==========================================================================
    
    always @(posedge clk) begin
        if (!rstn)
            parity_done <= 1'b0;
        else if ((ld_state && !fifo_full && !pkt_vd) || (laf_state && !pkt_vd))
            parity_done <= 1'b1; // Asserted when packet ends
        else
            parity_done <= 1'b0;
    end

    //==========================================================================
    // Low Packet Valid Detection
    //==========================================================================

    always @(posedge clk) begin
        if (!rstn)
            low_pkt_vd <= 1'b0;
        else if (rst_in_reg)
            low_pkt_vd <= 1'b0; // Clear on reset
        else if (ld_state && !pkt_vd)
            low_pkt_vd <= 1'b1; // Asserted at end of payload
    end

endmodule
