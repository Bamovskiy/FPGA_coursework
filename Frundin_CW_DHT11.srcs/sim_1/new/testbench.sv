`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 11:00:24
// Design Name: 
// Module Name: testbench
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


module testbench(); 

parameter Tt = 10;
	
logic clk;
logic rst_n;
wire data; 
logic TX_data;
logic uart_txd;
logic clk_1M;

logic w1r; 
logic w1_en; 

Top DHT11_tb 
	(
		.clk(clk),
		.rst_n(rst_n),
		.data(data),
		.TX_data(TX_data),
		.uart_txd(uart_txd)
	);

initial begin  
	w1r = 1'b0; 
	w1_en = 1'b0; 
	rst_n = 1'b0; 
	TX_data = 1'b0;
		#10
			rst_n <= 1'b1;
		repeat(30002) @(posedge clk_1M);
			w1r <= 1'b1; 
			w1_en <= 1'b1; 
		repeat(20) @(posedge clk_1M);
			w1r <= 1'b0; 
		#80000
			w1r <= 1'b1;
		#80000
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 1 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 2 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 3 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 4 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 5 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 6 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 7 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 8 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 9 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 10 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 11 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 12 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 13 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 14 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 15 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 16 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 17 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 18 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 19 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 20 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 21 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 22 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 23 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 24 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 25 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 26 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 27 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 28 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 29 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 30 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 31 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 32 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 33 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 34 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 35 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 36 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 37 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 38 = 1
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#28000 //Data 39 = 0
			w1r <= 1'b0;	
		#50000 
			w1r <= 1'b1;		
		#70000 //Data 40 = 1
			w1r <= 1'b0;
		#10000
			w1_en <= 1'b0; 
	   #1200000
		    TX_data = 1;
end 
	
initial begin
	clk = 0;
	forever clk = #(Tt/2) ~clk;
end

initial begin
	clk_1M = 0;
	forever clk_1M = #(1000/2) ~clk_1M;
end
	
assign data = w1_en ? w1r : 1'bZ;  
	
endmodule 