`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/17 10:52:29
// Design Name: 
// Module Name: tb_shift
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


module tb_shift(

    );
    
    reg clk;
    reg reset_n;
    reg done;
    
    wire [15:0] addrb;
    wire enb;
    wire web;
    wire [7:0] addra;
    wire ena;
    wire wea;
     
     
    shift shift(
    .clk(clk),
    .reset_n(reset_n),
    .done(done),
    .addrb(addrb),
    .addra(addra),
    .enb(enb),
    .web(web),
    .ena(ena),
    .wea(wea)
    
    );



    initial begin
    clk =0;
    reset_n = 0;
    done = 0;
    
    #5 reset_n = 1;
    
    end
    
    always 
    #0.5 clk = ~clk;
    
    
    always begin
    #100 done = 1;
    //# 20 done = 0;
    end
endmodule
