`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2024 14:57:37
// Design Name: 
// Module Name: uarttx
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


module uarttx(
    input clk,
    input [7:0] datain,
    input wrsig,
    output idle,
    output tx
    );
    
reg idle, tx;
reg send;
reg wrsigbuf, wrsigrise;
//reg presult;
reg[15:0] cnt;             //счетчик
//parameter paritymode = 1'b0;
parameter speed = 16'd434;
//Проверьте, действительна ли команда отправки
always @(posedge clk)
begin
   wrsigbuf <= wrsig;
   wrsigrise <= (~wrsigbuf) & wrsig;
end

always @(posedge clk)
begin
  if (wrsigrise &&  (~idle))  //Когда команда отправки действительна и строка неактивна, запустите новый процесс передачи данных
  begin
     send <= 1'b1;
  end
  else if(cnt == speed*10)      //Передача данных с одним кадром 
  begin
     send <= 1'b0;
  end
end

always @(posedge clk)
begin
  if(send == 1'b1)  begin
    case(cnt)                 //Сгенерировать стартовый бит
    16'd0: begin
         tx <= 1'b0;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed: begin//было208
         tx <= datain[0];    //Отправить данные 0 бит
         //presult <= datain[0]^paritymode;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*2: begin//было417
         tx <= datain[1];    //????1?
         //presult <= datain[1]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*3: begin//было625
         tx <= datain[2];    //????2?
         //presult <= datain[2]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*4: begin//было833
         tx <= datain[3];    //????3?
         //presult <= datain[3]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*5: begin//было1042
         tx <= datain[4];    //????4?
         //presult <= datain[4]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*6: begin//было1250
         tx <= datain[5];    //????5?
         //presult <= datain[5]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*7: begin//было1458
         tx <= datain[6];    //????6?
         //presult <= datain[6]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*8: begin//было1667
         tx <= datain[7];    //????7?
         //presult <= datain[7]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
   /* 
   16'd1875: begin//было1875
         tx <= presult;      //???????
         //presult <= datain[0]^paritymode;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    */
    speed*9: begin//было2083
         tx <= 1'b1;         //?????             
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    speed*10: begin//было2187
         tx <= 1'b1;             
         idle <= 1'b0;       //Передача данных с одним кадром
         cnt <= cnt + 8'd1;
    end
    default: begin
          cnt <= cnt + 8'd1;
    end
   endcase
  end
  else  begin
    tx <= 1'b1;
    cnt <= 16'd0;
    idle <= 1'b0;
  end
end

endmodule
