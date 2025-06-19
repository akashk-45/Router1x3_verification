`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:17:11 09/29/2024 
// Design Name:    FSM Controller for Packet Router
// Module Name:    fsm 
// Description:    Controls FIFO selection, loading, and packet states based on
//                 packet validity, FIFO status, and parity checks.
//
// Revision: 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module fsm (
    input        clk, rstn, pkt_vd,
    input        fifo_full,
    input        fifo_empty0, fifo_empty1, fifo_empty2,
    input        sft_rst0, sft_rst1, sft_rst2,
    input        parity_done, low_pkt_vd,
    input  [1:0] din,

    output       detect_add, ld_state, laf_state, full_state,
    output       lfd_state, write_enb_reg, rst_in_reg, busy
);

    //--------------------------------------------------------------------------
    // State Encoding
    //--------------------------------------------------------------------------
    parameter decode_address     = 3'b000,
              load_first_data    = 3'b001,
              load_data          = 3'b010,
              wait_till_empty    = 3'b011,
              load_parity        = 3'b100,
              check_parity_error = 3'b101,
              fifo_full_state    = 3'b110,
              load_after_full    = 3'b111;

    reg [2:0] pst, nst; // Present and next states

    //--------------------------------------------------------------------------
    // Present State Logic (Synchronous Reset & Soft Reset)
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn || sft_rst0 || sft_rst1 || sft_rst2)
            pst <= decode_address;
        else
            pst <= nst;
    end

    //--------------------------------------------------------------------------
    // Next State Logic (Combinational)
    //--------------------------------------------------------------------------
    always @(*) begin
        nst = decode_address;  // Default state
        case (pst)
            decode_address: begin
                if ((pkt_vd && din == 2'd0 && fifo_empty0) ||
                    (pkt_vd && din == 2'd1 && fifo_empty1) ||
                    (pkt_vd && din == 2'd2 && fifo_empty2))
                    nst = load_first_data;
                else if ((pkt_vd && din == 2'd0 && !fifo_empty0) ||
                         (pkt_vd && din == 2'd1 && !fifo_empty1) ||
                         (pkt_vd && din == 2'd2 && !fifo_empty2))
                    nst = wait_till_empty;
                else
                    nst = decode_address;
            end

            load_first_data:
                nst = load_data;

            load_data: begin
                if (!fifo_full && !pkt_vd)
                    nst = load_parity;
                else if (fifo_full)
                    nst = fifo_full_state;
                else
                    nst = load_data;
            end

            wait_till_empty: begin
                if (fifo_empty0 || fifo_empty1 || fifo_empty2)
                    nst = load_first_data;
                else
                    nst = wait_till_empty;
            end

            load_parity:
                nst = check_parity_error;

            check_parity_error: begin
                if (fifo_full)
                    nst = fifo_full_state;
                else
                    nst = decode_address;
            end

            fifo_full_state: begin
                if (!fifo_full)
                    nst = load_after_full;
                else
                    nst = fifo_full_state;
            end

            load_after_full: begin
                if (!parity_done && !low_pkt_vd)
                    nst = load_data;
                else if (!parity_done && low_pkt_vd)
                    nst = load_parity;
                else if (parity_done)
                    nst = decode_address;
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // Output Logic (Mealy-style where required)
    //--------------------------------------------------------------------------

    assign detect_add     = (pst == decode_address);
    assign lfd_state      = (pst == load_first_data);
    assign ld_state       = (pst == load_data);
    assign laf_state      = (pst == load_after_full);
    assign full_state     = (pst == fifo_full_state);
    assign write_enb_reg  = (pst == load_data || pst == load_parity || pst == load_after_full);
    assign rst_in_reg     = (pst == check_parity_error);
    assign busy           = (pst == load_data || pst == decode_address) ? 1'b0 : 1'b1;

endmodule
