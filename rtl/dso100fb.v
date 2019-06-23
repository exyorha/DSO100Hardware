module dso100fb (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock_intf CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_ASYNC_RESET RST_N, ASSOCIATED_BUSIF APB:AHB" *)
    input         CLK,
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 vid_clock_intf CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_ASYNC_RESET RST_N, ASSOCIATED_BUSIF VIDEO" *)
    input         VIDCLK,
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_intf RST" *)
    input         RST_N,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PADDR" *)
    input  [31:0] PADDR,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PENABLE" *)
    input         PENABLE,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PRDATA" *)
    output [31:0] PRDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PREADY" *)
    output        PREADY,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PSLVERR" *)
    output        PSLVERR,        
        
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PSEL" *)
    input         PSEL,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PWDATA" *)
    input  [31:0] PWDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB PWRITE" *)
    input         PWRITE,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HADDR" *)
    output [31:0] HADDR,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HBURST" *)
    output  [2:0] HBURST,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HPROT" *)
    output  [3:0] HPROT,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HRDATA" *)
    input  [31:0] HRDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HREADY" *)
    input         HREADY,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HRESP" *)
    input         HRESP,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HSIZE" *)
    output  [2:0] HSIZE,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HTRANS" *)   
    output  [1:0] HTRANS,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HWDATA" *)
    output [31:0] HWDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HWRITE" *)
    output        HWRITE,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:ahblite:2.0 AHB HMASTLOCK" *)
    output        HMASTLOCK,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO DATA" *)
    output [31:0] VID_DATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO ACTIVE_VIDEO" *)
    output        VID_DE,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO HSYNC" *)
    output        VID_HSYNC,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO VSYNC" *)
    output        VID_VSYNC,
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt_rtl:1.0 INTR INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY LEVEL_HIGH" *)
    output        INTR,
    
    output        LCD_ENABLE,
    output        BL_ENABLE,
    
    output        OVERLAY_EN,
    input         OVERLAY_VALID,
    input  [31:0] OVERLAY_DATA,
    output        OVERLAY_SYNC,
    
    output        VID_RST_N          
);

    wire start;
    wire stop;
    wire started;
    wire stopped;
    wire [1:0] state;

    wire fetch_en;
    wire [31:0] fetch_fb_base;
    wire [31:0] fetch_fb_end;

    wire fifo_less_than_write_threshold;
    wire fifo_full;
    wire fifo_write;
    wire [31:0] fifo_write_data;
    
    wire [11:0] timing_widthbeforeoverlay;
    wire [11:0] timing_widthoverlay;
    wire [11:0] timing_widthafteroverlay;
    wire [11:0] timing_hfrontporch;
    wire [11:0] timing_hsyncpulse;
    wire [11:0] timing_hbackporch;
    wire [11:0] timing_heightbeforeoverlay;
    wire [11:0] timing_heightoverlay;
    wire [11:0] timing_heightafteroverlay;
    wire [11:0] timing_vfrontporch;
    wire [11:0] timing_vsyncpulse;
    wire [11:0] timing_vbackporch;
    wire hsync_polarity;
    wire vsync_polarity;
    wire de_polarity;    
    
    wire sync_enable;
    
    wire video_fetch;
    wire fetch_reset;
    wire read_reset;
        
    wire frame;
    
    wire video_empty;
    wire [31:0] video_pixel;
    
    wire de;
    wire hsync;
    wire vsync;
    
    reg vid_rst_n = 1'b0;
    reg vid_rst_sync = 1'b0;
    
    always @ (posedge VIDCLK)
        { vid_rst_n, vid_rst_sync } = { vid_rst_sync, RST_N };
    
    assign VID_RST_N = vid_rst_n;
    
    dso100fb_registers regs (
        .CLK(CLK),
        .RST_N(RST_N),
        
        .PADDR(PADDR),
        .PENABLE(PENABLE),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSEL(PSEL),
        .PSLVERR(PSLVERR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        
        .INTR(INTR),
        
        .START(start),
        .STOP(stop),
        .STARTED(started),
        .STOPPED(stopped),
        .STATE(state),
        
        .FETCH_FB_BASE(fetch_fb_base),
        .FETCH_FB_END(fetch_fb_end),
        
        .TIMING_WIDTHBEFOREOVERLAY(timing_widthbeforeoverlay),
        .TIMING_WIDTHOVERLAY(timing_widthoverlay),
        .TIMING_WIDTHAFTEROVERLAY(timing_widthafteroverlay),
        .TIMING_HFRONTPORCH(timing_hfrontporch),
        .TIMING_HSYNCPULSE(timing_hsyncpulse),
        .TIMING_HBACKPORCH(timing_hbackporch),
        .TIMING_HEIGHTBEFOREOVERLAY(timing_heightbeforeoverlay),
        .TIMING_HEIGHTOVERLAY(timing_heightoverlay),
        .TIMING_HEIGHTAFTEROVERLAY(timing_heightafteroverlay),
        .TIMING_VFRONTPORCH(timing_vfrontporch),
        .TIMING_VSYNCPULSE(timing_vsyncpulse),
        .TIMING_VBACKPORCH(timing_vbackporch),
        .HSYNC_POLARITY(hsync_polarity),
        .VSYNC_POLARITY(vsync_polarity),
        .DE_POLARITY(de_polarity)
    );

    dso100fb_startstop startstop (
        .CLK(CLK),
        .RST_N(RST_N),
        
        .START(start),
        .STOP(stop),
        .STARTED(started),
        .STOPPED(stopped),
        .STATE(state),
        
        .FETCH_EN(fetch_en),
        .LCD_ENABLE(LCD_ENABLE),
        .SYNC_ENABLE(sync_enable),
        .FRAME(frame),
        .BL_ENABLE(BL_ENABLE)
    );
    
    dso100fb_fetch fetch (
        .CLK(CLK),
        .RST_N(RST_N && !fetch_reset),
        
        .FETCH_EN(fetch_en),
        .FETCH_FB_BASE(fetch_fb_base),
        .FETCH_FB_END(fetch_fb_end),
        
        .HADDR(HADDR),
        .HBURST(HBURST),
        .HPROT(HPROT),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
        .HWDATA(HWDATA),
        .HWRITE(HWRITE),
        .HMASTLOCK(HMASTLOCK),
        
        .FIFO_LESS_THAN_WRITE_THRESHOLD(fifo_less_than_write_threshold),
        .FIFO_FULL(fifo_full),
        .FIFO_WRITE(fifo_write),
        .FIFO_DATA(fifo_write_data)
    );
    
    async_fifo #(
        .WIDTH(32),
        .DEPTH(9)
    ) fb_fifo (
        .RD_CLK(VIDCLK),
        .RD_RST_N(vid_rst_n && !read_reset),
        .RD(video_fetch),
        .RD_EMPTY(video_empty),
        .RD_DATA(video_pixel),
        
        .WR_CLK(CLK),
        .WR_RST_N(RST_N && !fetch_reset),
        .WR(fifo_write),
        .WR_FULL(fifo_full),
        .WR_DATA(fifo_write_data),
        .WR_LESS_THAN_HALF_FULL(fifo_less_than_write_threshold)
    );
    
    dso100fb_sync sync (
        .CLK(CLK),
        .VIDCLK(VIDCLK),
        .RST_N(RST_N),
        .VID_RST_N(vid_rst_n),
        .EN(sync_enable),
        
        .VID_DE(de),
        .VID_HSYNC(hsync),
        .VID_VSYNC(vsync),
        
        .VIDEO_FETCH(video_fetch),
        .FETCH_RESET(fetch_reset),
        .READ_RESET(read_reset),
        .OVERLAY_EN(OVERLAY_EN),
        .OVERLAY_SYNC(OVERLAY_SYNC),
        
        .WIDTHBEFOREOVERLAY(timing_widthbeforeoverlay),
        .WIDTHOVERLAY(timing_widthoverlay),
        .WIDTHAFTEROVERLAY(timing_widthafteroverlay),
        .HFRONTPORCH(timing_hfrontporch),
        .HSYNCPULSE(timing_hsyncpulse),
        .HBACKPORCH(timing_hbackporch),
        .HEIGHTBEFOREOVERLAY(timing_heightbeforeoverlay),
        .HEIGHTOVERLAY(timing_heightoverlay),
        .HEIGHTAFTEROVERLAY(timing_heightafteroverlay),
        .VFRONTPORCH(timing_vfrontporch),
        .VSYNCPULSE(timing_vsyncpulse),
        .VBACKPORCH(timing_vbackporch),
        .HSYNC_POLARITY(hsync_polarity),
        .VSYNC_POLARITY(vsync_polarity),
        .DE_POLARITY(de_polarity),
        
        .FRAME(frame)
    );
    
    dso100fb_video_mix mixer (
        .VIDCLK(VIDCLK),
        .RST_N(vid_rst_n),
        
        .VIDEO_FETCH(video_fetch),
        .VIDEO_EMPTY(video_empty),
        .VIDEO_DATA(video_pixel),
        .OVERLAY_EN(OVERLAY_EN),
        .OVERLAY_VALID(OVERLAY_VALID),
        .OVERLAY_DATA(OVERLAY_DATA),
        
        .DE(de),
        .HSYNC(hsync),
        .VSYNC(vsync),
        
        .VID_DATA(VID_DATA),
        .VID_DE(VID_DE),
        .VID_HSYNC(VID_HSYNC),
        .VID_VSYNC(VID_VSYNC)
    );
    
endmodule
