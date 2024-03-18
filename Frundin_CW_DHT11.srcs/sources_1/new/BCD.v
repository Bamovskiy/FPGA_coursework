`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 10:56:46
// Design Name: 
// Module Name: BCD
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BCD
(
    input [7:0] bin_in, // Data input
    input clk, // Clock
    input rst_n, // Reset active-low
	input data_en, // DHT11 data valid
    output reg [11:0] dec_out, // BCD output
	output reg valid_bcd // BCD data valid
);

reg [7:0] bin; // Input data register
reg [11:0] bcd; // BCD register
reg [2:0] state; // FSM state
reg [3:0] i; // Bit counter
reg valid; // Valid register

// FSM States
localparam RESET = 3'd0;
localparam START = 3'd1;
localparam SHIFT = 3'd2;
localparam ADD = 3'd3;
localparam DONE = 3'd4;

// BCD FSM
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        state <= RESET;
    else
        begin
            state <= START;
            case (state)
                RESET:
                    begin
                        bin <= 'd0;
                        i <= 'd0;
                        bcd <= 'd0;
                        dec_out <= 'd0;
								valid <= 1'b0;
								valid_bcd <= 1'b0;
                    end
                START:
                    begin
                        bin <= bin_in;
                        bcd <= 'd0;
								valid <= data_en;
								valid_bcd <= 1'b0;
								if (valid) begin
									state <= SHIFT;
								end
                    end
                SHIFT:
                    begin
                        bin <= {bin [6:0], 1'd0};
                        bcd <= {bcd [10:0], bin[7]};
                        i <= i + 4'd1;
                        if (i == 4'd7)
                            state <= DONE;
                        else
                            state <= ADD;
                    end
                ADD:
                    begin
                        if (bcd[3:0] > 'd4)
                            begin
                                bcd[3:0] <= bcd[3:0] + 4'd3;
                                state <= SHIFT;
                            end
                        else
                            state <= SHIFT;
                            
                        if (bcd[7:4] > 'd4)
                            begin
                                bcd[7:4] <= bcd[7:4] + 4'd3;
                                state <= SHIFT;
                            end
                        else
                            state <= SHIFT;
                        
                        if (bcd[11:8] >'d4)
                            begin
                                bcd[11:8] <= bcd[11:8] + 4'd3;
                                state <= SHIFT;
                            end
                        else
                            state <= SHIFT;
                    end
                DONE:
                    begin
                        dec_out <= bcd;
                        i <= 4'd0;
                        state <= START;
								valid_bcd <= 1'b1;
                    end
                default
                    state <= RESET;
                endcase
            end
endmodule
