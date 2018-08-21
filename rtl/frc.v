`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:02:16 08/16/2018 
// Design Name: 
// Module Name:    frc 
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
module frc(
    input clk,
    input rst,
    output reg lcd_wr_en,
    output reg [5:0] lcd_wr_data,
    input lcd_wr_full,
    input lcd_wr_almost_full,
    output lcd_wr_clk,
    input [31:0] seq_rd_data,
    output reg seq_rd_en,
    input seq_rd_empty,
    output seq_rd_clk,
    input vsync
    );
    // x, y counter for chess pattern generation
    reg [9:0] x;
    reg [9:0] y;

    reg [15:0] upper_pixel;
    reg [15:0] lower_pixel;
    
    wire [4:0] upper_r = upper_pixel[15:11];
    wire [4:0] upper_g = upper_pixel[10:6];
    wire [4:0] upper_b = upper_pixel[4:0];
    wire [4:0] lower_r = lower_pixel[15:11];
    wire [4:0] lower_g = lower_pixel[10:6];
    wire [4:0] lower_b = lower_pixel[4:0];
    
    wire output_upper_r;
    wire output_upper_g;
    wire output_upper_b;
    wire output_lower_r;
    wire output_lower_g;
    wire output_lower_b;
    
    // GLDP
    gldp_lut gldp_lut_upper_r(
        .rst(rst),
        .flm(vsync),
        .raw_in(upper_r),
        .inv(x[0]^y[0]),
        .dither_out(output_upper_r)
    );
    
    gldp_lut gldp_lut_upper_g(
        .rst(rst),
        .flm(vsync),
        .raw_in(upper_g),
        .inv(x[0]^y[0]),
        .dither_out(output_upper_g)
    );
    
    gldp_lut gldp_lut_upper_b(
        .rst(rst),
        .flm(vsync),
        .raw_in(upper_b),
        .inv(x[0]^y[0]),
        .dither_out(output_upper_b)
    );
    
    gldp_lut gldp_lut_lower_r(
        .rst(rst),
        .flm(vsync),
        .raw_in(lower_r),
        .inv(x[0]^y[0]),
        .dither_out(output_lower_r)
    );

    gldp_lut gldp_lut_lower_g(
        .rst(rst),
        .flm(vsync),
        .raw_in(lower_g),
        .inv(x[0]^y[0]),
        .dither_out(output_lower_g)
    );
    
    gldp_lut gldp_lut_lower_b(
        .rst(rst),
        .flm(vsync),
        .raw_in(lower_b),
        .inv(x[0]^y[0]),
        .dither_out(output_lower_b)
    );

    wire [5:0] output_pixel = {output_upper_r, output_upper_g, output_upper_b, 
        output_lower_r, output_lower_g, output_lower_b};

    // Pipeline
    assign seq_rd_clk = ~clk;

    reg data_valid_next_clock;
    reg data_valid;

    // Stage 1: Fetch
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            data_valid <= 1'b0;
            data_valid_next_clock <= 1'b0;
        end
        else begin
            data_valid <= data_valid_next_clock;
            if ((!lcd_wr_almost_full)&&(!seq_rd_empty)) begin
                // Can fetch
                seq_rd_en <= 1'b1;
                data_valid_next_clock <= 1'b1;
            end
            else begin
                seq_rd_en <= 1'b0;
                data_valid_next_clock <= 1'b0;
            end
        end
    end

    // Stage 2: Process
    reg data_ready;
    reg vsync_last;
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            data_ready <= 1'b0;
            upper_pixel <= 16'b111110000000000;
            lower_pixel <= 16'b111110000000000; // should not be used
            x <= 0;
            y <= 0;
        end
        else begin
            if (data_valid) begin
                upper_pixel <= seq_rd_data[31:16];
                lower_pixel <= seq_rd_data[15:0];
                data_ready <= 1'b1;
                if ((vsync_last == 1'b0)&&(vsync == 1'b1)) begin
                    x <= 0;
                    y <= 0;
                end
                else begin
                    if (x < 10'd640 - 1) begin
                        x <= x + 1;
                    end
                    else begin
                        x <= 0;
                        y <= y + 1;
                    end
                end
            end
            else begin
                data_ready <= 1'b0;
            end
        end
    end

    // Stage 3: Write
    assign lcd_wr_clk = ~clk;
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            lcd_wr_en <= 1'b0;
        end
        else begin
            if ((!lcd_wr_full)&&(data_ready)) begin
                lcd_wr_en <= 1'b1;
                lcd_wr_data <= output_pixel;
            end
            else begin
                lcd_wr_en <= 1'b0;
            end
        end
    end

endmodule
