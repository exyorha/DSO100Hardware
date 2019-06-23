`timescale 1ns / 1ps
module dso100_gpio_intercon(
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 EMIO TRI_T" *)
    input [0:0] EMIO_T,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 EMIO TRI_O" *)
    input [0:0] EMIO_O,
      
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 EMIO TRI_I" *)
    output [0:0] EMIO_I,
    
    (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:usbctrl_rtl:1.0 USBIND VBUS_PWRFAULT" *)
    output USBIND_PWRFAULT,
    
    inout OTG_RESETN,
    input OTG_VBUSOC
);

    IOBUF (
        .O(EMIO_I[0]),
        .I(EMIO_O[0]),
        .T(EMIO_T[0]),
        .IO(OTG_RESETN)
    );
    
    assign USBIND_PWRFAULT = ~OTG_VBUSOC;

endmodule
