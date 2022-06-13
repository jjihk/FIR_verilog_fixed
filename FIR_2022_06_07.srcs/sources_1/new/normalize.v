`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/23 10:03:30
// Design Name: 
// Module Name: normalize
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - ile Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module normalize
#(parameter num_of_ch = 64, num_of_tap = 350)
(
    input clk,
    input reset_n,
    input in_valid,
    input [7:0] in_ch,
    input [30:0] add,
    
    output [15:0] y,
    output done,
    output [7:0] out_ch,
    output round_error
    );
    
    reg check_overflow;
    reg r_round_error;    
    reg r_done;
    reg [7:0] r_out_ch;
    reg [15:0] r_y;

    
    assign y = (out_ch < num_of_ch) ? r_y : 16'd0;
    assign done = (out_ch < num_of_ch) ? r_done : 1'd0;
    assign out_ch = r_out_ch;
    assign round_error = r_round_error;

    always @ (posedge clk or negedge reset_n)begin
        if(~reset_n)begin
            r_done<=1'd0;
            r_out_ch <= 8'd0;
        end
        else begin
            if(in_valid)begin
                r_done<=in_valid;
                r_out_ch <= in_ch;
            end
            else begin
                r_done<=1'd0;
                r_out_ch<=8'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n)begin
        if(~reset_n)begin
            r_y<=16'd0;
            check_overflow <= 1'd0;
        end
        else begin
            if(in_valid)begin
                if(add[30])begin
                    if(add[14])begin
                        r_y <= add[30:15]+16'd1;
                        check_overflow <= add[30];
                    end
                    else begin
                        r_y <= add[30:15];
                        check_overflow <= add[30];
                    end
                end
                else begin
                    if(add[14:0] <= 15'h4000 && add[14:0] > 15'h0000)begin
                        r_y <= add[30:15] - 16'd1;
                        check_overflow <= add[30];
                    end
                    else begin
                        r_y <= add[30:15];
                        check_overflow <= add[30];
                    end
                end
            end
            else begin
                r_y<=16'd0;
                check_overflow <= 1'd0;
            end
        end
    end

    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_round_error<=1'd0;
        end
        else begin
            if(r_done)begin
                if(check_overflow != r_y[15])begin
                    r_round_error <= 1'd1;
                end
                else begin
                    r_round_error <= r_round_error;
                end
            end
            else begin
                r_round_error <= r_round_error;
            end
        end
    end


 

endmodule
