`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: The Fighting Meerkat, Wenting Zhang
// 
// Create Date:    11:41:00 11/11/2013 
// Design Name: 
// Module Name:    dvi_module 
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
module vga_input(  
    input clk,
    input rst,
    inout decoder_sda, 
    inout decoder_scl,            
    input vga_pixel_clk, 
    input vga_hsync, 
    input vga_vsync,
    input [7:0] vga_pixel_r, 
    input [7:0] vga_pixel_b,
    input [7:0] vga_pixel_g,
    output vga_sync_out,
    input [4:0] vga_phase,
    output seq_wr_en,
    output seq_wr_clk,
    output [15:0] seq_wr_data,
    output iic_done //TEST
    );

    iic_init #(.CLK_RATE_MHZ(35)) init (
        // Outputs
        .Done  (iic_done),  
        // Inouts
        .SDA  (decoder_sda),
        .SCL  (decoder_scl),
        // Inputs
        .Clk  (clk),
        .Reset  (rst),
        .Phase (vga_phase)
    );
    
    wire vs_in = ~vga_vsync;
    wire hs_in = ~vga_hsync;
    wire pclk_in = vga_pixel_clk;
    
    reg [10:0] x_counter; // 0-2047
    reg [10:0] y_counter; 
    reg hs_last;
    reg vs_last;
    
    // Intel HD: 146, 36
    // nVIDIA GTX: 156, 44
    localparam x_offset = 11'd156;
    localparam y_offset = 11'd44;
    localparam x_size = 11'd640;
    localparam y_size = 11'd480;
    
    wire x_valid = ((x_counter >= x_offset)&&(x_counter < (x_offset + x_size))) ? 1 : 0;
    wire y_valid = ((y_counter >= y_offset)&&(y_counter < (y_offset + y_size))) ? 1 : 0;
    wire [10:0] x_position = (x_valid) ? (x_counter - x_offset) : 11'd0;
    wire [10:0] y_position = (y_valid) ? (y_counter - y_offset) : 11'd0;
    
    reg hs_sync_1;
    reg hs_sync_2;
    reg vs_sync_1;
    reg vs_sync_2;
    
    always@(posedge pclk_in)
    begin
        if (rst) begin
            vs_last <= 0;
            hs_last <= 0;
            x_counter <= 0;
            y_counter <= 0;
            hs_sync_1 <= 0;
            hs_sync_2 <= 0;
            vs_sync_1 <= 0;
            vs_sync_2 <= 0;
        end
        else begin
            hs_sync_1 <= hs_in;
            hs_sync_2 <= hs_sync_1;
            vs_sync_1 <= vs_in;
            vs_sync_2 <= vs_sync_1;
            hs_last <= hs_sync_2;
            vs_last <= vs_sync_2;
            if ((hs_last == 1'b0)&&(hs_sync_2 == 1'b1)) begin
                x_counter <= 0;
                y_counter <= y_counter + 1;
            end else
                x_counter <= x_counter + 1;
            if ((vs_last == 1'b0)&&(vs_sync_2 == 1'b1)) begin
                y_counter <= 0;
            end
        end
    end
    
    assign seq_wr_en = (x_valid & y_valid);
    assign seq_wr_clk = vga_pixel_clk;
    assign seq_wr_data = {vga_pixel_r[7:3], vga_pixel_g[7:2], vga_pixel_b[7:3]};
    //assign vga_sync_out = ((y_counter >= 0) && (y_counter <= 64)) ? 1'b1 : 1'b0;
    assign vga_sync_out = ~vga_vsync;

endmodule
