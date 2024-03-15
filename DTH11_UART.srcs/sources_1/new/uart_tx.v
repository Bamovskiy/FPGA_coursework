`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2024 10:32:47
// Design Name: 
// Module Name: uart_tx
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


module uart_tx
#(
	parameter CLK_HZ = 100_000_000, // Clock frequency
	parameter BIT_RATE = 256000,	// Baud rate
	parameter PAYLOAD_BITS = 8, // Number of data bits recieved per UART packet
	parameter STOP_BITS = 1 // Number of stop bits indicating the end of a packet
)
(
	input clk, // Clock
	input rst_n, // Reset active-low
	output uart_txd, // TX port
	output uart_tx_busy, // Busy port
	input uart_tx_en, // Enable port
	input [PAYLOAD_BITS-1:0] uart_tx_data // Packet
);

localparam BIT_P = 1_000_000_000 * 1/BIT_RATE; // Nanosec
localparam CLK_P = 1_000_000_000 * 1/CLK_HZ; // Nanosec
localparam CYCLES_PER_BIT = BIT_P / CLK_P;  // Number of clock cycles per uart bit
localparam COUNT_REG_LEN = 1 + $clog2(CYCLES_PER_BIT); // Size of the registers which store sample counts and bit durations

reg txd_reg; // Internally latched value of the uart_txd line
reg [PAYLOAD_BITS-1:0] data_to_send; // Storage for the serial data to be sent
reg [COUNT_REG_LEN-1:0] cycle_counter; // Counter for the number of cycles over a packet bit
reg [3:0] bit_counter; // Counter for the number of sent bits of the packet
reg [2:0] fsm_state, n_fsm_state; // Current and next states of the internal FSM

localparam FSM_IDLE = 0;
localparam FSM_START = 1;
localparam FSM_SEND = 2;
localparam FSM_STOP = 3;

// --------------------------------------------------------------------------- 
// FSM next state selection

assign uart_tx_busy = fsm_state != FSM_IDLE;
assign uart_txd = txd_reg;

wire next_bit = cycle_counter == CYCLES_PER_BIT;
wire payload_done = bit_counter == PAYLOAD_BITS  ;
wire stop_done = bit_counter == STOP_BITS && fsm_state == FSM_STOP;

// Handle picking the next state
always @(*) begin : p_n_fsm_state
    case(fsm_state)
        FSM_IDLE : n_fsm_state = uart_tx_en ? FSM_START: FSM_IDLE ;
        FSM_START : n_fsm_state = next_bit ? FSM_SEND : FSM_START;
        FSM_SEND : n_fsm_state = payload_done ? FSM_STOP : FSM_SEND ;
        FSM_STOP : n_fsm_state = stop_done ? FSM_IDLE : FSM_STOP ;
        default : n_fsm_state = FSM_IDLE;
    endcase
end

// --------------------------------------------------------------------------- 
// Internal register setting and re-setting

// Handle updates to the sent data register
integer i = 0;
always @(posedge clk) begin : p_data_to_send
    if(!rst_n) begin
        data_to_send <= {PAYLOAD_BITS{1'b0}};
    end else if(fsm_state == FSM_IDLE && uart_tx_en) begin
        data_to_send <= uart_tx_data;
    end else if(fsm_state == FSM_SEND && next_bit ) begin
        for (i = PAYLOAD_BITS-2; i >= 0; i = i - 1) begin
            data_to_send[i] <= data_to_send[i+1];
        end
    end
end

// Increments the bit counter each time a new bit frame is sent
always @(posedge clk) begin : p_bit_counter
    if(!rst_n) begin
        bit_counter <= 4'b0;
    end else if(fsm_state != FSM_SEND && fsm_state != FSM_STOP) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_SEND && n_fsm_state == FSM_STOP) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_STOP&& next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end else if(fsm_state == FSM_SEND && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end
end

// Increments the cycle counter when sending
always @(posedge clk) begin : p_cycle_counter
    if(!rst_n) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(next_bit) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_START || 
                fsm_state == FSM_SEND  || 
                fsm_state == FSM_STOP) begin
        cycle_counter <= cycle_counter + 1'b1;
    end
end

// Progresses the next FSM state
always @(posedge clk) begin : p_fsm_state
    if(!rst_n) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end

// Responsible for updating the internal value of the txd_reg
always @(posedge clk) begin : p_txd_reg
    if(!rst_n) begin
        txd_reg <= 1'b1;
    end else if(fsm_state == FSM_IDLE) begin
        txd_reg <= 1'b1;
    end else if(fsm_state == FSM_START) begin
        txd_reg <= 1'b0;
    end else if(fsm_state == FSM_SEND) begin
        txd_reg <= data_to_send[0];
    end else if(fsm_state == FSM_STOP) begin
        txd_reg <= 1'b1;
    end
end

endmodule
