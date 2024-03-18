`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 10:56:46
// Design Name: 
// Module Name: Top
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


module Top
#(
	parameter CLK_HZ = 100_000_000, // Clock frequency
	parameter BIT_RATE = 256000, // Baud rate
	parameter PAYLOAD_BITS = 8, // Number of data bits recieved per UART packet
	parameter PACKAGES = 10 // Number UART packets
)
(
	input clk, // Clock
	(*mark_debug = "true"*) input rst_n, // Reset active-low
	(*mark_debug = "true"*) input TX_data, // Signal for TX data
	(*mark_debug = "true"*) inout data, // DHT11 data port
	(*mark_debug = "true"*) output uart_txd // UART TX port
);

// FSM States for UART
localparam IDLE = 0;
localparam TX_START = 1;
localparam TX_IDLE = 2;
localparam TX_STOP = 3;

reg [1:0] cstate, nstate; // Current and next states of the internal FSM

wire TX_wire; // Wire for detection TX_data posedge
reg buffer; // Buffer for detection TX_data posedge
reg TX_start; // TX start signal
wire [7:0] temp_wire; // DHT11 Temperature data
wire [7:0] hum_wire; // DHT11 Humidity data
wire [11:0] bcd_temp; // BCD Temperature data
wire [11:0] bcd_hum; // BCD Humidity data
wire valid; // DHT11 data valid
wire valid_bcd1; // BCD Temperature valid
wire valid_bcd2; // BCD Humidity valid
reg [3:0] addr_temp_unit, addr_temp_dec, addr_hum_unit, addr_hum_dec; // ASCII table addresses
wire [7:0] q_temp_unit, q_temp_dec, q_hum_unit, q_hum_dec; // ASCII table output

wire uart_tx_busy; // TX busy
(*mark_debug = "true"*) reg uart_tx_en; // TX enable
(*mark_debug = "true"*) reg [PAYLOAD_BITS - 1:0] package_tx; // Data packet
reg pack_flag; // Packet flag
reg [3:0] cnt_packs; // Packets counter
reg tx_stop; // TX stop signal
reg tx_busy_reg; // TX busy reg
reg [2:0] delay; // Delay

wire [39:0] temp_TX; // Temperature TX data
wire [39:0] hum_TX; // Humidity TX data
reg [79:0] data_tx; // TX data

// --------------------------------------------------------------------------- 
// Detection TX_data posedge

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		buffer <= 1'b0;
	end
	else begin
		buffer <= TX_data;
	end
end

assign TX_wire = TX_data & ~buffer;
////////////


// --------------------------------------------------------------------------- 
// DHT11 Controller Module
DHT11 dht
	(
		.clk(clk),
		.rst_n(rst_n),
		.dht11(data),
		.valid(valid),
		.temp(temp_wire),
		.hum(hum_wire)
	);

// --------------------------------------------------------------------------- 
// BCD for temperature module
BCD bcd_temperature
	(
		.clk(clk),
		.rst_n(rst_n),
		.data_en(valid),
		.bin_in(temp_wire),
		.valid_bcd(valid_bcd1),
		.dec_out(bcd_temp)
	);

// BCD for humidity module
BCD bcd_humidity
	(
		.clk(clk),
		.rst_n(rst_n),
		.data_en(valid),
		.bin_in(hum_wire),
		.valid_bcd(valid_bcd2),
		.dec_out(bcd_hum)
	);

// ASCII Table module	
rom ASCII
	(
		.clk(clk),
		.addr_temp_unit(addr_temp_unit),
		.addr_temp_dec(addr_temp_dec),
		.addr_hum_unit(addr_hum_unit),
		.addr_hum_dec(addr_hum_dec),
		.q_temp_unit(q_temp_unit),
		.q_temp_dec(q_temp_dec),
		.q_hum_unit(q_hum_unit),
		.q_hum_dec(q_hum_dec)
	);

// Assigning table addresses for units and tens
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		addr_temp_unit <= 4'b0;
		addr_temp_dec <= 4'b0;
		addr_hum_unit <= 4'b0;
		addr_hum_dec <= 4'b0;
	end
	else begin
        // If the data at the output of the both blocks is available
		if (valid_bcd1 && valid_bcd2) begin
			addr_temp_unit <= bcd_temp[3:0];
			addr_temp_dec <= bcd_temp[7:4];
			addr_hum_unit <= bcd_hum[3:0];
			addr_hum_dec <= bcd_hum[7:4];
		end
        // If the data at the output of the first block is available
		else if (valid_bcd1) begin
			addr_temp_unit <= bcd_temp[3:0];
			addr_temp_dec <= bcd_temp[7:4];
			addr_hum_unit <= addr_hum_unit;
			addr_hum_dec <= addr_hum_dec;
		end
        // If the data at the output of the second block is available
		else if (valid_bcd2) begin
			addr_temp_unit <= addr_temp_unit;
			addr_temp_dec <= addr_temp_dec;
			addr_hum_unit <= bcd_hum[3:0];
			addr_hum_dec <= bcd_hum[7:4];
		end
	end
end

// --------------------------------------------------------------------------- 
// Transmitted data with predefined ASCII characters
assign temp_TX = {8'b00100000, 8'b01000011, 8'b00100000, q_temp_unit, q_temp_dec};
assign hum_TX = {8'b00100000,  8'b00100101,  8'b00100000, q_hum_unit, q_hum_dec};

// Formation of transmitted data
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		data_tx <= 'd0;
	end
	else if (TX_wire) begin
		data_tx <= {hum_TX, temp_TX};
	end
end	

// TX start signal
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		TX_start <= 1'b0;
	end
	else begin
		TX_start <= TX_wire;
	end
end	

// --------------------------------------------------------------------------- 
// UART module
UART #(.CLK_HZ(CLK_HZ), .BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS)) uart
	(
		.clk(clk),
		.rst_n(rst_n),
		.uart_tx_en(uart_tx_en),
		.package_tx(package_tx),
		.uart_txd(uart_txd),
		.uart_tx_busy(uart_tx_busy)
	);

// Progresses the next FSM state
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		cstate <= IDLE;
	end
	else begin
		cstate <= nstate;
	end
end

// Busy register
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		tx_busy_reg <= 1'b0;
	end
	else begin
		tx_busy_reg <= uart_tx_busy;
	end
end

// FSM Transition logic
always @ (*) begin
	nstate = cstate;
	case (cstate)
		IDLE : nstate = TX_start ? TX_START : IDLE;
		TX_START : nstate = TX_IDLE;
		TX_IDLE : nstate = (tx_busy_reg || delay < 3) ? TX_IDLE : cnt_packs < PACKAGES ? TX_START : TX_STOP;
		TX_STOP : nstate = IDLE;
		default : nstate = IDLE;
	endcase
end

// FSM To transmit several data packets in a row
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		uart_tx_en <= 1'b0;
		cnt_packs <= 'b0;
		tx_stop <= 1'b0;
		pack_flag <= 1'b0;
		package_tx <= 8'b0;
		delay <= 'd0;
	end
	else begin
		case (nstate)
			IDLE : begin
				uart_tx_en <= 1'b0;
				cnt_packs <= 'b0;
				tx_stop <= 1'b0;
				pack_flag <= 1'b0;
				package_tx <= 8'b0;
				delay <= 'd0;
			end
			TX_START : begin
				uart_tx_en <= 1'b1;
				cnt_packs <= cnt_packs;
				tx_stop <= 1'b0;
				pack_flag <= 1'b0;
				package_tx <= data_tx[cnt_packs * 8 +:8]; // Generating 8-bit packets from the data register
				delay <= 'd0;
			end
			TX_IDLE : begin
				uart_tx_en <= 1'b0;
				if (pack_flag == 1'b0) begin
					cnt_packs <= cnt_packs + 1'b1;
				end
				package_tx <= package_tx;
				tx_stop <= 1'b0;
				pack_flag <= 1'b1;
				delay <= delay + 1;
			end
			TX_STOP : begin
				tx_stop <= 1'b1;
				uart_tx_en <= 1'b0;
				pack_flag <= 1'b0;
				delay <= 'd0;
			end
			default : begin
				uart_tx_en <= 1'b0;
				cnt_packs <= 'b0;
				tx_stop <= 1'b0;
				pack_flag <= 1'b0;
				package_tx <= 8'b0;
			end
		endcase
	end
end

endmodule
