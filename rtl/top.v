`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:19 01/27/2018 
// Design Name: 
// Module Name:    top 
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
module top(
    // Audio
    //output         AUDIO_SDATA_OUT,
    //input         AUDIO_BIT_CLK,
    //input          AUDIO_SDATA_IN,
    //output         AUDIO_SYNC,
    //output         FLASH_AUDIO_RESET_B,

    // SRAM & Flash
    //output [30:0]  SRAM_FLASH_A,
    //inout  [15:0]  SRAM_FLASH_D,
    //inout  [31:16] SRAM_D,
    //inout  [3:0]   SRAM_DQP,
    //output [3:0]   SRAM_BW,
    //output         SRAM_FLASH_WE_B,
    //output         SRAM_CLK,
    //output         SRAM_CS_B,
    //output         SRAM_OE_B,
    //output         SRAM_MODE,
    //output         SRAM_ADV_LD_B,
    //output         FLASH_CE_B,
    //output         FLASH_OE_B,
    //output         FLASH_CLK,
    //output         FLASH_ADV_B,
    //output         FLASH_WAIT,
    
    // Rotrary Encoder
    input          ROTARY_INCA,
    input          ROTARY_INCB,
    
    // UART
    /*output         FPGA_SERIAL1_TX,
    input          FPGA_SERIAL1_RX,
    output         FPGA_SERIAL2_TX,
    input          FPGA_SERIAL2_RX,*/
    
    // IIC
    /*output         IIC_SCL_MAIN,
    inout          IIC_SDA_MAIN,*/
    //inout          IIC_SCL_VIDEO,
    //inout          IIC_SDA_VIDEO,
    /*output         IIC_SCL_SFP,
    inout          IIC_SDA_SFP,*/
    
    // PS2
    /*output         MOUSE_CLK,
    input          MOUSE_DATA,
    output         KEYBOARD_CLK,
    inout          KEYBOARD_DATA,*/
    
    // VGA IN
    /*input          VGA_IN_DATA_CLK,
    input  [7:0]   VGA_IN_BLUE,
    input  [7:0]   VGA_IN_GREEN,
    input  [7:0]   VGA_IN_RED,
    input          VGA_IN_HSOUT,
    input          VGA_IN_ODD_EVEN_B,
    input          VGA_IN_VSOUT,
    input          VGA_IN_SOGOUT,*/
    
    // SW
    input          GPIO_SW_C,
    input          GPIO_SW_W,
    input          GPIO_SW_E,
    input          GPIO_SW_S,
    input          GPIO_SW_N,
    input  [7:0]   GPIO_DIP_SW,
    
    // LED
    output [7:0]   GPIO_LED,
    output         GPIO_LED_C,
    output         GPIO_LED_W,
    output         GPIO_LED_E,
    output         GPIO_LED_S,
    output         GPIO_LED_N,

    // DDR2
    /*inout  [63:0]  DDR2_D,
    output [12:0]  DDR2_A,
    output [1:0]   DDR2_CLK_P,
    output [1:0]   DDR2_CLK_N,
    output [1:0]   DDR2_CE,
    output [1:0]   DDR2_CS_B,
    output [1:0]   DDR2_ODT,
    output         DDR2_RAS_B,
    output         DDR2_CAS_B,
    output         DDR2_WE_B,
    output [1:0]   DDR2_BA,
    output [7:0]   DDR2_DQS_P,
    output [7:0]   DDR2_DQS_N,
    output         DDR2_SCL,
    inout          DDR2_SDA,*/
    
    // Speaker
    //output         PIEZO_SPEAKER,
    
    // DVI
    //output [11:0]  DVI_D,
    //output         DVI_DE,
    //output         DVI_H,
    //output         DVI_RESET_B,
    //output         DVI_V,
    //output         DVI_XCLK_N,
    //output         DVI_XCLK_P,
    //input          DVI_GPIO1,
    
    // Dual Shock 2
    //input          DS2_DAT,
    //output         DS2_CMD,
    //output         DS2_ATT,
    //output         DS2_CLK,
    //input          DS2_ACK,
    
    // CSTN
    output         CSTN_XCK,
    output         CSTN_LP,
    output         CSTN_FLM,
    output         CSTN_DISPOFF,
    output [7:0]   CSTN_UD,
    output [7:0]   CSTN_LD,
      
    // System
    input          FPGA_CPU_RESET_B,
    input          CLK_33MHZ_FPGA,
    input          CLK_27MHZ_FPGA
    );

    //Clock and Reset control   
    wire clk_33;
    wire clk_18; // 2x CSTN clock

    wire reset_in;
    wire reset_pll;
    wire reset;
    wire locked_pll;

    assign clk_33 = CLK_33MHZ_FPGA;
    assign reset_in = ~FPGA_CPU_RESET_B;

    pll pll (
        .CLKIN1_IN(clk_33), 
        .RST_IN(reset_pll), 
        .CLKOUT0_OUT(clk_18), 
        .CLKOUT1_OUT(), 
        .CLKOUT2_OUT(),
        .CLKOUT3_OUT(),
        .LOCKED_OUT(locked_pll)
    );

    debounce_rst debounce_rst(
        .clk(clk_33),
        .noisy_rst(reset_in),
        .pll_locked(locked_pll),
        .clean_pll_rst(reset_pll),
        .clean_async_rst(reset)
    );
  
    //Keys
    button button_c(
        .pressed(bp_step), 
        .pressed_disp(GPIO_LED_C),
        .button_input(GPIO_SW_C),
        .clock(clk_gb),
        .reset(reset)
    );
    
    button button_w(
        .pressed(bp_change), 
        .pressed_disp(GPIO_LED_W),
        .button_input(GPIO_SW_W),
        .clock(clk_gb),
        .reset(reset)
    );
    
    button button_e(
        .pressed(bp_continue), 
        .pressed_disp(GPIO_LED_E),
        .button_input(GPIO_SW_E),
        .clock(clk_gb),
        .reset(reset)
    );
    
    button button_s(
        .pressed(), 
        .pressed_disp(GPIO_LED_S),
        .button_input(GPIO_SW_S),
        .clock(clk_gb),
        .reset(reset)
    );
    
    assign GPIO_LED_N = reset;
    
    wire [7:0] dip_sw = {GPIO_DIP_SW[0], GPIO_DIP_SW[1], GPIO_DIP_SW[2], GPIO_DIP_SW[3], GPIO_DIP_SW[4], GPIO_DIP_SW[5], GPIO_DIP_SW[6], GPIO_DIP_SW[7]};
    
    assign GPIO_LED[7:0] = 8'h00;

    // experimental
    //Horizontal
    parameter H_FRONT   = 31; // Front porch
    parameter H_BACK    = 8;  // Back porch
    parameter H_LP      = 6;  // LP Pulse width
    parameter H_WAIT    = 11; // BP after pulse
    parameter H_ACT     = 640;// Active pixels
    parameter H_TOTAL   = H_FRONT + H_BACK + H_LP + H_WAIT + H_ACT;

    //Vertical
    parameter V_ACT     = 240; // Active lines
    
    reg [10:0] h_count;
    reg [10:0] v_count;
    
    wire flm;
    reg lp;
    reg xck;
    reg iclk;
    reg [1:0] div3;
    
    assign flm = (v_count == 11'b0) ? 1'b1 : 1'b0;
    
    always @(posedge clk_18 or posedge reset)
    begin
        if(reset)
        begin
            h_count <= 0;
            lp <= 0;
            xck <= 0;
            iclk <= 0;
            v_count <= 0;
            div3 <= 0;
        end
        else
        begin      
            iclk <= ~iclk;
            if(h_count < H_TOTAL) begin
                if (iclk) begin // second clock
                    h_count <= h_count + 1'b1;
                    if (div3 == 2'b10) begin
                        div3 <= 2'b00;
                    end else begin
                        div3 <= div3 + 1;
                    end
                end
            end else begin
                h_count <= 0;
                div3 <= 0;
            end
            
            if ((h_count > H_FRONT)&&(h_count <= (H_FRONT + H_ACT))) begin
                xck <= iclk;
            end else begin
                xck <= 1'b0;
            end
            
            if ((h_count > (H_FRONT + H_ACT + H_BACK))&&(h_count <= (H_FRONT + H_ACT + H_BACK + H_LP))) begin
                lp <= 1'b1;
            end else begin
                lp <= 1'b0;
            end
            
            if ((h_count == (H_FRONT + H_ACT + H_BACK + H_LP + H_WAIT - 1))&&(iclk)) begin
                if (v_count < (V_ACT - 1)) begin
                    v_count <= v_count + 1;
                end else begin
                    v_count <= 0;
                end
            end
           
        end 
    end
    
    assign CSTN_XCK = xck;
    assign CSTN_LP = lp;
    assign CSTN_FLM = flm;
    assign CSTN_DISPOFF = 1'b1;
    
    reg [7:0] frame_count;
    reg [2:0] color;
    
    always @(posedge flm or posedge reset) 
    begin
        if (reset) begin
            frame_count <= 0;
            color <= 0;
        end else begin
            frame_count <= frame_count + 1;
            if (frame_count == 0)
                color <= color + 1;
        end
    end
    
    wire [7:0] color_pattern_1 = {color[2:0], color[2:0], color[2:1]};
    wire [7:0] color_pattern_2 = {color[0], color[2:0], color[2:0], color[2]};
    wire [7:0] color_pattern_3 = {color[1:0], color[2:0], color[2:0]};
    wire [7:0] cstn_color = (div3 == 2'b00) ? (color_pattern_1) : ((div3 == 2'b01) ? (color_pattern_2) : (color_pattern_3) );
    assign CSTN_UD[7:0] = cstn_color;
    assign CSTN_LD[7:0] = cstn_color;

endmodule
