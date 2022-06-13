`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/16 15:23:10
// Design Name: 
// Module Name: top
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


module top
#(parameter num_of_ch = 64, num_of_tap = 350)
(
    input clk,
    input reset_n,
    input [15:0] in,
    input d_valid,
    
    output [7:0] ch,
    output [15:0] y,
    output done,
    output error_multiple_sub_add,
    output error_multiple_add,
    output error_ch_add,
    output round_error
    );
    
    wire in_shift_done;    
   
    wire ena;
    wire wea;
    wire [16:0] addra;
    wire [30:0] dina;
    wire [30:0] douta;
    
    wire i_ena;
    wire i_wea;
    wire [16:0] i_addra;
    wire [30:0] i_dina;
    wire [30:0] i_douta;

    wire s_ena;
    wire s_wea;
    wire [16:0] s_addra;
    wire [30:0] s_dina;
    wire [30:0] s_douta;    

    wire enb;
    wire web;
    wire [16:0] addrb;

    wire [30:0] doutb;


    wire [8:0] coef_addra;
    wire coef_ena;
    wire coef_wea;
    wire [31:0] shift_control;
    wire [31:0] coef_dina;

    wire mul_add_valid;
    wire signed [30:0] mul;
    wire [7:0] mul_add_ch;


        
    wire [30:0] add_out_norm_in;   
    wire add_norm_done;


    wire [7:0] norm_ch;



    
    assign ena = (in_shift_done)  ? s_ena :i_ena ;
    assign wea = (in_shift_done)  ? s_wea : i_wea ;
    assign addra = (in_shift_done)  ? s_addra : i_addra ;
    assign dina = (in_shift_done)  ? s_dina : i_dina ;
   // assign  douta = (in_shift_done)  ? s_douta :  i_douta;
 
    

    in_wide
    #(.num_of_ch(num_of_ch), .num_of_tap(num_of_tap))
    in_wide
    (
    .clk(clk),
    .d_valid(d_valid),
    .in(in),
    .reset_n(reset_n),
    .w_in(i_dina),
    .ena(i_ena),
    .wea(i_wea),
    .addra(i_addra),
    .done(in_shift_done)
    );
    
    blk_mem_gen_1 bram(
    .clka(clk),
    .ena(ena),
    .wea(wea),
    .addra(addra),
    .dina(dina),
    .douta(),

    
    
    .clkb(clk),
    .enb(enb),
    .web(web),
    .addrb(addrb),
    .dinb(),
    .doutb(doutb)
    );
    
    
    multiple 
    #(.num_of_ch(num_of_ch), .num_of_tap(num_of_tap))
    multiple(
    .clk(clk),
    .reset_n(reset_n),
    .done(in_shift_done),
    .w_in(doutb),
    .shift_control(shift_control),
    
    .addrb(addrb),
    .enb(enb),
    .web(web),

    
    .addra(s_addra),
    .ena(s_ena),
    .wea(s_wea),
    .dina(s_dina),
    
    .coef_addra(coef_addra),
    .coef_ena(coef_ena),
    .coef_wea(coef_wea),
    
    
    .valid(mul_add_valid),
    .in_coef_mul(mul),
    .out_ch(mul_add_ch),
    .error_sub_add(error_multiple_sub_add),
    .error_add(error_multiple_add)  

    );
    
    blk_mem_gen_2 brom(
    .clka(clk),
    .ena(coef_ena),
    .wea(coef_wea),
    .addra(coef_addra),
    .dina(),
    .douta(shift_control)
    );
    
    
    adder 
    #(.num_of_ch(num_of_ch), .num_of_tap(num_of_tap))
    adder (
    .clk(clk),
    .reset_n(reset_n),
    .in(mul),
    .in_valid(mul_add_valid),
    .in_ch(mul_add_ch),
    .add(add_out_norm_in),
    .done(add_norm_done),
    .out_ch(norm_ch),
    .error_ch_add(error_ch_add)
    );
    
    
    normalize 
    #(.num_of_ch(num_of_ch), .num_of_tap(num_of_tap))
    normalize(
    .clk(clk),
    .reset_n(reset_n),
    .in_valid(add_norm_done),
    .in_ch(norm_ch),
    .add(add_out_norm_in),
    
    .y(y),
    .out_ch(ch),
    .done(done),
    .round_error(round_error)   
    );
    


endmodule
