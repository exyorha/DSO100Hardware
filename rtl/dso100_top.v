`timescale 1ns / 1ps

module dso100_top(
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    OTG_RESETN,
    OTG_VBUSOC,

    HD_CLK,
    HD_D,
    HD_DE,
    HD_VSYNC,
    HD_HSYNC,
    VGA_R,
    VGA_G,
    VGA_B,
    VGA_HS,
    VGA_VS
);
    
    inout [14:0]DDR_addr;
    inout [2:0]DDR_ba;
    inout DDR_cas_n;
    inout DDR_ck_n;
    inout DDR_ck_p;
    inout DDR_cke;
    inout DDR_cs_n;
    inout [3:0]DDR_dm;
    inout [31:0]DDR_dq;
    inout [3:0]DDR_dqs_n;
    inout [3:0]DDR_dqs_p;
    inout DDR_odt;
    inout DDR_ras_n;
    inout DDR_reset_n;
    inout DDR_we_n;
    inout FIXED_IO_ddr_vrn;
    inout FIXED_IO_ddr_vrp;
    inout [53:0]FIXED_IO_mio;
    inout FIXED_IO_ps_clk;
    inout FIXED_IO_ps_porb;
    inout FIXED_IO_ps_srstb;
    inout OTG_RESETN;
    input OTG_VBUSOC;
            
    output        HD_CLK;
    output [15:0] HD_D;
    output        HD_DE;
    output        HD_VSYNC;
    output        HD_HSYNC;
    
    output  [4:1] VGA_R;
    output  [4:1] VGA_G;
    output  [4:1] VGA_B;
    output        VGA_HS;
    output        VGA_VS;

    wire [31:0]AHB_EXT_haddr;
    wire [2:0]AHB_EXT_hburst;
    wire [3:0]AHB_EXT_hprot;
    wire [31:0]AHB_EXT_hrdata;
    wire AHB_EXT_hready_in;
    wire AHB_EXT_hready_out;
    wire AHB_EXT_hresp;
    wire [2:0]AHB_EXT_hsize;
    wire [1:0]AHB_EXT_htrans;
    wire [31:0]AHB_EXT_hwdata;
    wire AHB_EXT_hwrite;
    wire AHB_EXT_sel;
    wire [31:0]APB_EXT_paddr;
    wire APB_EXT_penable;
    wire [31:0]APB_EXT_prdata;
    wire [0:0]APB_EXT_pready;
    wire [0:0]APB_EXT_psel;
    wire [0:0]APB_EXT_pslverr;
    wire [31:0]APB_EXT_pwdata;
    wire APB_EXT_pwrite;
    wire [0:0]INTR_EXT;
    wire RST_N;
    wire VID_CLK;
    wire CLK;
    
    wire [31:0] VID_DATA;
    wire VID_DE;
    wire VID_HSYNC;
    wire VID_VSYNC;

    wire LCD_ENABLE;
    wire BL_ENABLE;

    wire OVERLAY_EN;
    wire OVERLAY_VALID;
    wire [31:0] OVERLAY_DATA;
    wire OVERLAY_SYNC;
    wire VID_RST_N;
        
    dso100_wrapper dso100 (
        .AHB_EXT_haddr(AHB_EXT_haddr),
        .AHB_EXT_hburst(AHB_EXT_hburst),
        .AHB_EXT_hprot(AHB_EXT_hprot),
        .AHB_EXT_hrdata(AHB_EXT_hrdata),
        .AHB_EXT_hready_in(AHB_EXT_hready_in),
        .AHB_EXT_hready_out(AHB_EXT_hready_out),
        .AHB_EXT_hresp(AHB_EXT_hresp),
        .AHB_EXT_hsize(AHB_EXT_hsize),
        .AHB_EXT_htrans(AHB_EXT_htrans),
        .AHB_EXT_hwdata(AHB_EXT_hwdata),
        .AHB_EXT_hwrite(AHB_EXT_hwrite),
        .AHB_EXT_sel(AHB_EXT_sel),
        .APB_EXT_paddr(APB_EXT_paddr),
        .APB_EXT_penable(APB_EXT_penable),
        .APB_EXT_prdata(APB_EXT_prdata),
        .APB_EXT_pready(APB_EXT_pready),
        .APB_EXT_psel(APB_EXT_psel),
        .APB_EXT_pslverr(APB_EXT_pslverr),
        .APB_EXT_pwdata(APB_EXT_pwdata),
        .APB_EXT_pwrite(APB_EXT_pwrite),
        .CLK(CLK),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .INTR_EXT(INTR_EXT),
        .OTG_RESETN(OTG_RESETN),
        .OTG_VBUSOC(OTG_VBUSOC),
        .RST_N(RST_N),
        .VID_CLK(VID_CLK)
    );
      
    assign AHB_EXT_sel = 1'b1;
    assign AHB_EXT_hready_in = AHB_EXT_hready_out;
      
    dso100fb fb (
        .CLK(CLK),
        .VIDCLK(VID_CLK),
        .RST_N(RST_N),
        .PADDR(APB_EXT_paddr),
        .PENABLE(APB_EXT_penable),
        .PRDATA(APB_EXT_prdata),
        .PREADY(APB_EXT_pready),
        .PSLVERR(APB_EXT_pslverr),
        .PSEL(APB_EXT_psel),
        .PWDATA(APB_EXT_pwdata),
        .PWRITE(APB_EXT_pwrite),
        .HADDR(AHB_EXT_haddr),
        .HBURST(AHB_EXT_hburst),
        .HPROT(AHB_EXT_hprot),
        .HRDATA(AHB_EXT_hrdata),
        .HREADY(AHB_EXT_hready_out),
        .HRESP(AHB_EXT_hresp),
        .HSIZE(AHB_EXT_hsize),
        .HTRANS(AHB_EXT_htrans),
        .HWDATA(AHB_EXT_hwdata),
        .HWRITE(AHB_EXT_hwrite),
        .HMASTLOCK(),
        .VID_DATA(VID_DATA),
        .VID_DE(VID_DE),
        .VID_HSYNC(VID_HSYNC),
        .VID_VSYNC(VID_VSYNC),
        .INTR(INTR_EXT[0]),
        .LCD_ENABLE(LCD_ENABLE),
        .BL_ENABLE(BL_ENABLE),
        .OVERLAY_EN(OVERLAY_EN),
        .OVERLAY_DATA(OVERLAY_DATA),
        .OVERLAY_SYNC(OVERLAY_SYNC),
        .VID_RST_N(VID_RST_N)
    );
    
    dso100_zedboard_video_formatter video_formatter (
        .CLK(VID_CLK),
        .RST_N(VID_RST_N),
        .VID_DATA(VID_DATA),
        .VID_DE(VID_DE),
        .VID_HSYNC(VID_HSYNC),
        .VID_VSYNC(VID_VSYNC),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_VSYNC(HD_VSYNC),
        .HD_HSYNC(HD_HSYNC),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
    );
    
    assign HD_CLK = VID_CLK;
        
    assign OVERLAY_VALID = 1'b0;
    assign OVERLAY_DATA = 32'b0;
          
endmodule
