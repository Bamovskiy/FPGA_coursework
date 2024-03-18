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


module DHT11
(
	input clk, // Clock
	input rst_n, // Reset active-low
	inout dht11, // DHT11 data port
	output valid, // DHT11 data valid
	(*mark_debug = "true"*) output reg [7:0] temp, // DHT11 Temperature data
	(*mark_debug = "true"*) output reg [7:0] hum // DHT11 Humidity data
);

//parameter POWER_ON_NUM = 1000000;
parameter POWER_ON_NUM = 10000; // Initial waiting time (Us)

// FSM States
localparam POWER_ON = 0;
localparam LOW_20MS = 1;
localparam HIGH_20US = 2;
localparam LOW_80US = 3;
localparam HIGH_80US = 4;
localparam RX_DATA = 5;
localparam DELAY = 6;

reg [2:0] cstate, nstate; // Current and next states of the internal FSM
reg [20:0] cnt_1us; // Microsecond counter
reg [5:0] data_cnt; // Bits counter
reg [39:0] data_buff; // Data buffer
reg [5:0] clk_cnt; // Clk counter

(*mark_debug = "true"*) reg clk_1M; // 1 MHz frequency
reg us_clear; // Clear cnt_1us signal
reg state; // Data state signal
reg dht_buffer; // Data buffer
reg dht_d0; // Data buffer
reg dht_d1; // Data buffer

wire dht_posedge; // Data posedge
wire dht_negedge; // Data negedge

assign dht11 = dht_buffer;
assign dht_posedge = ~dht_d1 & dht_d0; // Data posedge
assign dht_negedge = dht_d1 & ~dht_d0; // Data negedge

// --------------------------------------------------------------------------- 
// 1 MHz clock generation
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		clk_cnt <= 6'd0;
		clk_1M <= 1'b0;
	end
	else if (clk_cnt < 6'd49)
		clk_cnt <= clk_cnt + 1'b1;
	else begin
		clk_cnt <= 6'd0;
		clk_1M <= ~clk_1M;
	end
end

// Microsecond timer
always @ (posedge clk_1M, negedge rst_n) begin
	if (!rst_n)
		cnt_1us <= 21'd0;
	else if (us_clear)
		cnt_1us <= 21'd0;
	else
		cnt_1us <= cnt_1us + 1'b1;
end

// --------------------------------------------------------------------------- 
// Progresses the next FSM state
always @ (posedge clk_1M, negedge rst_n) begin
	if (!rst_n)
		cstate <= POWER_ON;
	else
		cstate <= nstate;
end

// FSM
always @ (posedge clk_1M, negedge rst_n) begin
	if (!rst_n) begin
		nstate <= POWER_ON;
		dht_buffer <= 1'bz;
		state <= 1'b0;
		us_clear <= 1'b0;
		data_buff <= 40'd0;
		data_cnt <= 6'd0;
	end
	else begin
		case (cstate)
			POWER_ON : begin
				if (cnt_1us < POWER_ON_NUM) begin
					dht_buffer <= 1'bz;
					us_clear <= 1'b0;
				end
				else begin
					nstate <= LOW_20MS;
					us_clear <= 1'b1;
				end
			end
			LOW_20MS : begin
				if (cnt_1us < 20000) begin
					dht_buffer <= 1'b0;
					us_clear <= 1'b0;
				end
				else begin
					nstate <= HIGH_20US;
					dht_buffer <= 1'bz;
					us_clear <= 1'b1;
				end
			end
			HIGH_20US : begin
				if (cnt_1us < 50) begin
					us_clear <= 1'b0;
					if (dht_negedge) begin
						nstate <= LOW_80US;
						us_clear <= 1'b1;
					end
				end
				else
					nstate <= DELAY;
			end
			LOW_80US : begin
				if (dht_posedge)
					nstate <= HIGH_80US;
			end
			HIGH_80US : begin
				if (dht_negedge) begin
					nstate <= RX_DATA;
					us_clear <= 1'b1;
				end
				else begin
					data_cnt <= 6'd0;
					data_buff <= 40'd0;
					state <= 1'b0;
				end
			end
			RX_DATA : begin
				case (state)
					0 : begin
						if (dht_posedge) begin
							state <= 1'b1;
							us_clear <= 1'b1;
						end
						else
							us_clear <= 1'b0;
					end
					1 : begin
						if (dht_negedge) begin
							data_cnt <= data_cnt + 1'b1;
							state <= 1'b0;
							us_clear <= 1'b1;
							// Data detection
							if (cnt_1us < 60)
								data_buff <= {data_buff[38:0], 1'b0};
							else
								data_buff <= {data_buff[38:0], 1'b1};
						end
						else
							us_clear <= 1'b0;
					end
				endcase
				if (data_cnt == 40) begin
					nstate <= DELAY;
					temp <= data_buff[23:16];
					hum <= data_buff[39:32];
				end
			end
			DELAY : begin
				if (cnt_1us < 200000)
					us_clear <= 1'b0;
				else begin
					nstate <= LOW_20MS;
					us_clear <= 1'b1;
				end
			end
			default : begin
				cstate <= cstate;
			end
		endcase
	end
end

// --------------------------------------------------------------------------- 
// Data registers
always @ (posedge clk_1M, negedge rst_n) begin
	if (!rst_n) begin
		dht_d0 <= 1'b1;
		dht_d1 <= 1'b1;
	end
	else begin
		dht_d0 <= dht11;
		dht_d1 <= dht_d0;
	end
end

// Valid signal
assign valid = (cstate == RX_DATA && nstate == DELAY) ? 1'b1 : 1'b0;

endmodule
