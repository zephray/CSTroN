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
    output reg fifo_we,
    output reg [5:0] fifo_data,
    input fifo_full,
    output fifo_clk,
    output ddr_re,
    input [31:0] ddr_data,
    output [20:0] ddr_addr,
    input ddr_empty,
    output ddr_clk,
    input trigger
    );

    /* DEBUG */
    reg [9:0] x;
    reg [9:0] y;
    
    reg [15:0] image_data;

    always@(negedge clk)
    begin
        if (y < 80) 
            image_data <= {x[8:4], 6'b0, 5'b0};
        else if (y < 160)
            image_data <= {5'b0, x[8:3], 5'b0};
        else
            image_data <= {5'b0, 6'b0, x[8:4]};
    end
    
    // Not Pipelined Design, Process 32 bit of data (2pixels) at a time
    
    parameter S_IDLE = 4'd0;
    parameter S_FETCH_1 = 4'd1;
    parameter S_FETCH_2 = 4'd2;
    parameter S_FETCH_3 = 4'd3;
    parameter S_WB = 4'd4;
    
    reg flm; // new frame mark
    
    reg [3:0] state;
    reg [3:0] next_state;
    
    reg [18:0] upper_pointer;
    reg [18:0] lower_pointer;
    
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
        .flm(flm),
        .raw_in(upper_r),
        .dither_out(output_upper_r)
    );
    
    gldp_lut gldp_lut_upper_g(
        .rst(rst),
        .flm(flm),
        .raw_in(upper_g),
        .dither_out(output_upper_g)
    );
    
    gldp_lut gldp_lut_upper_b(
        .rst(rst),
        .flm(flm),
        .raw_in(upper_b),
        .dither_out(output_upper_b)
    );
    
    gldp_lut gldp_lut_lower_r(
        .rst(rst),
        .flm(flm),
        .raw_in(lower_r),
        .dither_out(output_lower_r)
    );

    gldp_lut gldp_lut_lower_g(
        .rst(rst),
        .flm(flm),
        .raw_in(lower_g),
        .dither_out(output_lower_g)
    );
    
    gldp_lut gldp_lut_lower_b(
        .rst(rst),
        .flm(flm),
        .raw_in(lower_b),
        .dither_out(output_lower_b)
    );

    wire [5:0] output_pixel = {output_upper_r, output_upper_g, output_upper_b, 
        output_lower_r, output_lower_g, output_lower_b};
    
    always @(*)
    begin
        next_state = S_IDLE;
        if ((!rst)&&(state == S_IDLE)&&(trigger)) next_state = S_FETCH_3;
        if ((!rst)&&(state == S_FETCH_2)) next_state = S_FETCH_3;
        if ((!rst)&&(state == S_FETCH_3)) next_state = S_WB;
        if ((!rst)&&(state == S_WB)&&(!fifo_full)&&(upper_pointer != 19'd153600)) next_state = S_FETCH_3;
        if ((!rst)&&(state == S_WB)&&(!fifo_full)&&(upper_pointer == 19'd153600)) next_state = S_IDLE;
        if ((!rst)&&(state == S_WB)&&(fifo_full)) next_state = S_WB;
    end
    
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            state <= S_IDLE;  
            fifo_we <= 0;  
        end
        else begin
            state <= next_state;
            case (state)
                S_IDLE: begin
                    //?
                    fifo_we <= 0;
                    x <= 0;
                    y <= 0;
                    upper_pointer <= 0;
                    flm <= 1;
                end
                S_FETCH_3: begin
                    flm <= 0;
                    fifo_we <= 0;
                    upper_pixel <= image_data;
                    lower_pixel <= image_data;
                    if (x < 10'd640 - 1) begin
                        x <= x + 1;
                    end
                    else begin
                        x <= 0;
                        y <= y + 1;
                    end
                    upper_pointer <= upper_pointer + 1;
                end
                //S_PROCESS: begin
                    
                //end
                S_WB: begin
                    flm <= 0;
                    if (!fifo_full) begin
                        fifo_we <= 1;
                        fifo_data <= output_pixel;
                    end
                end
            endcase
        end
    end
    
    // Fetch Unit
    //reg fetch_stall;
    //reg data_valid;
    
    
    // Store Unit
    assign fifo_clk = ~clk;
    

    

endmodule
