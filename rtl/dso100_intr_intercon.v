`timescale 1ns / 1ps
module dso100_intr_intercon(
    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt_rtl:1.0 DSO100FB_INTR INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY LEVEL_HIGH" *)
    input         DSO100FB_INTR,
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt_rtl:1.0 PS_INTR INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY LEVEL_HIGH" *)
    output [0:0] PS_INTR
);

    assign PS_INTR = { DSO100FB_INTR };

endmodule
