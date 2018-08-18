`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:53:22 08/16/2018 
// Design Name: 
// Module Name:    gldp_lut 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module gldp_lut(
    input rst,
    input flm,
    input [4:0] raw_in,
    output reg dither_out
    );

    reg       gldp_counter_length_2;
    reg [1:0] gldp_counter_length_3;
    reg [1:0] gldp_counter_length_4;
    reg [2:0] gldp_counter_length_5;
    reg [2:0] gldp_counter_length_6;
    reg [2:0] gldp_counter_length_7;
    reg [2:0] gldp_counter_length_8;
    reg [3:0] gldp_counter_length_9;
    reg [3:0] gldp_counter_length_10;
    reg [3:0] gldp_counter_length_11;
    reg [3:0] gldp_counter_length_13;
    reg [3:0] gldp_counter_length_15;
    reg [4:0] gldp_counter_length_24;
    
    always @(posedge flm, posedge rst)
    begin
        if (rst) begin
            gldp_counter_length_2 <= 0;
            gldp_counter_length_3 <= 0;
            gldp_counter_length_4 <= 0;
            gldp_counter_length_5 <= 0;
            gldp_counter_length_6 <= 0;
            gldp_counter_length_7 <= 0;
            gldp_counter_length_8 <= 0;
            gldp_counter_length_9 <= 0;
            gldp_counter_length_10 <= 0;
            gldp_counter_length_11 <= 0;
            gldp_counter_length_13 <= 0;
            gldp_counter_length_15 <= 0;
            gldp_counter_length_24 <= 0;
        end
        else begin
            gldp_counter_length_2 <= ~gldp_counter_length_2;
            if (gldp_counter_length_3 != 2'd2) gldp_counter_length_3 <= gldp_counter_length_3 + 1; else gldp_counter_length_3 <= 0;
            gldp_counter_length_4 <= gldp_counter_length_4 + 1;
            if (gldp_counter_length_5 != 3'd4) gldp_counter_length_5 <= gldp_counter_length_5 + 1; else gldp_counter_length_5 <= 0;
            if (gldp_counter_length_6 != 3'd5) gldp_counter_length_6 <= gldp_counter_length_6 + 1; else gldp_counter_length_6 <= 0;
            if (gldp_counter_length_7 != 3'd6) gldp_counter_length_7 <= gldp_counter_length_7 + 1; else gldp_counter_length_7 <= 0;
            gldp_counter_length_8 <= gldp_counter_length_8 + 1;
            if (gldp_counter_length_9 != 4'd8) gldp_counter_length_9 <= gldp_counter_length_9 + 1; else gldp_counter_length_9 <= 0;
            if (gldp_counter_length_10 != 4'd9) gldp_counter_length_10 <= gldp_counter_length_10 + 1; else gldp_counter_length_10 <= 0;
            if (gldp_counter_length_11 != 4'd10) gldp_counter_length_11 <= gldp_counter_length_11 + 1; else gldp_counter_length_11 <= 0;
            if (gldp_counter_length_13 != 4'd12) gldp_counter_length_13 <= gldp_counter_length_13 + 1; else gldp_counter_length_13 <= 0;
            if (gldp_counter_length_15 != 4'd14) gldp_counter_length_15 <= gldp_counter_length_15 + 1; else gldp_counter_length_15 <= 0;
            if (gldp_counter_length_24 != 5'd23) gldp_counter_length_24 <= gldp_counter_length_24 + 1; else gldp_counter_length_24 <= 0;
        end
    end
    
    wire [9-1: 0] gldp_pattern_1  =  9'b000000001;
    wire [8-1: 0] gldp_pattern_2  =  8'b00000001;
    wire [7-1: 0] gldp_pattern_3  =  7'b0000001;
    wire [6-1: 0] gldp_pattern_4  =  6'b000001;
    wire [5-1: 0] gldp_pattern_5  =  5'b00001;
    wire [4-1: 0] gldp_pattern_6  =  4'b0001;
    wire [7-1: 0] gldp_pattern_7  =  7'b0001001;
    wire [10-1:0] gldp_pattern_8  = 10'b0001001001;
    wire [3-1: 0] gldp_pattern_9  =  3'b001;
    wire [8-1: 0] gldp_pattern_10 =  8'b01001001;
    wire [5-1: 0] gldp_pattern_11 =  5'b00101;
    wire [9-1: 0] gldp_pattern_12 =  9'b001010101;
    wire [13-1:0] gldp_pattern_13 = 13'b0010101010101;
    wire [2-1: 0] gldp_pattern_14 =  2'b01;
    wire [13-1:0] gldp_pattern_15 = 13'b0101011001011;
    wire [9-1: 0] gldp_pattern_16 =  9'b101010101;
    wire [5-1: 0] gldp_pattern_17 =  5'b10101;
    wire [11-1:0] gldp_pattern_18 = 11'b01101101101;
    wire [3-1: 0] gldp_pattern_19 =  3'b011;
    wire [13-1:0] gldp_pattern_20 = 13'b1101101101101;
    wire [11-1:0] gldp_pattern_21 = 11'b11101110110;
    wire [4-1: 0] gldp_pattern_22 =  4'b1110;
    wire [9-1: 0] gldp_pattern_23 =  9'b111011101;
    wire [5-1: 0] gldp_pattern_24 =  5'b11011;
    wire [6-1: 0] gldp_pattern_25 =  6'b111011;
    wire [7-1: 0] gldp_pattern_26 =  7'b0111111;
    wire [9-1: 0] gldp_pattern_27 =  9'b011111111;
    wire [11-1:0] gldp_pattern_28 = 11'b01111111111;
    wire [15-1:0] gldp_pattern_29 = 15'b011111111111111;
    wire [24-1:0] gldp_pattern_30 = 24'b011111111111111111111111;
    
    always @(*) begin
        case (raw_in)
            5'd0:  dither_out = 1'b0;
            5'd1:  dither_out = gldp_pattern_1[gldp_counter_length_9];
            5'd2:  dither_out = gldp_pattern_2[gldp_counter_length_8];
            5'd3:  dither_out = gldp_pattern_3[gldp_counter_length_7];
            5'd4:  dither_out = gldp_pattern_4[gldp_counter_length_6];
            5'd5:  dither_out = gldp_pattern_5[gldp_counter_length_5];
            5'd6:  dither_out = gldp_pattern_6[gldp_counter_length_4];
            5'd7:  dither_out = gldp_pattern_7[gldp_counter_length_7];
            5'd8:  dither_out = gldp_pattern_8[gldp_counter_length_10];
            5'd9:  dither_out = gldp_pattern_9[gldp_counter_length_3];
            5'd10: dither_out = gldp_pattern_10[gldp_counter_length_8];
            5'd11: dither_out = gldp_pattern_11[gldp_counter_length_5];
            5'd12: dither_out = gldp_pattern_12[gldp_counter_length_9];
            5'd13: dither_out = gldp_pattern_13[gldp_counter_length_13];
            5'd14: dither_out = gldp_pattern_14[gldp_counter_length_2];
            5'd15: dither_out = gldp_pattern_15[gldp_counter_length_13];
            5'd16: dither_out = gldp_pattern_16[gldp_counter_length_9];
            5'd17: dither_out = gldp_pattern_17[gldp_counter_length_5];
            5'd18: dither_out = gldp_pattern_18[gldp_counter_length_11];
            5'd19: dither_out = gldp_pattern_19[gldp_counter_length_3];
            5'd20: dither_out = gldp_pattern_20[gldp_counter_length_13];
            5'd21: dither_out = gldp_pattern_21[gldp_counter_length_11];
            5'd22: dither_out = gldp_pattern_22[gldp_counter_length_4];
            5'd23: dither_out = gldp_pattern_23[gldp_counter_length_9];
            5'd24: dither_out = gldp_pattern_24[gldp_counter_length_5];
            5'd25: dither_out = gldp_pattern_25[gldp_counter_length_6];
            5'd26: dither_out = gldp_pattern_26[gldp_counter_length_7];
            5'd27: dither_out = gldp_pattern_27[gldp_counter_length_9];
            5'd28: dither_out = gldp_pattern_28[gldp_counter_length_11];
            5'd29: dither_out = gldp_pattern_29[gldp_counter_length_15];
            5'd30: dither_out = gldp_pattern_30[gldp_counter_length_24];
            5'd31: dither_out = 1'b1;
        endcase
    end

endmodule
