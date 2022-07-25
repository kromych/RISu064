`timescale 1ns / 1ps
`default_nettype none
//
// RISu64
// Copyright 2022 Wenting Zhang
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

module asictop(
    input  wire         clk,
    input  wire         rst,
    output wire         ml_clk,
    output wire         ml_clkn,
    output wire         ml_abr,
    input  wire         ml_bbr,
    output wire [31:0]  ml_data_o,
    input  wire [31:0]  ml_data_i,
    output wire         ml_data_oe,
    output wire         ml_data_ie
);

    wire [31:0] ib_req_addr;
    wire [2:0]  ib_req_size;
    wire        ib_req_valid;
    wire        ib_req_ready;
    wire [63:0] ib_resp_rdata;
    wire        ib_resp_valid;
    wire        ib_resp_ready;
    wire [31:0] db_req_addr;
    wire [63:0] db_req_wdata;
    wire [7:0]  db_req_wmask;
    wire        db_req_wen;
    wire [2:0]  db_req_size;
    wire        db_req_valid;
    wire        db_req_ready;
    wire [63:0] db_resp_rdata;
    wire        db_resp_valid;
    wire        db_resp_ready;
    wire        extint_software;
    wire        extint_timer;
    wire        extint_external;

    // CPU core
    risu risu(
        .clk(clk),
        .rst(rst),
        .ib_req_addr(ib_req_addr),
        .ib_req_size(ib_req_size),
        .ib_req_valid(ib_req_valid),
        .ib_req_ready(ib_req_ready),
        .ib_resp_rdata(ib_resp_rdata),
        .ib_resp_valid(ib_resp_valid),
        .ib_resp_ready(ib_resp_ready),
        .db_req_addr(db_req_addr),
        .db_req_wdata(db_req_wdata),
        .db_req_wmask(db_req_wmask),
        .db_req_wen(db_req_wen),
        .db_req_size(db_req_size),
        .db_req_valid(db_req_valid),
        .db_req_ready(db_req_ready),
        .db_resp_rdata(db_resp_rdata),
        .db_resp_valid(db_resp_valid),
        .db_resp_ready(db_resp_ready),
        .extint_software(extint_software),
        .extint_timer(extint_timer),
        .extint_external(extint_external)
    );

    /// TODO: Do something about this
    assign extint_software = 1'b0;
    assign extint_timer = 1'b0;
    assign extint_external = 1'b0;

    wire [31:0] bus_req_addr;
    wire        bus_req_wen;
    wire [63:0] bus_req_wdata;
    wire [7:0]  bus_req_wmask;
    wire [2:0]  bus_req_size;
    wire [4:0]  bus_req_srcid;
    wire        bus_req_valid;
    wire        bus_req_ready;
    wire [63:0] bus_resp_rdata;
    wire [2:0]  bus_resp_size;
    wire [4:0]  bus_resp_dstid;
    wire        bus_resp_valid;
    wire        bus_resp_ready;

    kl_arbiter_2by1 kl_arbiter_2by1(
        .clk(clk),
        .rst(rst),
        // Instruction bus
        .up0_req_addr(ib_req_addr),
        .up0_req_wen(1'b0),
        .up0_req_wdata(64'bx),
        .up0_req_wmask(8'bx),
        .up0_req_size(ib_req_size),
        .up0_req_valid(ib_req_valid),
        .up0_req_ready(ib_req_ready),
        .up0_resp_rdata(ib_resp_rdata),
        .up0_resp_valid(ib_resp_valid),
        .up0_resp_ready(ib_resp_ready),
        // Data bus
        .up1_req_addr(db_req_addr),
        .up1_req_wen(db_req_wen),
        .up1_req_wdata(db_req_wdata),
        .up1_req_wmask(db_req_wmask),
        .up1_req_size(db_req_size),
        .up1_req_valid(db_req_valid),
        .up1_req_ready(db_req_ready),
        .up1_resp_rdata(db_resp_rdata),
        .up1_resp_valid(db_resp_valid),
        .up1_resp_ready(db_resp_ready),
        // External port
        .dn_req_addr(bus_req_addr),
        .dn_req_wen(bus_req_wen),
        .dn_req_wdata(bus_req_wdata),
        .dn_req_wmask(bus_req_wmask),
        .dn_req_size(bus_req_size),
        .dn_req_srcid(bus_req_srcid),
        .dn_req_valid(bus_req_valid),
        .dn_req_ready(bus_req_ready),
        .dn_resp_rdata(bus_resp_rdata),
        .dn_resp_size(bus_resp_size),
        .dn_resp_dstid(bus_resp_dstid),
        .dn_resp_valid(bus_resp_valid),
        .dn_resp_ready(bus_resp_ready)
    );

    // External bus bridge
    wire [31:0] sideband_rx;
    kl2ml_bridge kl2ml_bridge(
        .clk(clk),
        .rst(rst),
        .kl_req_addr(bus_req_addr),
        .kl_req_wen(bus_req_wen),
        .kl_req_wdata(bus_req_wdata),
        .kl_req_wmask(bus_req_wmask),
        .kl_req_size(bus_req_size),
        .kl_req_srcid(bus_req_srcid),
        .kl_req_valid(bus_req_valid),
        .kl_req_ready(bus_req_ready),
        .kl_resp_rdata(bus_resp_rdata),
        /* verilator lint_off PINCONNECTEMPTY */
        .kl_resp_ren(),
        /* verilator lint_on PINCONNECTEMPTY */
        .kl_resp_size(bus_resp_size),
        .kl_resp_dstid(bus_resp_dstid),
        .kl_resp_valid(bus_resp_valid),
        .kl_resp_ready(bus_resp_ready),
        .ml_clk(ml_clk),
        .ml_clkn(ml_clkn),
        .ml_abr(ml_abr),
        .ml_bbr(ml_bbr),
        .ml_data_o(ml_data_o),
        .ml_data_i(ml_data_i),
        .ml_data_oe(ml_data_oe),
        .ml_data_ie(ml_data_ie),
        .sideband(sideband_rx)
    );

endmodule
