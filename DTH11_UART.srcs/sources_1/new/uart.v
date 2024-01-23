`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2024 14:52:37
// Design Name: 
// Module Name: uart
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


module uart
#(
    parameter LEN = 4000,
    parameter ADDRW = 13
)
(
    input clk50m,
    output tx,
    output reg wren,
    output reg [ADDRW-1:0] address,
    input [15:0] q,
    input tx_en,
    output reg tx_status
);
    
localparam STATE_IDLE=4'd0,STATE_DELAY=4'd7, STATE_START=4'd1, STATE_READ=4'd2, STATE_COMPLETE=4'd3;
reg [3:0] state=STATE_IDLE;


reg [15:0] uart_cnt;

reg  [7:0]  txdata;             
reg         wrsig;              

reg [ADDRW-1:0] bc;				//buffer counter if == LEN then stop the transfer



reg lsb;  // флажок передачи второй части 12 битной посылки



initial begin

lsb <= 1'b0;

end



//===================================================================================
always @(posedge clk50m )
begin
  	 case(state)
	 STATE_IDLE: begin     
	   if ( tx_en == 1'b1 ) begin
		   tx_status <= 1'b1; //начинаем передачу 
         state<=STATE_DELAY;  //отправим спец символ
       end
	 end
	 STATE_DELAY: begin //задержка 
	   if(uart_cnt < 3000) begin
         uart_cnt <= uart_cnt + 1'b1;
       end
       else begin
         uart_cnt <= 16'd0;
         state<=STATE_START;
       end
	 end
	 STATE_START: begin //отправка спец символа начала   
	     
       if(uart_cnt == 16'd0) begin
         txdata <= 8'd68; //символ "D" data
         wrsig <= 1'b1;
         uart_cnt <= uart_cnt + 1'b1;
       end
         else if(uart_cnt == 6510) begin
       	uart_cnt <= 16'b0;
		   wrsig <= 1'b0;
			wren <= 1'b0;
			address <= 13'd0;
		   state<=STATE_READ; //переходим к передаче данных из памяти	 
         end
         else begin			
		   uart_cnt <= uart_cnt + 1'b1;
		   wrsig <= 1'b0;  
	     end
	 end	
	 STATE_READ: begin                        
         if (bc == LEN ) begin          	//Отправить 26-й символ		 
				uart_cnt <= 16'd0;
				wrsig <= 1'b0; 				
			   state <= STATE_COMPLETE;
			   bc<=13'b0; 
			end
			else begin                      //Отправьте первые 25 символов
				   if(uart_cnt ==0) begin      
                     if ( lsb == 1'b0 ) begin //1ая часть					  
					   
					   txdata <= q[15:8];//или + 4'b0000 в случае [11:8] (первые 4 байта в этой посылке и остальные 8байт в другой)
					   //txdata <= q[11:8]+ 4'b0000;
					   
					   uart_cnt <= uart_cnt + 1'b1;
					   wrsig <= 1'b1;
					   lsb <= 1'b1;
					 end
					   else begin
						 txdata <= q[7:0];//или + ничего в случае [7:0] (первые 4 байта в этой посылке и остальные 8байт в другой)
						 //txdata <= q[7:0];					 
					     uart_cnt <= uart_cnt + 1'b1;
					     wrsig <= 1'b1;
					     address <= bc + 1'b1;				     
					     lsb <= 1'b0;  
					   end                			
				   end	
				   else if(uart_cnt == 6510) begin //Один байт отправляется как 168 часов. Подождите 255 часов, чтобы убедиться, что одна передача данных завершена
					  uart_cnt <= 16'd0;
					  wrsig <= 1'b0;
					  if ( lsb == 1'b0 ) begin 
					    bc <= bc + 1'b1; //передали один байт
					  end				
				   end
				   else	begin			
					   uart_cnt <= uart_cnt + 1'b1;
					   wrsig <= 1'b0;  
				   end
		   end	 
	 end
	 STATE_COMPLETE: begin       //послать finish	 
		 	state <= STATE_IDLE;
		 	tx_status <= 1'b0; 
	 end
	 default:state <= STATE_IDLE;
    endcase 
end

endmodule
