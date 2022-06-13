`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/18 13:25:53
// Design Name: 
// Module Name: tb_top
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


module tb_top
#(parameter num_of_ch = 5, num_of_tap = 350)
    (

    );
    
    reg clk;
    reg data_clk;
    reg reset_n;
    reg signed [15:0] in;
    reg signed [15:0] sine;
    reg [15:0] count;
    reg d_valid;
    
    wire signed [15:0] y;
    wire [7:0] ch;
    wire [15:0] cvt_y [num_of_ch-1:0];
    reg r_d_valid;
    wire done;
  
    reg [15:0] sine100 [324:0];
    reg [15:0] sine300 [324:0];
    reg [15:0] sine2k [64:0];
    reg [15:0] sine3k [64:0];
    reg [15:0] sine4k [64:0];
    reg [15:0] d_sine [4:0];
        reg [15:0] test_count;

    
    always @ (posedge data_clk or negedge reset_n) begin
        if(~reset_n) begin
            d_sine[0] <= 16'd0;
            d_sine[1] <= 16'd0;
            d_sine[2] <= 16'd0;
            d_sine[3] <= 16'd0;
            d_sine[4] <= 16'd0;
        end
        else begin
            d_sine[0] <= sine100[0];
            d_sine[1] <= sine300[0];
            d_sine[2] <= sine2k[0];
            d_sine[3] <= sine3k[0];
            d_sine[4] <= sine4k[0];        
        end
    end
    
    always @ (*) begin
        case (count%5)
        ///////////////////////////////////// constant input
          /*
        (3'd0) : sine <= 16'd10000;
        //(3'd0) : sine <= 16'd1;
        (3'd1) : sine <= 16'd10000;
        (3'd2) : sine <= 16'd10000;
        (3'd3) : sine <= 16'd10000;
        (3'd4) : sine <= 16'd10000;
        default sine <= 16'd0;
         */
        ////////////////////////////////////////////////sine input 100 300 2k 3k 4k
        // /*
        (3'd0) : sine <= d_sine[0];
        (3'd1) : sine <= d_sine[1];
        (3'd2) : sine <= d_sine[2];
        (3'd3) : sine <= d_sine[3];
        (3'd4) : sine <= d_sine[4];
        default sine <= d_sine[0];
        //*/
        endcase
    end 
    
    
    /*
    to check the real value, we have to convert 16 bit floating to 32 bit single
    precision floating point.
    otherwise, we only see zeros in simulation
    */
    genvar i;
    generate 
        for(i=0; i<num_of_ch ; i=i+1)begin       
            assign cvt_y[i] = ((ch == i && done) || (~reset_n)) ? y : cvt_y[i];        
        end
    endgenerate
    

    
    always @ (posedge data_clk or negedge reset_n)begin
        if(~reset_n)begin
            test_count <= 0;
        end
        else begin
            test_count <= test_count + 1;
        end
    end
    
    top
    #(.num_of_ch(num_of_ch), .num_of_tap(num_of_tap))
    top (
    .clk(clk),
    .reset_n(reset_n),
    .in(in),
    .d_valid(d_valid),
    .y(y),
    .ch(ch),
    .done(done)
    );
    
    initial begin
    clk = 0;
    data_clk =0;
    reset_n = 0;

    #1 reset_n = 1;
    


    
    end
    
    always 
    #0.5 clk = ~clk;
    
    
    //////////////data sampling freq is 32.5k samples / sec
    always
    #15384 data_clk = ~ data_clk;
    
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            in <= 16'd0;
            r_d_valid <= 1'd0;
            count <= 16'd0;
        end
        else begin
            if(count >= num_of_ch -1)begin
                in <= sine;
                r_d_valid <= 1'd0;
                count<=16'd0;
                @ (posedge data_clk) begin
                r_d_valid <= 1'd1;
                count<=16'd0;
                in <= sine;
                end
            end
            else begin
                in <= sine;
                count<= count + 16'd1;
                r_d_valid <= r_d_valid;
            end
        end
    end



    always @ (posedge clk or negedge reset_n)begin
        if(~reset_n)begin
            d_valid <= 1'd0;
        end
        else begin
            d_valid <= r_d_valid; 
        end
    end
////////////////////////////////////////////////////////////////////////////////
/*
functions bin->16bit floating, 16bit floating <-> 32bit floating.
only use in test_bench.
*/

   function [15:0] bin_to_half;
        input [15:0] a;
        reg [15:0]in;
        reg c[1:0];
        reg [3:0] lod;
        reg [14:0] sub;
        reg [4:0] subexp;
        begin
        
        if(~a[15])begin
            in = a;
        end
        else begin
            in = {1'd1, ~(a[14:0]-15'd1)};
        end
            c[0] = &(~in[14:7]);
            c[1] = &(~in[6:0]);
            if(c[0])begin
                if(c[1])begin
                    lod = 4'd15;
                end
                else begin
                    lod[0] = (~in[6]&in[5]) | (&(~in[6:4]) & in[3]) | (&(~in[6:2]) & in[1]);
                    lod[1] =  (&(~in[6:5])&in[4]) | (&(~in[6:4])&in[3]) | (&(~in[6:1]) & in[0]);
                    lod[2] = &(~in[6:3]);
                    lod[3] = 1'd1;
                end
            end
            else begin
                lod[0] = (~in[14]&in[13]) | (&(~in[14:12]) & in[11]) | (&(~in[14:10]) & in[9]) | (&(~in[14:8]) & in[7]);
                lod[1] =  (&(~in[14:13])&in[12]) | (&(~in[14:12])&in[11]) | (&(~in[14:9]) & in[8]) | (&(~in[14:8]) & in[7]);
                lod[2] = &(~in[14:11]);
                lod[3] = 1'd0;
            end             
            
           sub = in[14:0]<<(lod+1);
           subexp = (lod==15) ? 5'd0:5'd14+5'd15-lod;
           bin_to_half = {in[15],subexp, sub[14:5]};
   
        end
    endfunction
    
    
    function [31:0] half_to_single;
        input [15:0]out;
        begin
            if( out[14:10] == 5'b11111)begin
                half_to_single = 32'hzzzz_zzzz;
            end
            else if(out[14:10] == 5'b00000)begin
                half_to_single[31] = out[15];
                half_to_single[30:23] = 8'd0;
                half_to_single[22:0] = {out[9:0],{13{1'b0}}};
            end
            else begin
                half_to_single[31] = out[15];
                half_to_single[30:23] = out[14:10] + 8'd112;
                half_to_single[22:0] = {out[9:0],{13{1'b0}}};
            end
        end
    
    endfunction
    
    function [15:0]single_to_half;
        input[31:0]in;
        begin
        
            if(in[30:23] == 8'b00000000)begin
                single_to_half[15] = in[31];
                single_to_half[14:0] = 5'b0;
                single_to_half[9:0] = in[22:13];
            end
            else if(in[31:23] == 8'b11111111)begin
                single_to_half = 16'bz;
            end
            else begin
                single_to_half[15] = in[31];
                single_to_half[14:10] = in[30:23] - 8'd112;
                single_to_half[9:0] = in[22:13];
            end
        end
    
    endfunction
    

////////////////////////////////////////sine///////////////////////////////////////////////////////////////////
/*

Here are data for sine input.
***Before use, check the file address.
Mostly file names are 'sine(freq)' , sine2k means 2kHz sine signal.
*/


//////////////////////////////////////100Hz///////////////////////////////////////////////////////////////////////


initial begin
$readmemh("C:/Users/ADmin/Desktop/jihk/FIR_2022_06_07/FIR_2022_06_07_sinedata/sine100.txt", sine100);
end

genvar a;
   generate
   for(a=0; a<325; a=a+1)begin
        always @ (posedge data_clk or negedge reset_n)begin
            if(~reset_n)begin
                 sine100[a]<=sine100[a];
            end
            else begin
                if(a==0)begin
                    sine100[324] <= sine100[a];
                end
                else begin
                    sine100[a-1] <= sine100[a];
                end
            end
        end
   end
   endgenerate
    
//////////////////////////////////////////300Hz////////////////////////////////////////////////////////


initial begin
$readmemh("C:/Users/ADmin/Desktop/jihk/FIR_2022_06_07/FIR_2022_06_07_sinedata/sine300.txt", sine300);
end

genvar b;
generate
for(b=0; b<325; b=b+1)begin
     always @ (posedge data_clk or negedge reset_n)begin
         if(~reset_n)begin
              sine300[b]<=sine300[b];
         end
         else begin
             if(b==0)begin
                 sine300[324] <= sine300[b];
             end
             else begin
                 sine300[b-1] <= sine300[b];
             end
         end
     end
end
endgenerate
 
 
///////////////////////////////////////////////////2kHz/////////////////////////////////////////////


initial begin
$readmemh("C:/Users/ADmin/Desktop/jihk/FIR_2022_06_07/FIR_2022_06_07_sinedata/sine2k.txt", sine2k);
end

genvar c;
generate
for(c=0; c<65; c=c+1)begin
     always @ (posedge data_clk or negedge reset_n)begin
         if(~reset_n)begin
              sine2k[c]<=sine2k[c];
         end
         else begin
             if(c==0)begin
                 sine2k[64] <= sine2k[c];
             end
             else begin
                 sine2k[c-1] <= sine2k[c];
             end
         end
     end
end
endgenerate


///////////////////////////////////////////////////3kHz/////////////////////////////////////////////


initial begin
$readmemh("C:/Users/ADmin/Desktop/jihk/FIR_2022_06_07/FIR_2022_06_07_sinedata/sine3k.txt", sine3k);
end

genvar d;
generate
for(d=0; d<65; d=d+1)begin
     always @ (posedge data_clk or negedge reset_n)begin
         if(~reset_n)begin
              sine3k[d]<=sine3k[d];
         end
         else begin
             if(d==0)begin
                 sine3k[64] <= sine3k[d];
             end
             else begin
                 sine3k[d-1] <= sine3k[d];
             end
         end
     end
end
endgenerate


///////////////////////////////////////////////////4kHz/////////////////////////////////////////////

initial begin
$readmemh("C:/Users/ADmin/Desktop/jihk/FIR_2022_06_07/FIR_2022_06_07_sinedata/sine4k.txt", sine4k);
end

genvar e;
generate
for(e=0; e<65; e=e+1)begin
     always @ (posedge data_clk or negedge reset_n)begin
         if(~reset_n)begin
              sine4k[e]<=sine4k[e];
         end
         else begin
             if(e==0)begin
                 sine4k[64] <= sine4k[e];
             end
             else begin
                 sine4k[e-1] <= sine4k[e];
             end
         end
     end
end
endgenerate

endmodule
