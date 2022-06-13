`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/16 11:23:41
// Design Name: 
// Module Name: int_to_float
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


module in_wide
#(parameter num_of_ch = 64, num_of_tap = 350)
(
input clk,
input d_valid,
input [15:0] in,
input reset_n,
output signed [30:0] w_in,
output ena,
output wea,
output [16:0] addra,
output done
    );
    
    
    reg signed [30:0] r_w_in;
    reg [7:0] ch;
    reg r_d_valid;
    reg [16:0] r_addra; 
    
    reg r_ena;
    reg start;
   

    assign wea = 1'b1;    
    assign addra = r_addra;
    assign w_in = r_w_in;
    assign done = (start)?~ena:1'd0;
    assign ena = r_ena;
    
    
    always @ (posedge  clk or negedge reset_n) begin
        if(!reset_n) begin
            ch <= 8'd0;
        end
        else begin
            if(d_valid)begin           
                if(ch >= (num_of_ch-1))begin             
                    ch <= 8'd0;              
                end
                else begin
                    ch <= ch + 8'd1;
                end
            end
            else begin
                ch<=0;
            end
        end    
    end
   
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_ena <= 1'd0;
        end
        else begin
            if(d_valid)begin
                r_ena<=1'd1;
            end
            else begin
                r_ena <= 1'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            r_addra <= 17'd0;
        end
        else begin
            r_addra <= {ch,9'd0};
        end
    end
    
    always @ (posedge clk or negedge reset_n)begin
        if(~reset_n)begin
            start <=1'd0;
        end
        else begin
            if(ena)begin
                start<=1'd1;
            end
            else begin
                start <= start;
            end
        end
    end
    

    always @ ( posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_w_in <= 22'b0;
        end
        else begin
            if(d_valid)begin
                r_w_in <= {in,15'd0};
            end
            else begin
                r_w_in <= r_w_in;
            end
        end
    end
    


endmodule