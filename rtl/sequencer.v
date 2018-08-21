`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:17:44 08/18/2018 
// Design Name: 
// Module Name:    sequencer 
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
module sequencer(
    // Clock and Reset
    input clk_33,
    output pll_locked,
    input rst_noisy,
    output rst_global,
    output clk_35,
    output clk_110,
    output ddr_rst,
    output ddr_clk,
    // DDR PHY
    inout [63:0] ddr2_dq,
    output [12:0] ddr2_a,
    output [1:0] ddr2_ba,
    output ddr2_ras_n,
    output ddr2_cas_n,
    output ddr2_we_n,
    output ddr2_cs_n,
    output ddr2_odt,
    output ddr2_cke,
    output [7:0] ddr2_dm,
    inout [7:0] ddr2_dqs,
    inout [7:0] ddr2_dqs_n,
    output [1:0] ddr2_ck,
    output [1:0] ddr2_ck_n,
    // FRC FIFO Master Port
    output frc_wr_clk,
    output frc_wr_en,
    output [127:0] frc_wr_data,
    input frc_wr_almost_full, // when there is less than 32 slots available (DDR latency up to 28 clocks) 
    // LCDC VSYNC output
    output reg lcdc_vsync,
    // VGA FIFO Master Port
    output vga_rd_clk,
    output vga_rd_en,
    input vga_rd_empty,
    input [127:0] vga_rd_data,
    // VGA VSYNC input
    input vga_vsync,
    // Debug
    output phy_init_done,
    output [1:0] dbg_state
    );
    
    wire rst;
    wire rst_pll;
    wire clk_125_raw;
    wire clk_125_90_raw;
    wire clk_62p5_raw;
    wire clk_200_raw;
    
    /*clk_gen_pll pll (
        .sysClk(clk_33),
        .sysRst(rst_pll),  //Asynchronous PLL reset
        .clk0_125(clk_125_raw), //125 Mhz
        .clk0Phase90(clk_125_90_raw), //125 MHz clk200 with 90 degree phase
        .clk0Div2(clk_62p5_raw), //62.5 MHz
        .clk200(clk_200_raw),   //200 MHz clk
        .clkTFT10(), 
        .clkTFT10_180(),
        .locked(pll_locked)
    );
    
    wire clk_125;
    wire clk_125_90;
    wire clk_62p5;
    wire clk_200;
    
    BUFG u_bufg_clk_125
    (
        .O (clk_125),
        .I (clk_125_raw)
    );

    BUFG u_bufg_clk_125_90
    (
        .O (clk_125_90),
        .I (clk_125_90_raw)
    );

    BUFG u_bufg_clk_200
    (
        .O (clk_200),
        .I (clk_200_raw)
    );

    BUFG u_bufg_clk_62p5
    (
        .O (clk_62p5),
        .I (clk_62p5_raw)
    );
    */
    
    pll pll (
        .CLKIN1_IN(clk_33), 
        .RST_IN(rst_pll), 
        .CLKOUT0_OUT(clk_35), 
        .CLKOUT1_OUT(clk_125), 
        .CLKOUT2_OUT(clk_125_90),
        .CLKOUT3_OUT(clk_62p5),
        .CLKOUT4_OUT(clk_200),
        .CLKOUT5_OUT(clk_110), 
        .LOCKED_OUT(pll_locked)
    );
    
    debounce_rst debounce_rst(
        .clk(clk_33),
        .noisy_rst(rst_noisy),
        .pll_locked(pll_locked),
        .clean_pll_rst(rst_pll),
        .clean_async_rst(rst)
    );
    
    assign rst_global = rst;
    
    wire         app_wdf_afull;      // User Write FIFO Almost Full
    wire         app_af_afull;       // Address FIFO Almost Full
    wire         rd_data_valid;      // Read Data Valid
    reg          app_wdf_wren;       // User Write FIFO Writen Enable
    reg          app_af_wren;        // Address FIFO Written Enable
    reg  [30:0]  app_af_addr;        // Address FIFO Data
    reg  [2:0]   app_af_cmd;         // 3'b000 for Write; 3'b001 for Read
    wire [127:0] rd_data_fifo_out;   // Read Data from Memory
    reg  [127:0] app_wdf_data;       // User Input Data
    reg  [15:0]   app_wdf_mask_data;  // Usser Masking Data

    localparam MIG_CMD_RD = 3'b001;
    localparam MIG_CMD_WR = 3'b000;

    localparam BANK_WIDTH              = 2;
    localparam CKE_WIDTH               = 1;
    localparam CLK_WIDTH               = 2;
    localparam COL_WIDTH               = 10;
    localparam CS_NUM                  = 1;
    localparam CS_WIDTH                = 1;
    localparam CS_BITS                 = 0;
    localparam DM_WIDTH                = 8;
    localparam DQ_WIDTH                = 64;
    localparam DQ_PER_DQS              = 8;
    localparam DQS_WIDTH               = 8;
    localparam DQ_BITS                 = 6;
    localparam DQS_BITS                = 3;
    localparam ODT_WIDTH               = 1;
    localparam ROW_WIDTH               = 13;
    localparam ADDITIVE_LAT            = 0;
    localparam BURST_LEN               = 4;
    localparam BURST_TYPE              = 0;
    localparam CAS_LAT                 = 3;
    localparam ECC_ENABLE              = 0;
    localparam APPDATA_WIDTH           = 128;
    localparam MULTI_BANK_EN           = 1;
    localparam TWO_T_TIME_EN           = 1;
    localparam ODT_TYPE                = 1;
    localparam REDUCE_DRV              = 0;
    localparam REG_ENABLE              = 0;
    localparam TREFI_NS                = 7800;
    localparam TRAS                    = 40000;
    localparam TRCD                    = 15000;
    localparam TRFC                    = 105000;
    localparam TRP                     = 15000;
    localparam TRTP                    = 7500;
    localparam TWR                     = 15000;
    localparam TWTR                    = 7500;
    localparam HIGH_PERFORMANCE_MODE   = "TRUE";
    localparam SIM_ONLY                = 0;
    localparam DEBUG_EN                = 0;
    localparam CLK_PERIOD              = 8000;
    localparam RST_ACT_LOW             = 0;

    MEMCtrl #
    (
        .BANK_WIDTH (BANK_WIDTH),        // # of memory bank addr bits.
        .CKE_WIDTH (CKE_WIDTH),          // # of memory clock enable outputs.
        .CLK_WIDTH (CLK_WIDTH),          // # of clock outputs.
        .COL_WIDTH (COL_WIDTH),          // # of memory column bits.
        .CS_NUM (CS_NUM),                // # of separate memory chip selects.
        .CS_WIDTH (CS_WIDTH),            // # of total memory chip selects.
        .CS_BITS (CS_BITS),              // set to log2(CS_NUM) (rounded up).
        .DM_WIDTH (DM_WIDTH),            // # of data mask bits.
        .DQ_WIDTH (DQ_WIDTH),            // # of data width.
        .DQ_PER_DQS (DQ_PER_DQS),        // # of DQ data bits per strobe.
        .DQS_WIDTH  (DQS_WIDTH),         // # of DQS strobes.
        .DQ_BITS (DQ_BITS),              // set to log2(DQS_WIDTH*DQ_PER_DQS).
        .DQS_BITS (DQS_BITS),            // set to log2(DQS_WIDTH).
        .ODT_WIDTH (ODT_WIDTH),          // # of memory on-die term enables.
        .ROW_WIDTH (ROW_WIDTH),          // # of memory row and # of addr bits.
        .ADDITIVE_LAT(ADDITIVE_LAT),     // additive write latency.
        .BURST_LEN (BURST_LEN),          // burst length (in double words).
        .BURST_TYPE(BURST_TYPE),         // burst type (=0 seq; =1 interleaved).
        .CAS_LAT (CAS_LAT),              // CAS latency.
        .ECC_ENABLE (ECC_ENABLE),        // enable ECC (=1 enable).
        .APPDATA_WIDTH (APPDATA_WIDTH),  // # of usr read/write data bus bits.
        .MULTI_BANK_EN (MULTI_BANK_EN),  // Keeps multiple banks open. (= 1 enable).
        .TWO_T_TIME_EN (TWO_T_TIME_EN),  // 2t timing for unbuffered dimms.
        .ODT_TYPE (ODT_TYPE),            // ODT (=0(none),=1(75),=2(150),=3(50)).
        .REDUCE_DRV (REDUCE_DRV),        // reduced strength mem I/O (=1 yes).
        .REG_ENABLE (REDUCE_DRV),        // registered addr/ctrl (=1 yes).
        .TREFI_NS (TREFI_NS),            // auto refresh interval (ns).
        .TRAS (TRAS),                    // active->precharge delay.
        .TRCD (TRCD),                    // active->read/write delay.
        .TRFC (TRFC),                    // refresh->refresh, refresh->active delay.
        .TRP (TRP),                      // precharge->command delay.
        .TRTP (TRTP),                    // read->precharge delay.
        .TWR (TWR),                      // used to determine write->precharge.
        .TWTR (TWTR),                    // write->read delay.
        .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),       
                                         // # = TRUE, the IODELAY performance mode is set to high.
                                         // # = FALSE, the IODELAY performance mode is set to low.
        .SIM_ONLY (SIM_ONLY),            // = 1 to skip SDRAM power up delay.
        .DEBUG_EN (DEBUG_EN),            // Enable debug signals/controls.
                                         // When this parameter is changed from 0 to 1,
                                         // make sure to uncomment the coregen commands
                                         // in ise_flow.bat or create_ise.bat files in
                                         // par folder.
        .CLK_PERIOD (CLK_PERIOD),        // Core/Memory clock period (in ps).
        .RST_ACT_LOW (RST_ACT_LOW)       // =1 for active low reset, =0 for active high.
    )
    MEMCtrl (
        // DDR PHY
        .ddr2_dq(ddr2_dq),
        .ddr2_a(ddr2_a),
        .ddr2_ba(ddr2_ba),
        .ddr2_ras_n(ddr2_ras_n),
        .ddr2_cas_n(ddr2_cas_n),
        .ddr2_we_n(ddr2_we_n),
        .ddr2_cs_n(ddr2_cs_n),
        .ddr2_odt(ddr2_odt),
        .ddr2_cke(ddr2_cke),
        .ddr2_dm(ddr2_dm),
        .ddr2_dqs(ddr2_dqs),
        .ddr2_dqs_n(ddr2_dqs_n),
        .ddr2_ck(ddr2_ck),
        .ddr2_ck_n(ddr2_ck_n),
         
        // Clock
        .sys_rst_n(rst), 
        .phy_init_done(phy_init_done),
        .locked(pll_locked),
        .rst0_tb(ddr_rst),
        .clk0(clk_125),
        .clk0_tb(ddr_clk), 
        .clk90(clk_125_90),
        .clkdiv0(clk_62p5),
        .clk200(clk_200),
         
        // User interface
        .app_wdf_afull(app_wdf_afull),
        .app_af_afull(app_af_afull),
        .rd_data_valid(rd_data_valid),
        .app_wdf_wren(app_wdf_wren),
        .app_af_wren(app_af_wren),
        .app_af_addr(app_af_addr),
        .app_af_cmd(app_af_cmd),
        .rd_data_fifo_out(rd_data_fifo_out),
        .app_wdf_data(app_wdf_data),
        .app_wdf_mask_data(app_wdf_mask_data)	
    );
   
    // FRC read port
    assign frc_wr_clk = ddr_clk;
    assign frc_wr_en = rd_data_valid;
    assign frc_wr_data = rd_data_fifo_out;

    // Sequencer Logic !
    // |_VGA\FRC_|_Full_|_Normal_|_Empty_|
    // | Full    | WR   | WR     | BOOM  |
    // | Normal  | WR   | RD/WR  | RD    |
    // | Empty   | NoOp | RD     | RD    | //?
    // Logic: If there is any incoming data, write them.
    //        Otherwise check if the LCDC fifo is full, if not, issue read command.
    // Note: 1. since there is delay between command issue and actual data writing into fifo,
    //          The LCDC fifo MUST be large enough to fit all data read by the command issued before.
    //       2. The written data should be interlaced: In each 32bit packet,
    //          upper 16bit is for upper screen, lower 16bit is for lower screen.
    //          Thus, 128bit Input data is enough for 256bit burst (burst length = 4).
    // S0 - Idle
    // S1 - Normal
    // S2 - Input Normal, Output Waiting Vsync
    localparam S_IDLE = 3'd0;
    localparam S_NORMAL = 3'd1;
    localparam S_INPUTONLY = 3'd2; // this is deprecated. Pixel fetch should be stopped after one frame under any cases.
    localparam S_DDRWR = 3'd3;
    reg [2:0] state;
    reg [2:0] next_state;
    // Dual buffering
    reg  wr_buf_sel = 0;
    wire rd_buf_sel = ~wr_buf_sel;
    localparam buf_addr_base_0 = 31'h0;
    localparam buf_addr_base_1 = 31'h100000;
    wire [30:0] wr_buf_addr_base = (wr_buf_sel) ? (buf_addr_base_1) : (buf_addr_base_0);
    wire [30:0] rd_buf_addr_base = (rd_buf_sel) ? (buf_addr_base_1) : (buf_addr_base_0);
    // Pixel Counting
    reg [19:0] wr_position = 0;
    reg [19:0] rd_position = 0;
    wire [30:0] wr_pointer = {wr_buf_addr_base[30:20], wr_position[19:0]};
    wire [30:0] rd_pointer = {rd_buf_addr_base[30:20], rd_position[19:0]};
    reg wr_upper_lower_select = 0; // 0 for upper half screen, 1 for lower half screen
    wire wr_upper_lower_select_next = (wr_position == (20'd307200 - 8)) ? (~wr_upper_lower_select) : (wr_upper_lower_select);
    wire [19:0] wr_position_next = (wr_position == (20'd307200 - 8)) ? (20'd0) : (wr_position + 20'd8);
    wire rd_reach_end = (rd_position == (20'd614400)) ? 1'b1 : 1'b0;
    wire [19:0] rd_position_next = (rd_reach_end) ? (rd_position) : (rd_position + 20'd8);
    // Interlacing
    wire [127:0] wr_data_upper_1 = {vga_rd_data[127:112], 16'b0, vga_rd_data[111:96], 16'b0, vga_rd_data[95:80], 16'b0, vga_rd_data[79:64], 16'b0};
    wire [127:0] wr_data_upper_2 = {vga_rd_data[63:48], 16'b0, vga_rd_data[47:32], 16'b0, vga_rd_data[31:16], 16'b0, vga_rd_data[15:0], 16'b0};
    wire [127:0] wr_data_lower_1 = {16'b0, vga_rd_data[127:112], 16'b0, vga_rd_data[111:96], 16'b0, vga_rd_data[95:80], 16'b0, vga_rd_data[79:64]};
    wire [127:0] wr_data_lower_2 = {16'b0, vga_rd_data[63:48], 16'b0, vga_rd_data[47:32], 16'b0, vga_rd_data[31:16], 16'b0, vga_rd_data[15:0]};
    wire [15:0] wr_mask_upper = 16'b1010101010101010;
    wire [15:0] wr_mask_lower = 16'b0101010101010101;
    wire [127:0] wr_data_1 = (wr_upper_lower_select) ? (wr_data_lower_1) : (wr_data_upper_1);
    wire [127:0] wr_data_2 = (wr_upper_lower_select) ? (wr_data_lower_2) : (wr_data_upper_2);
    wire [15:0] wr_mask = (wr_upper_lower_select) ? (wr_mask_lower) : (wr_mask_upper);
    // Vertical Sync
    reg last_vsync;
    reg [22:0] ticks_since_last_sync;
    reg [19:0] ticks_since_last_cstn_frame;
    reg [22:0] last_sync_duration;
    wire [19:0] cstn_vsync_threshold = last_sync_duration[22:2];
 
    always @(posedge ddr_clk) begin
        if (ddr_rst) begin
            wr_position <= 0;
            rd_position <= 0;
            wr_upper_lower_select <= 0;
            state <= S_NORMAL;
            app_af_wren <= 1'b0;
            app_wdf_wren <= 1'b0;
            last_sync_duration <= 23'd2000000; 
            ticks_since_last_cstn_frame <= 23'd0;
            ticks_since_last_sync <= 23'd0;
            last_vsync <= 1'b0;
            lcdc_vsync <= 1'b1;
        end
        else begin
            case (state)
                S_IDLE: begin
                    //?
                    state <= S_IDLE;
                end
                S_NORMAL: begin
                    // Check if there is incoming sync
                    if ((last_vsync == 1'b0)&&(vga_vsync == 1'b1)) begin
                        // VSYNC
                        last_sync_duration <= ticks_since_last_sync;
                        ticks_since_last_sync <= 1'b0;
                        // Switch Buffer
                        wr_buf_sel <= ~wr_buf_sel;
                        wr_position <= 0;
                        // CSTN Vsync
                        ticks_since_last_cstn_frame <= 1'b0;
                        rd_position <= 0;
                        lcdc_vsync <= 1'b1;
                        state <= S_NORMAL;
                    end
                    else begin
                        ticks_since_last_sync <= ticks_since_last_sync + 1'd1;
                        if (ticks_since_last_cstn_frame != cstn_vsync_threshold) begin
                            ticks_since_last_cstn_frame <= ticks_since_last_cstn_frame + 1'd1;
                            if (ticks_since_last_cstn_frame > 19'd200000)
                                lcdc_vsync <= 1'b0;
                        end else begin
                            // CSTN VSYNC
                            ticks_since_last_cstn_frame <= 1'b0;
                            rd_position <= 0;
                            lcdc_vsync <= 1'b1;
                        end
                    
                        // Check if we can do anything...
                        if (!app_af_afull) begin
                            // To WR to the DRAM
                            if ((!vga_rd_empty) && (!app_wdf_afull)) begin
                                // Have incoming data.
                                // This cycle would be a writing cycle.
                                app_af_cmd <= MIG_CMD_WR;
                                app_af_wren <= 1'b1;
                                app_af_addr <= wr_pointer;
                                app_wdf_data <= wr_data_1;
                                app_wdf_mask_data <= wr_mask;
                                app_wdf_wren <= 1'b1;
                                state <= S_DDRWR;
                            end
                            else if ((!frc_wr_almost_full) && (!rd_reach_end)) begin
                                app_af_cmd <= MIG_CMD_RD;
                                app_af_wren <= 1'b1;
                                app_af_addr <= rd_pointer;
                                app_wdf_wren <= 1'b0;
                                rd_position <= rd_position_next;
                                state <= S_NORMAL;
                            end
                            else begin
                                // No incoming data, cannot read
                                app_af_wren <= 1'b0;
                                app_wdf_wren <= 1'b0;
                                state <= S_NORMAL;
                            end
                        end
                        else begin
                            app_af_wren <= 1'b0;
                            app_wdf_wren <= 1'b0;
                            state <= S_NORMAL;
                        end
                    end
                    last_vsync <= vga_vsync;
                end
                S_DDRWR: begin
                    // Update data on 2nd writing clock
                    app_af_cmd <= MIG_CMD_WR;
                    app_af_wren <= 1'b0;
                    app_wdf_data <= wr_data_2;
                    app_wdf_mask_data <= wr_mask;
                    app_wdf_wren <= 1'b1;
                    wr_position <= wr_position_next;
                    wr_upper_lower_select <= wr_upper_lower_select;
                    state <= S_NORMAL;
                end
            endcase
        end
    end
    
    assign dbg_state[1:0] = state[1:0];
   
endmodule
