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
// VGA -> VGA_SEQ_FIFO -> SEQUENCER -> SEQ_FRC_FIFO -> FRC -> FRC_LCDC_FIFO -> LCDC
//                            |
//                          DDRII
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
    //input          ROTARY_INCA,
    //input          ROTARY_INCB,
    
    // UART
    /*output         FPGA_SERIAL1_TX,
    input          FPGA_SERIAL1_RX,
    output         FPGA_SERIAL2_TX,
    input          FPGA_SERIAL2_RX,*/
    
    // IIC
    /*output         IIC_SCL_MAIN,
    inout          IIC_SDA_MAIN,*/
    inout          IIC_SCL_VIDEO,
    inout          IIC_SDA_VIDEO,
    /*output         IIC_SCL_SFP,
    inout          IIC_SDA_SFP,*/
    
    // PS2
    /*output         MOUSE_CLK,
    input          MOUSE_DATA,
    output         KEYBOARD_CLK,
    inout          KEYBOARD_DATA,*/
    
    // VGA IN
    input          VGA_IN_DATA_CLK,
    input  [7:0]   VGA_IN_BLUE,
    input  [7:0]   VGA_IN_GREEN,
    input  [7:0]   VGA_IN_RED,
    input          VGA_IN_HSOUT,
    input          VGA_IN_ODD_EVEN_B,
    input          VGA_IN_VSOUT,
    input          VGA_IN_SOGOUT,
    
    // SW
    input          GPIO_SW_C,
    input          GPIO_SW_W,
    input          GPIO_SW_E,
    input          GPIO_SW_S,
    input          GPIO_SW_N,
    //input  [7:0]   GPIO_DIP_SW,
    
    // LED
    output [7:0]   GPIO_LED,
    //output         GPIO_LED_C,
    //output         GPIO_LED_W,
    //output         GPIO_LED_E,
    //output         GPIO_LED_S,
    //output         GPIO_LED_N,

    // DDR2
    inout  [63:0]  DDR2_D,
    output [7:0]   DDR2_DM,
    output [12:0]  DDR2_A,
    output [1:0]   DDR2_CLK_P,
    output [1:0]   DDR2_CLK_N,
    output [1:0]   DDR2_CS_B,
    output [1:0]   DDR2_ODT,
    output [1:0]   DDR2_CKE,
    output         DDR2_RAS_B,
    output         DDR2_CAS_B,
    output         DDR2_WE_B,
    output [1:0]   DDR2_BA,
    inout  [7:0]   DDR2_DQS_P,
    inout  [7:0]   DDR2_DQS_N,
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
    
    // Debug
    output         DEBUG_1,
    output         DEBUG_2,
    output         DEBUG_3,
    output         DEBUG_4,
      
    // System
    input          FPGA_CPU_RESET_B,
    input          CLK_33MHZ_FPGA
    //input          CLK_27MHZ_FPGA
    );

    //Clock and Reset control   
    wire clk_33;
    wire clk_35;  // 2x CSTN clock
    wire clk_110; // FRC clock
    wire clk_from_ddr;

    wire rst_in;
    wire rst_pll;
    wire rst;
    wire pll_locked;
    wire rst_from_ddr;

    assign clk_33 = CLK_33MHZ_FPGA;
    assign rst_in = ~FPGA_CPU_RESET_B;
  
    //Keys
    wire lcd_vsync;
    /*button button_c(
        .pressed(), 
        .pressed_disp(GPIO_LED_C),
        .button_input(GPIO_SW_C),
        .clock(clk_35),
        .reset(rst)
    );
    
    button button_w(
        .pressed(), 
        .pressed_disp(GPIO_LED_W),
        .button_input(GPIO_SW_W),
        .clock(clk_35),
        .reset(rst)
    );
    
    button button_e(
        .pressed(), 
        .pressed_disp(GPIO_LED_E),
        .button_input(GPIO_SW_E),
        .clock(clk_35),
        .reset(rst)
    );
    
    button button_s(
        .pressed(), 
        .pressed_disp(GPIO_LED_S),
        .button_input(GPIO_SW_S),
        .clock(clk_35),
        .reset(rst)
    );*/
    
    // VGA Input
    wire vga_seq_wr_en;
    wire vga_seq_wr_clk;
    wire [15:0] vga_seq_wr_data;
    wire vga_seq_wr_full;
    wire vga_seq_rd_en;
    wire vga_seq_rd_clk;
    wire [127:0] vga_seq_rd_data;
    wire vga_seq_rd_empty;
    wire vga_vsync;
    
    vga_input vga_input(  
        .clk(clk_35),
        .rst(rst),
        .decoder_sda(IIC_SDA_VIDEO), 
        .decoder_scl(IIC_SCL_VIDEO),
        .vga_pixel_clk(VGA_IN_DATA_CLK),
        .vga_hsync(VGA_IN_HSOUT),
        .vga_vsync(VGA_IN_VSOUT),
        .vga_pixel_r(VGA_IN_RED),
        .vga_pixel_b(VGA_IN_BLUE),
        .vga_pixel_g(VGA_IN_GREEN),
        .vga_sync_out(vga_vsync),
        .seq_wr_en(vga_seq_wr_en),
        .seq_wr_clk(vga_seq_wr_clk),
        .seq_wr_data(vga_seq_wr_data),
        .iic_done(iic_done)
    );
    
    // VGA 2 SEQ FIFO
    vga_seq_fifo vga_seq_fifo(
        .rst(rst), // input rst
        .wr_clk(vga_seq_wr_clk), // input wr_clk
        .rd_clk(vga_seq_rd_clk), // input rd_clk
        .din(vga_seq_wr_data), // input [15 : 0] din
        .wr_en(vga_seq_wr_en), // input wr_en
        .rd_en(vga_seq_rd_en), // input rd_en
        .dout(vga_seq_rd_data), // output [127 : 0] dout
        .full(vga_seq_wr_full), // output full
        .empty(vga_seq_rd_empty), // output empty
        .prog_empty(vga_seq_rd_almost_empty) // output prog_empty
    );
    
    // SEQ 2 FRC FIFO
    wire seq_frc_wr_clk;
    wire seq_frc_wr_en;
    wire seq_frc_wr_full;
    wire [127:0] seq_frc_wr_data;
    wire seq_frc_wr_almost_full;
    wire seq_frc_rd_clk;
    wire [31:0] seq_frc_rd_data;
    wire seq_frc_rd_en;
    wire seq_frc_rd_empty;
    seq_frc_fifo seq_frc_fifo (
        .rst(rst), // input rst
        .wr_clk(seq_frc_wr_clk), // input wr_clk
        .rd_clk(seq_frc_rd_clk), // input rd_clk
        .din(seq_frc_wr_data), // input [127 : 0] din
        .wr_en(seq_frc_wr_en), // input wr_en
        .rd_en(seq_frc_rd_en), // input rd_en
        .dout(seq_frc_rd_data), // output [15 : 0] dout
        .full(), // output full
        .empty(seq_frc_rd_empty), // output empty
        .prog_full(seq_frc_wr_almost_full) // output prog_full
    );
    
    // Sequencer
    wire phy_init_done;
    
    sequencer sequencer(
        .clk_33(clk_33),
        .pll_locked(pll_locked),
        .rst_noisy(rst_in),
        .rst_global(rst),
        .clk_35(clk_35),
        .clk_110(clk_110),
        .ddr_rst(rst_from_ddr),
        .ddr_clk(clk_from_ddr),
        .ddr2_dq(DDR2_D),
        .ddr2_a(DDR2_A),
        .ddr2_ba(DDR2_BA),
        .ddr2_ras_n(DDR2_RAS_B),
        .ddr2_cas_n(DDR2_CAS_B),
        .ddr2_we_n(DDR2_WE_B),
        .ddr2_cs_n(DDR2_CS_B[0]),
        .ddr2_odt(DDR2_ODT[0]),
        .ddr2_cke(DDR2_CKE[0]),
        .ddr2_dm(DDR2_DM),
        .ddr2_dqs(DDR2_DQS_P),
        .ddr2_dqs_n(DDR2_DQS_N),
        .ddr2_ck(DDR2_CLK_P),
        .ddr2_ck_n(DDR2_CLK_N),
        .frc_wr_clk(seq_frc_wr_clk),
        .frc_wr_en(seq_frc_wr_en),
        .frc_wr_data(seq_frc_wr_data),
        .frc_wr_almost_full(seq_frc_wr_almost_full),
        .lcdc_vsync(lcd_vsync),
        .vga_rd_clk(vga_seq_rd_clk),
        .vga_rd_en(vga_seq_rd_en),
        .vga_rd_empty(vga_seq_rd_almost_empty),
        .vga_rd_data(vga_seq_rd_data),
        .vga_vsync(vga_vsync),
        .phy_init_done(phy_init_done),
        .dbg_state(),
        .af_wren(af_wren),
        .wdf_wren(wdf_wren),
        .reach_end(reach_end),
        .wr_buf(wr_buf)
    );

    // Display
    wire frc_lcd_rd_clk;
    wire [47:0] frc_lcd_rd_data;
    wire frc_lcd_rd_en;
    wire frc_lcd_rd_empty;
    wire frc_lcd_wr_clk;
    wire [5:0] frc_lcd_wr_data;
    wire frc_lcd_wr_en;
    wire frc_lcd_wr_full;
    wire frc_lcd_wr_almost_full;
    
    lcdc lcdc(
        .clk(clk_35),
        .rst(rst),
        .cstn_xck(CSTN_XCK),
        .cstn_lp(CSTN_LP),
        .cstn_flm(CSTN_FLM),
        .cstn_dispoff(CSTN_DISPOFF),
        .cstn_ud(CSTN_UD),
        .cstn_ld(CSTN_LD),
        .fifo_clk(frc_lcd_rd_clk),
        .fifo_data(frc_lcd_rd_data),
        .fifo_re(frc_lcd_rd_en),
        .fifo_empty(frc_lcd_rd_empty),
        .vsync_in(lcd_vsync)
    );
    
    // FRC
    frc frc(
        .clk(clk_110),
        .rst(rst),
        .lcd_wr_en(frc_lcd_wr_en),
        .lcd_wr_data(frc_lcd_wr_data),
        .lcd_wr_full(frc_lcd_wr_full),
        .lcd_wr_almost_full(frc_lcd_wr_almost_full),
        .lcd_wr_clk(frc_lcd_wr_clk),
        .seq_rd_data(seq_frc_rd_data),
        .seq_rd_en(seq_frc_rd_en),
        .seq_rd_empty(seq_frc_rd_empty),
        .seq_rd_clk(seq_frc_rd_clk),
        .vsync(lcd_vsync)
    );

    // FIFO
    frc_lcdc_fifo frc_lcdc_fifo (
        .rst(rst), // input rst
        .wr_clk(frc_lcd_wr_clk), // input wr_clk
        .rd_clk(frc_lcd_rd_clk), // input rd_clk
        .din(frc_lcd_wr_data), // input [5 : 0] din
        .wr_en(frc_lcd_wr_en), // input wr_en
        .rd_en(frc_lcd_rd_en), // input rd_en
        .dout(frc_lcd_rd_data), // output [47 : 0] dout
        .full(frc_lcd_wr_full), // output full
        .prog_full(frc_lcd_wr_almost_full), // output amost full
        .empty(frc_lcd_rd_empty) // output empty
    );
    
    
    assign GPIO_LED_N = rst;
    
    assign GPIO_LED[7] = frc_lcd_wr_full;
    assign GPIO_LED[6] = frc_lcd_rd_empty;
    assign GPIO_LED[5] = lcd_vsync;
    assign GPIO_LED[4] = seq_frc_rd_empty;
    assign GPIO_LED[3] = iic_done;
    assign GPIO_LED[2] = seq_frc_wr_en;
    assign GPIO_LED[1] = pll_locked;
    assign GPIO_LED[0] = phy_init_done;
    
    assign DEBUG_1 = vga_vsync;
    assign DEBUG_2 = wdf_wren;
    assign DEBUG_3 = af_wren;
    assign DEBUG_4 = wr_buf;
    
endmodule
