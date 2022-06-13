`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/19 16:41:33
// Design Name: 
// Module Name: adder_1
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


module adder
#(parameter num_of_ch = 64, num_of_tap = 350)
(
    input clk,
    input reset_n,
    input [30:0] in,
    input in_valid,
    input [7:0] in_ch,
    
    output signed [30:0] add,
    output done,
    output [7:0] out_ch,
    output error_ch_add
    );
    localparam min_ch = 4;
    
    reg valid_delay;
    
    reg signed [30:0] acc [num_of_ch-1 :0];
    
    reg signed [30:0] a0;   
    reg signed [30:0] b0;
    
    reg signed [30:0] r_add;
    reg [8:0] tap;
    reg [7:0] ch;
    reg r_out_valid;
    
    reg [1:0] check_overflow;
    reg r_error_ch_add;
    
    

    assign add = r_add;
    assign done = (tap == num_of_tap -1)? 1'd1 : 1'd0;
    assign out_ch = ch;
    assign error_ch_add = r_error_ch_add;
        
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            ch <= 8'd0;
        end
        else begin
            if(r_out_valid)begin
                if(num_of_ch < min_ch)begin
                    if(ch >= (min_ch-1))begin
                        ch<=8'd0;
                    end
                    else begin
                        ch <= ch + 8'd1;
                    end
                end
                else begin
                    if(ch >= (num_of_ch-1))begin
                        ch<=8'd0;
                    end
                    else begin
                        ch <= ch + 8'd1;
                    end
                end
            end
            else begin
                ch<=8'd0;
            end
        end
    end
    
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            tap <= 9'd0;
        end
        else begin
            if(r_out_valid)begin
                if(num_of_ch<min_ch)begin
                    if( ch == (min_ch -1))begin
                        if(tap >= (num_of_tap -1))begin
                            tap <= 9'd0;                
                        end
                        else begin
                            tap <= tap + 9'd1;
                        end
                    end
                    else begin
                        tap <= tap;
                    end
                
                end
                else begin
                    if( ch == (num_of_ch -1))begin
                        if(tap >= (num_of_tap -1))begin
                            tap <= 9'd0;                
                        end
                        else begin
                            tap <= tap + 9'd1;
                        end
                    end
                    else begin
                        tap <= tap;
                    end
                end
            end
            else begin
                tap<=9'd0;
            end
        end
    end
    
    genvar i;
    generate
        for(i=0; i<num_of_ch; i=i+1) begin
            always @ (posedge clk or negedge reset_n)begin
                if(~reset_n) begin
                    acc[i]<=31'd0;
                end
                else begin
                    if(r_out_valid)begin
                        if(i == ch)begin
                            acc[i] <= r_add;
                        end
                        else begin
                            acc[i] <= acc[i];
                        end
                    end
                    else begin
                        acc[i] <= 31'd0;
                    end
                end
            end

        end
        
    endgenerate
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            a0<=31'd0;
        end
        else begin
            if(in_valid)begin
                a0<=in;
            end
            else begin
                a0<=31'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            b0<=31'd0;
        end
        else begin
            if(in_valid)begin
                if(in_ch<num_of_ch)begin
                    b0 <= acc[in_ch ];
                end
                else begin
                    b0<=31'd0;
                end  
            end
            else begin
                b0<=31'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_add<=31'd0;
            check_overflow <= 2'b10;
        end
        else begin
            r_add<= a0 + b0;
            check_overflow <= {a0[30],b0[30]};
        end
    end

    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_error_ch_add <= 1'd0;
        end
        else begin

                if((check_overflow == 2'b00 && r_add[30] == 1'b1) || (check_overflow == 2'b11 && r_add[30] == 1'b0))begin
                    r_error_ch_add <= 1'd1;
                end
                else begin
                    r_error_ch_add<=r_error_ch_add;
                end

        end   
    end

    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            valid_delay <= 1'd0;
            r_out_valid <= 1'd0;
        end
        else begin
            valid_delay <= in_valid;
            r_out_valid <= valid_delay;
        end
    end
endmodule