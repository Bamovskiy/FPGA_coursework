`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 10:56:46
// Design Name: 
// Module Name: UART
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


module UART
#(
	parameter CLK_HZ = 100_000_000, // Clock frequency
	parameter BIT_RATE = 256000, // Baud rate
	parameter PAYLOAD_BITS = 8 // Number of data bits recieved per UART packet
)
(
	input clk, // Clock
	input rst_n, // Reset active-low
	input uart_tx_en, // Enable port
	input [PAYLOAD_BITS - 1:0] package_tx, // Packet
	output uart_txd, // TX port
	output uart_tx_busy // Busy port
);

wire [PAYLOAD_BITS - 1:0] uart_tx_data; // Wire for sending data

assign uart_tx_data = package_tx;

// UART TX module
uart_tx #(.BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS), .CLK_HZ(CLK_HZ), .STOP_BITS(1)) i_uart_tx
(
	.clk(clk),
	.rst_n(rst_n),
	.uart_txd(uart_txd),
	.uart_tx_en(uart_tx_en),
	.uart_tx_busy(uart_tx_busy),
	.uart_tx_data(uart_tx_data)
);

endmodule