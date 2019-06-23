`timescale 1ns / 1ps
module dso100_zedboard_video_formatter(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock_intf CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_ASYNC_RESET RST_N, ASSOCIATED_BUSIF VIDEO" *)
    input          CLK,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_intf RST" *)
    input          RST_N,

    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO DATA" *)
    input  [31:0] VID_DATA,

    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO ACTIVE_VIDEO" *)
    input         VID_DE,

    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO HSYNC" *)
    input         VID_HSYNC,

    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io_rtl:1.0 VIDEO VSYNC" *)
    input         VID_VSYNC,

    output reg [15:0] HD_D,
    output reg        HD_DE,
    output reg        HD_VSYNC,
    output reg        HD_HSYNC,

    output reg  [4:1] VGA_R,
    output reg  [4:1] VGA_G,
    output reg  [4:1] VGA_B,
    output reg        VGA_HS,
    output reg        VGA_VS
);

    always @ (posedge CLK or negedge RST_N)
        if(!RST_N)
        begin
            VGA_R <= 4'b0;
            VGA_G <= 4'b0;
            VGA_B <= 4'b0;
            VGA_HS <= 1'b0;
            VGA_VS <= 1'b0;
            HD_D <= 16'b0;
            HD_DE <= 1'b0;
            HD_HSYNC <= 1'b0;
            HD_VSYNC <= 1'b0;
        end
        else
        begin
            VGA_R <= VID_DATA[23:20];
            VGA_G <= VID_DATA[15:12];
            VGA_B <= VID_DATA[7:4];
            VGA_HS <= VID_HSYNC;
            VGA_VS <= VID_VSYNC;
            HD_D <= { VID_DATA[23:19], VID_DATA[15:10], VID_DATA[7:3] };
            HD_DE <= VID_DE;
            HD_HSYNC <= VID_HSYNC;
            HD_VSYNC <= VID_VSYNC;
        end


endmodule
