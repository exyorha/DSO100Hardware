module dso100fb_registers (
    input CLK,
    input RST_N,
    
    input      [31:0] PADDR,
    input             PENABLE,
    output reg [31:0] PRDATA,
    output            PREADY,
    output            PSLVERR,    
    input             PSEL,
    input      [31:0] PWDATA,
    input             PWRITE,
    
    output            INTR,
    
    output reg        START,
    output reg        STOP,
    input             STARTED,
    input             STOPPED,
    input       [1:0] STATE,
    
    output reg [31:0] FETCH_FB_BASE,
    output reg [22:0] FETCH_FB_LENGTH,
    
    output reg [11:0] TIMING_WIDTHBEFOREOVERLAY,
    output reg [11:0] TIMING_WIDTHOVERLAY,
    output reg [11:0] TIMING_WIDTHAFTEROVERLAY,
    output reg [11:0] TIMING_HFRONTPORCH,
    output reg [11:0] TIMING_HSYNCPULSE,
    output reg [11:0] TIMING_HBACKPORCH,
    output reg [11:0] TIMING_HEIGHTBEFOREOVERLAY,
    output reg [11:0] TIMING_HEIGHTOVERLAY,
    output reg [11:0] TIMING_HEIGHTAFTEROVERLAY,
    output reg [11:0] TIMING_VFRONTPORCH,
    output reg [11:0] TIMING_VSYNCPULSE,
    output reg [11:0] TIMING_VBACKPORCH,
    output reg        HSYNC_POLARITY,
    output reg        VSYNC_POLARITY,
    output reg        DE_POLARITY
);

    `include "dso100fb_interface.v"

    reg [1:0] isr;
    reg [1:0] imr;
    
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;

    always @ (posedge CLK or negedge RST_N)
        if(!RST_N)
        begin
            PRDATA <= 32'b0;
            START <= 1'b0;
            STOP <= 1'b0;
            
            isr <= 2'b00;
            imr <= 2'b00;
            
            FETCH_FB_BASE <= 32'b0;
            FETCH_FB_LENGTH <= 23'b0;
            TIMING_WIDTHBEFOREOVERLAY <= 12'b0;
            TIMING_WIDTHOVERLAY <= 12'b0;
            TIMING_WIDTHAFTEROVERLAY <= 12'b0;
            TIMING_HFRONTPORCH <= 12'b0;
            TIMING_HSYNCPULSE <= 12'b0;
            TIMING_HBACKPORCH <= 12'b0;
            TIMING_HEIGHTBEFOREOVERLAY <= 12'b0;
            TIMING_HEIGHTOVERLAY <= 12'b0;
            TIMING_HEIGHTAFTEROVERLAY <= 12'b0;
            TIMING_VFRONTPORCH <= 12'b0;
            TIMING_VSYNCPULSE <= 12'b0;
            TIMING_VBACKPORCH <= 12'b0;
            HSYNC_POLARITY <= 1'b0;
            VSYNC_POLARITY <= 1'b0;
            DE_POLARITY <= 1'b0;
        end
        else
        begin
            isr[`DSO100FB_ISR_STARTED] <= isr[`DSO100FB_ISR_STARTED] | STARTED;
            isr[`DSO100FB_ISR_STOPPED] <= isr[`DSO100FB_ISR_STOPPED] | STOPPED;
            START <= 1'b0;
            STOP <= 1'b0;
            
            if(PSEL)
            begin
                PRDATA <= 32'b0;
                
                case(PADDR[5:2])                
                `DSO100FB_REG_CR:
                    PRDATA[`DSO100FB_CR_STATE] <= STATE;
                                
                `DSO100FB_REG_ISR:
                    PRDATA[1:0] <= isr;
                    
                `DSO100FB_REG_IMR:
                    PRDATA[1:0] <= imr;
                    
                `DSO100FB_REG_FB_BASE:
                    PRDATA <= FETCH_FB_BASE;
                    
                `DSO100FB_REG_FB_LENGTH:
                    PRDATA[`DSO100FB_FB_LENGTH_FB_LENGTH] <= FETCH_FB_LENGTH;
                    
                `DSO100FB_REG_HTIMING1:
                begin
                    PRDATA[`DSO100FB_HTIMING1_WIDTHBEFOREOVERLAY] <= TIMING_WIDTHBEFOREOVERLAY;
                    PRDATA[`DSO100FB_HTIMING1_WIDTHOVERLAY] <= TIMING_WIDTHOVERLAY;
                end
 
               `DSO100FB_REG_HTIMING2:
               begin
                   PRDATA[`DSO100FB_HTIMING2_WIDTHAFTEROVERLAY] <= TIMING_WIDTHAFTEROVERLAY;
                   PRDATA[`DSO100FB_HTIMING2_FRONTPORCH] <= TIMING_HFRONTPORCH;
               end
               
                `DSO100FB_REG_HTIMING3:
                begin
                    PRDATA[`DSO100FB_HTIMING3_SYNCPULSE] <= TIMING_HSYNCPULSE;
                    PRDATA[`DSO100FB_HTIMING3_BACKPORCH] <= TIMING_HBACKPORCH;
                end
                
                `DSO100FB_REG_VTIMING1:
                begin
                    PRDATA[`DSO100FB_VTIMING1_HEIGHTBEFOREOVERLAY] <= TIMING_HEIGHTBEFOREOVERLAY;
                    PRDATA[`DSO100FB_VTIMING1_HEIGHTOVERLAY] <= TIMING_HEIGHTOVERLAY;
                end
 
               `DSO100FB_REG_VTIMING2:
               begin
                   PRDATA[`DSO100FB_VTIMING2_HEIGHTAFTEROVERLAY] <= TIMING_HEIGHTAFTEROVERLAY;
                   PRDATA[`DSO100FB_VTIMING2_FRONTPORCH] <= TIMING_VFRONTPORCH;
               end
               
                `DSO100FB_REG_VTIMING3:
                begin
                    PRDATA[`DSO100FB_VTIMING3_SYNCPULSE] <= TIMING_VSYNCPULSE;
                    PRDATA[`DSO100FB_VTIMING3_BACKPORCH] <= TIMING_VBACKPORCH;
                end
                
                `DSO100FB_REG_IFCTRL:
                begin
                    PRDATA[`DSO100FB_IFCTRL_HSYNC_POL] <= HSYNC_POLARITY;
                    PRDATA[`DSO100FB_IFCTRL_VSYNC_POL] <= VSYNC_POLARITY;
                    PRDATA[`DSO100FB_IFCTRL_DE_POL] <= DE_POLARITY;
                end
                
                default: ;
                endcase
                
                if(PWRITE & PENABLE)
                begin
                    case(PADDR[5:2])
                    `DSO100FB_REG_CR:
                    begin
                        START <= PWDATA[`DSO100FB_CR_START];
                        STOP <= PWDATA[`DSO100FB_CR_STOP];
                    end
                    
                    `DSO100FB_REG_ISR:
                        isr <= isr & PWDATA[1:0];
                        
                    `DSO100FB_REG_IMR:
                        imr <= PWDATA[1:0];
                        
                    `DSO100FB_REG_FB_BASE:
                        FETCH_FB_BASE <= PWDATA;
                        
                    `DSO100FB_REG_FB_LENGTH:
                        FETCH_FB_LENGTH <= PWDATA[`DSO100FB_FB_LENGTH_FB_LENGTH];
                        
                    `DSO100FB_REG_HTIMING1:
                    begin
                        TIMING_WIDTHBEFOREOVERLAY <= PWDATA[`DSO100FB_HTIMING1_WIDTHBEFOREOVERLAY];
                        TIMING_WIDTHOVERLAY <= PWDATA[`DSO100FB_HTIMING1_WIDTHOVERLAY];
                    end
                    
                    `DSO100FB_REG_HTIMING2:
                    begin
                        TIMING_WIDTHAFTEROVERLAY <= PWDATA[`DSO100FB_HTIMING2_WIDTHAFTEROVERLAY];
                        TIMING_HFRONTPORCH <= PWDATA[`DSO100FB_HTIMING2_FRONTPORCH];
                    end

                    `DSO100FB_REG_HTIMING3:
                    begin
                        TIMING_HSYNCPULSE <= PWDATA[`DSO100FB_HTIMING3_SYNCPULSE];
                        TIMING_HBACKPORCH <= PWDATA[`DSO100FB_HTIMING3_BACKPORCH];
                    end
                    
                    `DSO100FB_REG_VTIMING1:
                    begin
                        TIMING_HEIGHTBEFOREOVERLAY <= PWDATA[`DSO100FB_VTIMING1_HEIGHTBEFOREOVERLAY];
                        TIMING_HEIGHTOVERLAY <= PWDATA[`DSO100FB_VTIMING1_HEIGHTOVERLAY];
                    end
                    
                    `DSO100FB_REG_VTIMING2:
                    begin
                        TIMING_HEIGHTAFTEROVERLAY <= PWDATA[`DSO100FB_VTIMING2_HEIGHTAFTEROVERLAY];
                        TIMING_VFRONTPORCH <= PWDATA[`DSO100FB_VTIMING2_FRONTPORCH];
                    end

                    `DSO100FB_REG_VTIMING3:
                    begin
                        TIMING_VSYNCPULSE <= PWDATA[`DSO100FB_VTIMING3_SYNCPULSE];
                        TIMING_VBACKPORCH <= PWDATA[`DSO100FB_VTIMING3_BACKPORCH];
                    end
                    
                    `DSO100FB_REG_IFCTRL:
                    begin
                        HSYNC_POLARITY <= PWDATA[`DSO100FB_IFCTRL_HSYNC_POL];
                        VSYNC_POLARITY <= PWDATA[`DSO100FB_IFCTRL_VSYNC_POL];
                        DE_POLARITY <= PWDATA[`DSO100FB_IFCTRL_DE_POL];
                    end
                    
                    default: ;
                    endcase            
                end
            end
        end
        
    assign INTR = |(isr & imr);

endmodule
