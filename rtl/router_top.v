`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:06:50 09/30/2024 
// Design Name:    Packet-Based Router Top Module
// Module Name:    top_module 
// Description:    Integrates all router sub-modules (FIFO, FSM, Register,
//                 Synchronizer) to form a complete packet-based data router.
//
// Revision: 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module top_module (
    input         clk, rstn,          // Clock and reset
    input         pkt_vd,            // Packet valid signal
    input         re0, re1, re2,     // Read enables for output FIFOs
    input  [7:0]  din,               // 8-bit input data

    output        vo0, vo1, vo2,     // Valid out signals for each FIFO
    output        busy, error,       // FSM busy and parity error signal
    output [7:0]  dout0, dout1, dout2 // Output data from each FIFO
);

    //--------------------------------------------------------------------------
    // Internal Wires
    //--------------------------------------------------------------------------

    // Control & status signals
    wire sr0, sr1, sr2;             // Soft reset for FIFO0, FIFO1, FIFO2
    wire parity_done;               // Indicates parity byte received and checked
    wire fifo_full;                 // FIFO full signal from synchronizer block
    wire low_pkt_vd;                // Indicates low pkt_vd (end of packet)

    wire fe0, fe1, fe2;             // Empty flags for FIFO0, FIFO1, FIFO2
    wire full0, full1, full2;       // Full flags for FIFO0, FIFO1, FIFO2

    wire detect_addr;               // FSM: detecting address
    wire ld_state, laf_state;       // FSM: load data states
    wire full_state, write_enb_reg; // FSM: indicates full state & write enable
    wire lfd_state, rst_int_reg;    // FSM: load first data & internal reset

    wire [2:0] we;                  // Write enables for 3 FIFOs
    wire [7:0] data_out;            // Output of register block to FIFO inputs

    //--------------------------------------------------------------------------
    // FIFO Instantiations
    //--------------------------------------------------------------------------

    fifo f1 (
        .clk(clk), .rstn(rstn),
        .we(we[0]), .re(re0), .soft_rst(sr0),
        .lfd_state(lfd_state),
        .empty(fe0), .full(full0),
        .din(data_out), .dout(dout0)
    );

    fifo f2 (
        .clk(clk), .rstn(rstn),
        .we(we[1]), .re(re1), .soft_rst(sr1),
        .lfd_state(lfd_state),
        .empty(fe1), .full(full1),
        .din(data_out), .dout(dout1)
    );

    fifo f3 (
        .clk(clk), .rstn(rstn),
        .we(we[2]), .re(re2), .soft_rst(sr2),
        .lfd_state(lfd_state),
        .empty(fe2), .full(full2),
        .din(data_out), .dout(dout2)
    );

    //--------------------------------------------------------------------------
    // FSM Instantiation
    //--------------------------------------------------------------------------

    fsm fb (
        .clk(clk), .rstn(rstn),
        .pkt_vd(pkt_vd),
        .din(din[1:0]),

        .fifo_full(fifo_full),
        .fifo_empty0(fe0),
        .fifo_empty1(fe1),
        .fifo_empty2(fe2),

        .sft_rst0(sr0),
        .sft_rst1(sr1),
        .sft_rst2(sr2),

        .parity_done(parity_done),
        .low_pkt_vd(low_pkt_vd),

        .detect_add(detect_addr),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),

        .write_enb_reg(write_enb_reg),
        .rst_in_reg(rst_int_reg),

        .busy(busy)
    );

    //--------------------------------------------------------------------------
    // Register Block Instantiation
    //--------------------------------------------------------------------------

    register r1 (
        .clk(clk), .rstn(rstn),
        .pkt_vd(pkt_vd),
        .fifo_full(fifo_full),
        .rst_in_reg(rst_int_reg),

        .detect_addr(detect_addr),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),

        .din(din),
        .parity_done(parity_done),
        .low_pkt_vd(low_pkt_vd),
        .error(error),
        .dout(data_out)
    );

    //--------------------------------------------------------------------------
    // Synchronizer Block Instantiation
    //--------------------------------------------------------------------------

    synchronizer_block s1 (
        .clk(clk), .rstn(rstn),
        .detect_addr(detect_addr),
        .write_enb_reg(write_enb_reg),

        .re0(re0), .re1(re1), .re2(re2),
        .e0(fe0), .e1(fe1), .e2(fe2),
        .f0(full0), .f1(full1), .f2(full2),

        .din(din[1:0]),
        .vo0(vo0), .vo1(vo1), .vo2(vo2),
        .sr0(sr0), .sr1(sr1), .sr2(sr2),
        .fifo_full(fifo_full),
        .we(we)
    );

endmodule
