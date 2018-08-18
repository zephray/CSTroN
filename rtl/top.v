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
    output [7:0]   DDR2_DM,
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
    inout  [7:0]   DDR2_DQS_P,
    inout  [7:0]   DDR2_DQS_N,*/
    /*output         DDR2_SCL,
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
    wire clk_50; // FRC clock

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
        .CLKOUT1_OUT(clk_50), 
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
    wire lcd_vsync;
    button button_c(
        .pressed(), 
        .pressed_disp(GPIO_LED_C),
        .button_input(GPIO_SW_C),
        .clock(clk_18),
        .reset(reset)
    );
    
    button button_w(
        .pressed(), 
        .pressed_disp(GPIO_LED_W),
        .button_input(GPIO_SW_W),
        .clock(clk_18),
        .reset(reset)
    );
    
    button button_e(
        .pressed(), 
        .pressed_disp(GPIO_LED_E),
        .button_input(GPIO_SW_E),
        .clock(clk_18),
        .reset(reset)
    );
    
    button button_s(
        .pressed(), 
        .pressed_disp(GPIO_LED_S),
        .button_input(GPIO_SW_S),
        .clock(clk_18),
        .reset(reset)
    );
    

    // Display
    wire fifo_rd_clk;
    wire [47:0] fifo_rd_data;
    wire fifo_rd_en;
    wire fifo_rd_empty;
    wire fifo_wr_clk;
    wire [5:0] fifo_wr_data;
    wire fifo_wr_en;
    wire fifo_wr_full;
    
    
    /*clk_div #(.WIDTH(21), .DIV(250000)) frame_div(
        .i(clk_18),
        .o(lcd_vsync)
    );*/
    assign lcd_vsync = 1'b1;
    
    lcdc lcdc(
        .clk(clk_18),
        .rst(reset),
        .cstn_xck(CSTN_XCK),
        .cstn_lp(CSTN_LP),
        .cstn_flm(CSTN_FLM),
        .cstn_dispoff(CSTN_DISPOFF),
        .cstn_ud(CSTN_UD),
        .cstn_ld(CSTN_LD),
        .fifo_clk(fifo_rd_clk),
        .fifo_data(fifo_rd_data),
        .fifo_re(fifo_rd_en),
        .fifo_empty(fifo_rd_empty),
        .vsync_in(lcd_vsync)
    );
    
    // Fake FIFO
    //assign fifo_empty = 1;
    /*reg [7:0] frame_count;
    reg [2:0] color;
    
    always @(posedge CSTN_FLM or posedge reset) 
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
    
    assign fifo_rd_data = {16{color}};*/
    //assign fifo_rd_data = 48'h924924924924;
    
    // FRC
    frc frc(
        .clk(clk_50),
        .rst(reset),
        .fifo_we(fifo_wr_en),
        .fifo_data(fifo_wr_data),
        .fifo_full(fifo_wr_full),
        .fifo_clk(fifo_wr_clk),
        .ddr_re(),
        .ddr_data(),
        .ddr_addr(),
        .ddr_empty(),
        .ddr_clk(),
        .trigger(lcd_vsync)
    );
    
    // FIFO
    frc_lcdc_fifo frc_lcdc_fifo (
        .rst(reset), // input rst
        .wr_clk(fifo_wr_clk), // input wr_clk
        .rd_clk(fifo_rd_clk), // input rd_clk
        .din(fifo_wr_data), // input [5 : 0] din
        .wr_en(fifo_wr_en), // input wr_en
        .rd_en(fifo_rd_en), // input rd_en
        .dout(fifo_rd_data), // output [47 : 0] dout
        .full(fifo_wr_full), // output full
        .empty(fifo_rd_empty) // output empty
    );
    
    
    assign GPIO_LED_N = reset;
    
    wire [7:0] dip_sw = {GPIO_DIP_SW[0], GPIO_DIP_SW[1], GPIO_DIP_SW[2], GPIO_DIP_SW[3], GPIO_DIP_SW[4], GPIO_DIP_SW[5], GPIO_DIP_SW[6], GPIO_DIP_SW[7]};
    assign GPIO_LED[7] = fifo_wr_full;
    assign GPIO_LED[6] = fifo_rd_empty;
    assign GPIO_LED[5:0] = 6'b0;
    
endmodule
