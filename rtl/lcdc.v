`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:08:53 08/16/2018 
// Design Name: 
// Module Name:    lcdc 
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
module lcdc(
    input clk,
    input rst,
    output cstn_xck,
    output cstn_flm,
    output cstn_lp,
    output cstn_dispoff,
    output [7:0] cstn_ud,
    output [7:0] cstn_ld,
    output reg fifo_clk,
    input [47:0] fifo_data,
    output reg fifo_re,
    input fifo_empty,
    input vsync_in
    );

    //Horizontal
    parameter H_FRONT   = 31; // Front porch
    parameter H_BACK    = 8;  // Back porch
    parameter H_LP      = 6;  // LP Pulse width
    parameter H_WAIT    = 11; // BP after pulse
    parameter H_ACT     = 240;// Active pixels in clks
    parameter H_TOTAL   = H_FRONT + H_BACK + H_LP + H_WAIT + H_ACT;

    //Vertical
    parameter V_ACT     = 240; // Active lines
    parameter V_BACK    = 1;   // Back porch
    parameter V_TOTAL   = V_ACT + V_BACK;
    
    reg [10:0] h_count;
    reg [10:0] v_count;
    
    wire flm;
    reg lp;
    reg xck;
    reg iclk;
    reg [1:0] div3;
    reg [7:0] ud;
    reg [7:0] ld;
    
    reg [23:0] upper_buffer;
    reg [23:0] lower_buffer;
    
    wire [23:0] fifo_upper_data = {fifo_data[47:45], fifo_data[41:39], fifo_data[35:33], fifo_data[29:27], 
        fifo_data[23:21], fifo_data[17:15], fifo_data[11:9], fifo_data[5:3]};
    wire [23:0] fifo_lower_data = {fifo_data[44:42], fifo_data[38:36], fifo_data[32:30], fifo_data[26:24], 
        fifo_data[20:18], fifo_data[14:12], fifo_data[8:6], fifo_data[2:0]};
    reg [1:0] state; // S0 - idle, wait for sync; S1 - refreshing; S2 - wait for FIFO
    
    assign flm = (v_count == 11'b0) ? 1'b1 : 1'b0;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            h_count <= 0;
            lp <= 0;
            xck <= 0;
            iclk <= 0;
            v_count <= 0;
            div3 <= 0;
            fifo_clk <= 1'b0;
            fifo_re <= 1'b0;
            state <= 0;
        end
        else
        begin      
            if (state == 2'd0) begin // idle state
                if (vsync_in)
                    state <= 2'd2;
            end else if (state == 2'd2) begin
                if (!fifo_empty)
                    state <= 2'd1;
                fifo_clk <= ~fifo_clk;
            end else begin // refresh state
                iclk <= ~iclk;
            
                // Horizontal Counter
                if(h_count < H_TOTAL) begin
                    if (iclk) begin // second clock
                        h_count <= h_count + 1'b1;
                    end
                end else begin
                    h_count <= 0;
                end
                
                // Div by 3 counter, FIFO read logic
                if ((v_count < V_ACT) && (h_count > (H_FRONT - 18))&&(h_count <= (H_FRONT + H_ACT))) begin
                    
                    if (~iclk) begin // was low, rising edge
                        // Counter
                        case(div3)
                            2'b00: div3 <= 2'b01;
                            2'b01: div3 <= 2'b10;
                            2'b10: div3 <= 2'b00;
                        endcase
                        
                        // Fifo Clock
                        case(div3)
                            2'b01: fifo_clk <= 1'b1;
                            2'b10: fifo_clk <= 1'b0;
                        endcase
                        
                        // Fifo Logic
                        if (div3 == 2'b00) begin
                            upper_buffer <= fifo_upper_data;
                            lower_buffer <= fifo_lower_data;
                        end
                    end
                    
                end else begin
                    div3 <= 0;
                    fifo_clk <= 1'b0;
                end 
                
                // FIFO read enable
                if ((v_count < V_ACT) && (h_count > (H_FRONT - 6))&&(h_count <= (H_FRONT + H_ACT - 6))) begin
                    if (~iclk) begin // rising edge
                        if (div3 == 2'b00) begin
                            if (!fifo_empty) fifo_re <= 1'b1; else fifo_re <= 1'b0;
                        end
                    end
                end else begin
                    fifo_re <= 1'b0;
                end 
                
                // CSTN data bus output logic
                if ((h_count > H_FRONT)&&(h_count <= (H_FRONT + H_ACT))) begin
                    xck <= iclk;
                    if (iclk) begin // was high, falling edge, rising edge of LCD
                        case(div3)
                            2'b01: begin ud <= upper_buffer[23:16]; ld <= lower_buffer[23:16]; end
                            2'b10: begin ud <= upper_buffer[15:8];  ld <= lower_buffer[15:8];  end
                            2'b00: begin ud <= upper_buffer[7:0];   ld <= lower_buffer[7:0];   end
                        endcase
                    end else begin // was low, rising edge
                        // do nothing, FIFO reading might happen at this edge
                    end
                end else begin
                    xck <= 1'b0;
                end
                
                if ((h_count > (H_FRONT + H_ACT + H_BACK))&&(h_count <= (H_FRONT + H_ACT + H_BACK + H_LP))) begin
                    lp <= 1'b1;
                end else begin
                    lp <= 1'b0;
                end
                
                if ((h_count == (H_FRONT + H_ACT + H_BACK + H_LP + H_WAIT - 1))&&(iclk)) begin
                    if ((v_count < (V_TOTAL - 1))) begin
                        v_count <= v_count + 1;
                    end else begin
                        v_count <= 0; 
                        state <= 0;
                    end
                end
            end  // state machine 
        end // reset
    end // always
    
    assign cstn_xck = xck;
    assign cstn_lp = lp;
    assign cstn_flm = flm;
    assign cstn_dispoff = 1'b1;
    assign cstn_ud = ud;
    assign cstn_ld = ld;

endmodule
