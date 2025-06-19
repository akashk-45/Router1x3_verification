`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:21:41 09/29/2024 
// Design Name:    FIFO with packet-based support
// Module Name:    fifo 
// Project Name: 
// Description:    This FIFO supports both standard and packet-based operations.
//                 It uses an embedded header to determine payload size for packets.
//
// Dependencies:   None
//
//////////////////////////////////////////////////////////////////////////////////

module fifo (
    input              clk,        // System clock
    input              rstn,       // Active-low reset
    input              we,         // Write enable
    input              re,         // Read enable
    input              soft_rst,   // Soft reset signal
    input              lfd_state,  // Start-of-packet indicator
    input      [7:0]   din,        // Data input
    output reg [7:0]   dout,       // Data output
    output             full,       // FIFO full flag
    output             empty       // FIFO empty flag
);

    // Internal pointers and counters
    reg [4:0] wr_pt, rd_pt;        // Write and read pointers (5 bits to track full/empty)
    reg [6:0] fifo_counter;        // Packet-aware counter
    reg       lfd_state_s;         // Sampled lfd_state signal

    // Internal FIFO memory - 16 entries of 9 bits (1 bit lfd + 8 bits data)
    reg [8:0] mem[15:0];
    integer i;

    //------------------------------
    // Write & Read Pointer Logic
    //------------------------------
    always @(posedge clk) begin
        if (!rstn || soft_rst) begin
            wr_pt <= 5'd0;
            rd_pt <= 5'd0;
        end
        else begin
            if (re && !empty)
                rd_pt <= rd_pt + 5'd1;
            if (we && !full)
                wr_pt <= wr_pt + 5'd1;
        end
    end

    //------------------------------
    // LFD State Sampling Logic
    //------------------------------
    always @(posedge clk) begin
        if (!rstn)
            lfd_state_s <= 1'b0;
        else
            lfd_state_s <= lfd_state;
    end

    //------------------------------
    // Write Operation
    //------------------------------
    always @(posedge clk) begin
        if (!rstn || soft_rst) begin
            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 9'd0;
        end
        else if (we && !full) begin
            mem[wr_pt[3:0]] <= {lfd_state_s, din};  // Concatenate lfd bit with 8-bit data
        end
    end

    //------------------------------
    // Read Operation
    //------------------------------
    always @(posedge clk) begin
        if (!rstn)
            dout <= 8'd0;
        else if (soft_rst)
            dout <= 8'bz;  // High-impedance state on soft reset
        else if (re && !empty)
            dout <= mem[rd_pt[3:0]][7:0];  // Read only data part (exclude lfd bit)
    end

    //------------------------------
    // Packet Counter Logic
    // Counts number of remaining packet bytes
    //------------------------------
    always @(posedge clk) begin
        if (!rstn || soft_rst) begin
            fifo_counter <= 7'd0;
        end
        else if (re && !empty) begin
            if (mem[rd_pt[3:0]][8] == 1)  // If start-of-packet detected
                fifo_counter <= mem[rd_pt[3:0]][7:2] + 7'd1;  // Extract payload size + header
            else if (fifo_counter != 7'd0)
                fifo_counter <= fifo_counter - 7'd1;
        end
    end

    //------------------------------
    // FIFO Status Flags
    //------------------------------
    assign full  = ((wr_pt[4] != rd_pt[4]) && (wr_pt[3:0] == rd_pt[3:0])) ? 1'b1 : 1'b0;
    assign empty = (wr_pt == rd_pt) ? 1'b1 : 1'b0;

endmodule
