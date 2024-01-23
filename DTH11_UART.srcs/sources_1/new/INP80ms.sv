`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2024 16:26:22
// Design Name: 
// Module Name: INP80ms
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


module INP80ms(
    clk, rst, btn, signal
    );
    
//inputs
input logic clk, rst, btn;

//outputs
output logic signal;

//Counter
logic flag;
logic [20:0] cnt;
logic signal_cnt;

always_ff @(posedge clk)
    begin
        if (rst)
            begin
                cnt <= 21'd0;
                signal_cnt <= 1'd0;
                flag <= 1'd1;
            end
        if (btn)
            begin
                flag <= 1'd1;
                signal_cnt <= 1'd0;
            end            
        if (flag) 
                cnt <= cnt + 21'd1;
        if (cnt == 21'd1800000)
            begin
                signal_cnt <= 1'd1;
                flag <= 1'd0;
                cnt <= 21'd0;
            end
         else
                signal_cnt <= 1'd0;
     end
     
assign signal = signal_cnt;

endmodule
