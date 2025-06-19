`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:02:30 09/29/2024 
// Design Name:    Synchronizer Block for Router
// Module Name:    synchronizer_block 
// Description:    Controls write enable selection, monitors FIFO full conditions,
//                 and generates soft resets (srX) for output FIFOs based on timeouts.
//
// Revision: 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module synchronizer_block (
    input        clk, rstn,
    input        detect_addr, write_enb_reg,
    input        re0, re1, re2,    // Read enables from destinations
    input        e0, e1, e2,       // Empty flags from FIFO0, FIFO1, FIFO2
    input        f0, f1, f2,       // Full flags from FIFO0, FIFO1, FIFO2
    input  [1:0] din,              // Input address (destination select)

    output reg   fifo_full,        // MUXed FIFO full output
    output       vo0, vo1, vo2,    // Valid output (not empty) for each FIFO
    output reg   sr0, sr1, sr2,    // Soft reset signals for FIFO0, FIFO1, FIFO2
    output reg [2:0] we            // Write enable for selected FIFO
);

    //--------------------------------------------------------------------------
    // Internal registers
    //--------------------------------------------------------------------------
    reg [1:0] address;             // Holds captured destination address
    reg [4:0] count_0, count_1, count_2;  // Timeout counters for soft resets

    //--------------------------------------------------------------------------
    // Capture Destination Address
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn)
            address <= 2'b00;
        else if (detect_addr)
            address <= din;
    end

    //--------------------------------------------------------------------------
    // Write Enable Logic (based on captured address)
    //--------------------------------------------------------------------------
    always @(*) begin
        if (write_enb_reg) begin
            case (address)
                2'b00: we = 3'b001;  // Enable FIFO0
                2'b01: we = 3'b010;  // Enable FIFO1
                2'b10: we = 3'b100;  // Enable FIFO2
                default: we = 3'b000;
            endcase
        end else begin
            we = 3'b000;
        end
    end

    //--------------------------------------------------------------------------
    // FIFO Full Selection Logic (based on selected address)
    //--------------------------------------------------------------------------
    always @(*) begin
        case (address)
            2'b00: fifo_full = f0;
            2'b01: fifo_full = f1;
            2'b10: fifo_full = f2;
            default: fifo_full = 1'b0;
        endcase
    end

    //--------------------------------------------------------------------------
    // Valid Output Signals (not empty)
    //--------------------------------------------------------------------------
    assign vo0 = ~e0;
    assign vo1 = ~e1;
    assign vo2 = ~e2;

    //--------------------------------------------------------------------------
    // Soft Reset Logic: SR0 - Triggered if vo0 remains high for >29 cycles without re0
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            sr0     <= 1'b0;
            count_0 <= 5'd0;
        end else if (!vo0 || re0) begin
            sr0     <= 1'b0;
            count_0 <= 5'd0;
        end else if (count_0 <= 5'd29) begin
            sr0     <= 1'b0;
            count_0 <= count_0 + 1;
        end else begin
            sr0     <= 1'b1;
            count_0 <= 5'd0;
        end
    end

    //--------------------------------------------------------------------------
    // Soft Reset Logic: SR1 - Similar to SR0 but for FIFO1
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            sr1     <= 1'b0;
            count_1 <= 5'd0;
        end else if (!vo1 || re1) begin
            sr1     <= 1'b0;
            count_1 <= 5'd0;
        end else if (count_1 <= 5'd29) begin
            sr1     <= 1'b0;
            count_1 <= count_1 + 1;
        end else begin
            sr1     <= 1'b1;
            count_1 <= 5'd0;
        end
    end

    //--------------------------------------------------------------------------
    // Soft Reset Logic: SR2 - Similar to SR0 but for FIFO2
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            sr2     <= 1'b0;
            count_2 <= 5'd0;
        end else if (!vo2 || re2) begin
            sr2     <= 1'b0;
            count_2 <= 5'd0;
        end else if (count_2 <= 5'd29) begin
            sr2     <= 1'b0;
            count_2 <= count_2 + 1;
        end else begin
            sr2     <= 1'b1;
            count_2 <= 5'd0;
        end
    end

endmodule
