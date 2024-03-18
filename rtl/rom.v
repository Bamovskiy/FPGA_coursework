`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 10:56:46
// Design Name: 
// Module Name: rom
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


module rom
#(
	parameter DATA_WIDTH=8, 
	parameter ADDR_WIDTH=4
)
(
	input [(ADDR_WIDTH-1):0] addr_temp_unit,
	input [(ADDR_WIDTH-1):0] addr_temp_dec,
	input [(ADDR_WIDTH-1):0] addr_hum_unit,
	input [(ADDR_WIDTH-1):0] addr_hum_dec,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q_temp_unit,
	output reg [(DATA_WIDTH-1):0] q_temp_dec,
	output reg [(DATA_WIDTH-1):0] q_hum_unit,
	output reg [(DATA_WIDTH-1):0] q_hum_dec
);

	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

initial
	begin
		rom[0] = 8'b00110000;
		rom[1] = 8'b00110001;
		rom[2] = 8'b00110010;
		rom[3] = 8'b00110011;
		rom[4] = 8'b00110100;
		rom[5] = 8'b00110101;
		rom[6] = 8'b00110110;
		rom[7] = 8'b00110111;
		rom[8] = 8'b00111000;
		rom[9] = 8'b00111001;
		rom[10] = 8'b00110000;
		rom[11] = 8'b00110000;
		rom[12] = 8'b00110000;
		rom[13] = 8'b00110000;
		rom[14] = 8'b00110000;
		rom[15] = 8'b00110000;
	end

always @ (posedge clk) begin
		q_temp_unit <= rom[addr_temp_unit];
		q_temp_dec <= rom[addr_temp_dec];
		q_hum_unit <= rom[addr_hum_unit];
		q_hum_dec <= rom[addr_hum_dec];
end

endmodule
