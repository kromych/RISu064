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
module ram_128_24(
    input wire clk,
    input wire rst,
    // Read port
    input wire [6:0] raddr,
    output wire [23:0] rd,
    input wire re,
    // Write port
    input wire [6:0] waddr,
    input wire [23:0] wr,
    input wire we
);

`ifdef SKY130
    sky130_sram_1r1w_24x128_8 mem(
        .clk0(clk),
        .csb0(!we),
        .addr0(waddr),
        .din0(wr),
        .clk1(clk),
        .csb1(!re),
        .addr1(raddr),
        .dout1(rd)
    );
`else
    reg [23:0] mem [0:127];
    reg [23:0] rd_reg;

    always @(posedge clk) begin
        if (!rst) begin
            if (we) begin
                mem[waddr] <= wr;
            end
            
            if (re) begin
                rd_reg <= mem[raddr];
            end
        end
    end

    assign rd = rd_reg;
`endif

endmodule
