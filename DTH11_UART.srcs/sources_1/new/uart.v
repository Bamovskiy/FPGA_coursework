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



reg lsb;  // ������ �������� ������ ����� 12 ������ �������



initial begin

lsb <= 1'b0;

end



//===================================================================================
always @(posedge clk50m )
begin
  	 case(state)
	 STATE_IDLE: begin     
	   if ( tx_en == 1'b1 ) begin
		   tx_status <= 1'b1; //�������� �������� 
         state<=STATE_DELAY;  //�������� ���� ������
       end
	 end
	 STATE_DELAY: begin //�������� 
	   if(uart_cnt < 3000) begin
         uart_cnt <= uart_cnt + 1'b1;
       end
       else begin
         uart_cnt <= 16'd0;
         state<=STATE_START;
       end
	 end
	 STATE_START: begin //�������� ���� ������� ������   
	     
       if(uart_cnt == 16'd0) begin
         txdata <= 8'd68; //������ "D" data
         wrsig <= 1'b1;
         uart_cnt <= uart_cnt + 1'b1;
       end
         else if(uart_cnt == 6510) begin
       	uart_cnt <= 16'b0;
		   wrsig <= 1'b0;
			wren <= 1'b0;
			address <= 13'd0;
		   state<=STATE_READ; //��������� � �������� ������ �� ������	 
         end
         else begin			
		   uart_cnt <= uart_cnt + 1'b1;
		   wrsig <= 1'b0;  
	     end
	 end	
	 STATE_READ: begin                        
         if (bc == LEN ) begin          	//��������� 26-� ������		 
				uart_cnt <= 16'd0;
				wrsig <= 1'b0; 				
			   state <= STATE_COMPLETE;
			   bc<=13'b0; 
			end
			else begin                      //��������� ������ 25 ��������
				   if(uart_cnt ==0) begin      
                     if ( lsb == 1'b0 ) begin //1�� �����					  
					   
					   txdata <= q[15:8];//��� + 4'b0000 � ������ [11:8] (������ 4 ����� � ���� ������� � ��������� 8���� � ������)
					   //txdata <= q[11:8]+ 4'b0000;
					   
					   uart_cnt <= uart_cnt + 1'b1;
					   wrsig <= 1'b1;
					   lsb <= 1'b1;
					 end
					   else begin
						 txdata <= q[7:0];//��� + ������ � ������ [7:0] (������ 4 ����� � ���� ������� � ��������� 8���� � ������)
						 //txdata <= q[7:0];					 
					     uart_cnt <= uart_cnt + 1'b1;
					     wrsig <= 1'b1;
					     address <= bc + 1'b1;				     
					     lsb <= 1'b0;  
					   end                			
				   end	
				   else if(uart_cnt == 6510) begin //���� ���� ������������ ��� 168 �����. ��������� 255 �����, ����� ���������, ��� ���� �������� ������ ���������
					  uart_cnt <= 16'd0;
					  wrsig <= 1'b0;
					  if ( lsb == 1'b0 ) begin 
					    bc <= bc + 1'b1; //�������� ���� ����
					  end				
				   end
				   else	begin			
					   uart_cnt <= uart_cnt + 1'b1;
					   wrsig <= 1'b0;  
				   end
		   end	 
	 end
	 STATE_COMPLETE: begin       //������� finish	 
		 	state <= STATE_IDLE;
		 	tx_status <= 1'b0; 
	 end
	 default:state <= STATE_IDLE;
    endcase 
end

endmodule
