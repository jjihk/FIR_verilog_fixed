`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/16 16:05:48
// Design Name: 
// Module Name: tb_brom
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


module tb_brom(

    );
    reg clk;
    reg [15:0]addra;
    reg wea;
    reg ena;
    wire [15:0]douta;
    
     blk_mem_gen_2 brom(
     .clka(clk),
     .ena(ena),
     .addra(addra),
     .wea(1'b0),
     .douta(douta)
     );
     
     
     initial begin
     clk =0;
     ena = 1;
     addra = 0;
     end
     
     always
     #0.5 clk = ~clk;
     
     
     always @(posedge clk) begin
        if(addra >=16'd100)begin
            addra <= 16'd0;
        end
        else begin
            addra <= addra + 16'd1;
        end
     end

endmodule
