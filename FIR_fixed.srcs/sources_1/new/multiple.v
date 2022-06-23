`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/16 17:47:05
// Design Name: 
// Module Name: shift
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


module multiple
#(parameter num_of_ch =8, num_of_tap = 350)
(
    input clk,
    input reset_n,
    input done,
    input signed [30:0] w_in,
    input [31:0] shift_control,
    
    output [12:0] addrb,
    output enb,
    output web,
    
    output [12:0] addra,
    output signed [30:0] dina,
    output ena,
    output wea,
    
    //coeff
    output [8:0] coef_addra,
    output coef_ena,
    output coef_wea,

    output valid,
    output signed [30:0] in_coef_mul,
    output [3:0] out_ch,
    output error_sub_add,
    output error_add

    );
    localparam min_ch = 4;
    
    reg [12:0] r_addrb;
    reg [12:0] r_addra;
    reg [8:0] coef_r_addra;  
    reg r_ena;
    reg r_enb;
    reg signed [30:0] r_dina;
    reg read_done;
    
    reg [12:0] delay_addrb [ num_of_ch +3 : 0];
    reg delay_enb [ num_of_ch  +3 :0];
    reg signed [30:0] delay_w_in [num_of_ch+2:0];
    reg [3:0] delay_ch[4:0];    
    
    reg [8:0] data_loc;
    reg [3:0] ch; 
    
    reg signed [30:0] r_shift [3:0];
    reg signed [30:0] sub_add[2:0];
    reg [1:0] check_overflow[2:0];

    wire shift_valid;
    reg sub_add_valid;
    
    reg r_error_sub_add;
    reg r_error_add;
    reg r_valid;
    reg [5:0]r_out_ch;
    
    wire [12:0] max_addra;
    
    assign shift_valid = (enb) ? delay_enb[2] : delay_enb[1];
    assign coef_ena = r_enb;
    assign ena = r_ena;
    assign enb = r_enb;
    assign coef_wea = 1'd0; //only read
    assign wea = 1'b1; //only write
    assign web = 1'd0; // only read
    assign coef_addra = coef_r_addra;
    assign addra = r_addra;
    assign addrb = r_addrb;
    assign dina = r_dina;

    assign valid = r_valid;
    assign in_coef_mul = sub_add[2];
    assign out_ch = r_out_ch;
    assign error_sub_add = r_error_sub_add;
    assign error_add = r_error_add;

    assign max_addra[12:9] = (num_of_ch <= min_ch-1) ? min_ch-1 : num_of_ch-1;
    assign max_addra[8:0] = num_of_tap-1;  
    
    
    //should turn-off bram portb after finishing read
    always @ (posedge  clk or negedge reset_n) begin
        if(~reset_n) begin
            read_done <= 1'd0;
        end
        else begin
            if(done) begin
                if(addrb >= max_addra)begin
                    read_done <= 1'd1;
                end
                else begin
                    read_done <= read_done;
                end
            end
            else begin
                read_done <= 1'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_enb <= 1'd0;
        end
        else begin
            if(done && ~read_done)begin
                r_enb <= 1'd1;                
            end
            else begin
                r_enb <= 1'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n)begin
        if(~reset_n) begin
            r_addrb <= 13'd0;
            coef_r_addra <= 8'd0;
        end
        else begin
            if(done) begin
                r_addrb <= {ch,data_loc};
                coef_r_addra <= data_loc;
            end
            else begin
                r_addrb <= 13'd0;
                coef_r_addra <= 8'd0;
            end
        end
    end
  
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            ch <= 4'd0;
        end
        else begin
            if(done)begin
                if(num_of_ch<=min_ch-1)begin
                    if(ch >= (min_ch-1))begin
                        ch <= 4'd0;
                    end
                    else begin
                        ch <= ch + 4'd1;
                    end
                end
                else begin
                    if(ch >= (num_of_ch-1))begin
                        ch <= 4'd0;
                    end
                    else begin
                        ch <= ch + 4'd1;
                    end                
                end
            end
            else begin
                ch <= 4'd0;
            end
        end
    end

    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            data_loc <= 8'd0;
        end
        else begin
            if(done)begin
                if(num_of_ch <= (min_ch -1))begin
                    if(ch >= (min_ch-1))begin
                        if(data_loc>=(num_of_tap-1))begin
                            data_loc<= 8'd0;                    
                        end
                        else begin
                            data_loc<=data_loc+8'd1;
                        end
                    end
                    else begin
                        data_loc<=data_loc;
                    end    
                end
                else begin
                    if(ch >= (num_of_ch-1))begin
                        if(data_loc>=(num_of_tap-1))begin
                            data_loc<= 8'd0;                    
                        end
                        else begin
                            data_loc<=data_loc+8'd1;
                        end
                    end
                    else begin
                        data_loc<=data_loc;
                    end
                end
            end
            else begin
                data_loc <= 8'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            sub_add_valid <= 1'd0;
        end
        else begin
            if(shift_valid)begin
                sub_add_valid <= 1'd1;
            end
            else begin
                sub_add_valid <= 1'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_valid <= 1'd0;
        end
        else begin
            if(sub_add_valid)begin
                r_valid <= 1'd1;
            end
            else begin
                r_valid <= 1'd0;
            end
        end
    end
    ///////////////////////////////////
    
    
    ////delay part
    genvar m;
    generate
        for(m=0;m<6;m=m+1)begin
        always @(posedge clk or negedge reset_n) begin
            if(~reset_n) begin
                if(m==5)begin
                    r_out_ch<=4'd0;
                end
                else begin
                    delay_ch[m]<=4'd0;
                end
            end
            else begin
                if(done) begin
                    if(m==0)begin
                        delay_ch[m]<=ch;
                    end
                    else if (m==5)begin
                        r_out_ch <= delay_ch[m-1];
                    end
                    else begin
                        delay_ch[m] <= delay_ch[m-1];
                    end
                end
                else begin
                    if(m==5)begin
                        r_out_ch<=4'd0;
                    end
                    else begin
                        delay_ch[m]<=4'd0;
                    end
                end
            end
        end
        end
    endgenerate
    
    
    /// data in addr0 move to addr1 =(z^(-1)), must save after reading 0001 from port b
    genvar i;
    generate
        for(i=0; i<=num_of_ch+4 ; i=i+1)begin
            always @ (posedge clk or negedge reset_n)begin
                if(~reset_n) begin
                    if(i == num_of_ch +4) begin
                        r_addra <= 13'd0;
                        r_ena <= 16'd0;
                    end
                    else begin
                        delay_addrb[i] <= 13'd0;
                        delay_enb[i] <= 1'd0;
                    end
                end
               else begin
                    if(i == 0)begin
                        delay_addrb[i] <= addrb;
                        delay_enb[i] <= enb;                    
                    end
                    else if(i == num_of_ch + 4)begin
                        if ( enb) begin //start ena 
                            r_addra <= delay_addrb[i-1]+13'd1; // add 1 mean z^(-1)
                            r_ena <= delay_enb[i-1]; 
                        end
                        else begin //end ena
                            r_addra <= delay_addrb[i-1]+13'd1;
                            r_ena <= delay_enb[i-2]; 
                        end
                    end
                     
                    else begin
                        delay_addrb[i] <= delay_addrb[i-1];
                        delay_enb[i] <= delay_enb[i-1];
                  
                    end
                end
                
            end
        end
    
    endgenerate
    
    
    genvar j;
    generate 
        for( j=0; j<=num_of_ch +2 ; j = j+1)begin
            always @ (posedge clk or negedge reset_n)begin
                if(~reset_n) begin
                    if(j == num_of_ch+2) begin
                        r_dina <= 22'd0;
                    end
                    else begin
                        delay_w_in[j] <= 22'd0;
                    end
                end
                else begin
                    if(j == 0)begin
                        delay_w_in[j] <= w_in;                 
                    end
                    else if(j == num_of_ch+2)begin
                        r_dina <= delay_w_in[j-1];
                    end
                     
                    else begin
                        delay_w_in[j] <= delay_w_in[j-1];
                    end
                end
                
            end
        end
    endgenerate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// shift
    genvar k;
    generate
        for(k=0; k<4; k=k+1)begin
        always @ (posedge clk or negedge reset_n)begin
            if(~reset_n)begin
                r_shift[k]<=31'd0;
            end
            else begin
                if(done)begin
                    if((shift_control[7+(k*8):0+(k*8)] == 8'd0))begin
                        r_shift[k]<=31'd0;
                    end
                    else begin
                        if(shift_control[7+(k*8):4+(k*8)]==4'd1)begin
                            r_shift[k] <= -{w_in>>>shift_control[3+(k*8):0+(k*8)]};
                        end
                        else begin
                            r_shift[k] <= {w_in>>>shift_control[3+(k*8):0+(k*8)]};
                        end
                    end
               end
               else begin
                    r_shift[k]<=22'd0;
               end
            end
        end
        end
    endgenerate
    
////add   
    genvar l;
    generate
        for(l=0;l<2;l=l+1)begin
        always @ (posedge clk or negedge reset_n) begin
            if(~reset_n) begin
                sub_add[l]<=31'd0;
                check_overflow[l] <= 2'b10;
            end
            else begin
                if(shift_valid)begin
                    sub_add[l]<=r_shift[l*2]+r_shift[(l*2)+1];
                    check_overflow[l] <= {r_shift[l*2][30],r_shift[l*2+1][30]};
                end
                else begin
                    sub_add[l] <= 31'd0;
                    check_overflow[l] <= 2'b10;
                end
            end
        end
        end
    endgenerate
   
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_error_sub_add <= 1'd0;
        end
        else begin
            if((check_overflow[0] == 2'b00 && sub_add[0][30] == 1'b1) || (check_overflow[0] == 2'b11 && sub_add[0][30] == 1'b0))begin
                r_error_sub_add <= 1'd1;
            end
            else if ((check_overflow[1] == 2'b00 && sub_add[1][30] == 1'b1) || (check_overflow[1] == 2'b11 && sub_add[1][30] == 1'b0))begin
                r_error_sub_add<=1'd1;
            end
            else begin
                r_error_sub_add<=r_error_sub_add;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            sub_add[2]<=31'd0;
            check_overflow[2] <= 2'b10;
        end
        else begin
            if(sub_add_valid)begin
                sub_add[2]<= sub_add[0] + sub_add[1];
                check_overflow[2] <= {sub_add[0][30],sub_add[1][30]};
                
            end
            else begin
                sub_add[2] <= 31'd0;
                check_overflow[2] <= 2'b10;
            end
        end
    end
    
    always @ (posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            r_error_add <= 1'd0;
        end
        else begin
            if((check_overflow[2] == 2'b00 && sub_add[2][30] == 1'b1) || (check_overflow[2] == 2'b11 && sub_add[2][30] == 1'b0))begin
                r_error_add <= 1'd1;
            end
            else begin
                r_error_add<=r_error_add;
            end
        end   
    end
endmodule