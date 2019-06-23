module dso100fb_test;
    `include "dso100fb_interface.v"

    reg clk;
    reg vidclk;
    reg rst_n;
    reg [31:0] paddr;
    reg penable;
    wire [31:0] prdata;
    wire pready;
    wire psvlerr;
    reg psel;
    reg [31:0] pwdata;
    reg pwrite;
    
    wire [31:0] haddr;
    wire [2:0] hburst;
    wire [3:0] hprot;
    wire [31:0] hrdata;
    wire hready;
    wire hresp;
    wire [2:0] hsize;
    wire [1:0] htrans;
    wire [31:0] hwdata;
    wire hwrite;
    wire hmastlock;
    
    wire [31:0] vid_data;
    wire vid_de;
    wire vid_hsync;
    wire vid_vsync;
    
    wire lcd_enable;
    wire bl_enable;
    
    wire intr;
    
    wire overlay_en;
    wire overlay_valid;
    wire [31:0] overlay_data;
    wire overlay_sync;
    
    assign hready = 1'b1;
    assign hresp = 1'b0;
    assign hrdata = haddr;
    
    dso100fb uut (
        .CLK(clk),
        .VIDCLK(vidclk),
        .RST_N(rst_n),
        .PADDR(paddr),
        .PENABLE(penable),
        .PRDATA(prdata),
        .PREADY(pready),
        .PSLVERR(psvlerr),
        .PSEL(psel),
        .PWDATA(pwdata),
        .PWRITE(pwrite),
        .HADDR(haddr),
        .HBURST(hburst),
        .HPROT(hprot),
        .HRDATA(hrdata),
        .HREADY(hready),
        .HRESP(hresp),
        .HSIZE(hsize),
        .HTRANS(htrans),
        .HWDATA(hwdata),
        .HWRITE(hwrite),
        .HMASTLOCK(hmastlock),
        
        .VID_DATA(vid_data),
        .VID_DE(vid_de),
        .VID_HSYNC(vid_hsync),
        .VID_VSYNC(vid_vsync),
        
        .INTR(intr),
        
        .LCD_ENABLE(lcd_enable),
        .BL_ENABLE(bl_enable),
        
        .OVERLAY_EN(overlay_en),
        .OVERLAY_VALID(overlay_valid),
        .OVERLAY_DATA(overlay_data),
        .OVERLAY_SYNC(overlay_sync)
    );
    
    assign overlay_valid = 1'b0;
    
    task apb_write;
    input [31:0] address;
    input [31:0] data;
    begin
        @(posedge clk);
        
        paddr = address;
        pwrite = 1'b1;
        psel = 1'b1;
        pwdata = data;
        
        @(posedge clk);
        
        penable = 1'b1;
        
        @(posedge clk);
                    
        while(!pready)
        begin
            @(posedge clk);        
        end
        
        penable = 1'b0;
        psel = 1'b0;        
    end
    endtask
    
    task apb_read;
    input [31:0] address;
    output [31:0] data;
    begin
        @(posedge clk);
    
        paddr = address;
        pwrite = 1'b0;
        psel = 1'b1;
        
        @(posedge clk);
        penable = 1'b1;
        
        @(posedge clk);
                    
        while(!pready)
        begin
            @(posedge clk);        
        end
        
        data = prdata;
        
        penable = 1'b0;
        psel = 1'b0; 
    end
    endtask

    task wait_for_interrupt;
    input [31:0] mask;
    output [31:0] status;
    begin
        apb_write({ `DSO100FB_REG_IMR, 2'b00 }, mask);
        
        while(!intr)
            @(posedge clk);
            
        apb_read({ `DSO100FB_REG_ISR, 2'b00 }, status);
        
        apb_write({ `DSO100FB_REG_ISR, 2'b00 }, ~(mask & status));
    end
    endtask

    reg [31:0] regval;

    initial
    begin
        clk = 1'b0;
        vidclk = 1'b0;
        rst_n = 1'b0;
        paddr = 32'b0;
        penable = 1'b0;
        psel = 1'b0;
        pwdata = 32'b0;
        pwrite = 32'b0;
        
        #100;
        
        rst_n = 1'b1;
        
        apb_write({ `DSO100FB_REG_FB_BASE, 2'b00 }, 32'h1000000);
        apb_write({ `DSO100FB_REG_FB_END, 2'b00 },  32'h1176FFC);
        
        apb_write({ `DSO100FB_REG_HTIMING1, 2'b00 }, { 4'b0, 12'd512, 4'b0, 12'd16 }); 
        apb_write({ `DSO100FB_REG_HTIMING2, 2'b00 }, { 4'b0, 12'd210, 4'b0, 12'd272 }); 
        apb_write({ `DSO100FB_REG_HTIMING3, 2'b00 }, { 4'b0, 12'd45, 4'b0, 12'd1 });
        apb_write({ `DSO100FB_REG_VTIMING1, 2'b00 }, { 4'b0, 12'd384, 4'b0, 12'd48 }); 
        apb_write({ `DSO100FB_REG_VTIMING2, 2'b00 }, { 4'b0, 12'd22, 4'b0, 12'd48 }); 
        apb_write({ `DSO100FB_REG_VTIMING3, 2'b00 }, { 4'b0, 12'd22, 4'b0, 12'd1 });
        
        // START request
        apb_write({ `DSO100FB_REG_CR, 2'b00 }, 32'b01);
        
        // Wait for STARTED
        wait_for_interrupt(32'b01, regval);
        
        
        // STOP request
        apb_write({ `DSO100FB_REG_CR, 2'b00 }, 32'b10);
        
        // Wait for STOPPED
        wait_for_interrupt(32'b10, regval);
        
        // START request
        apb_write({ `DSO100FB_REG_CR, 2'b00 }, 32'b01);
        
        // Wait for STARTED
        wait_for_interrupt(32'b01, regval);
                
    end
    
    always
    begin
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    end

    always
    begin
        vidclk = 1'b1;
        #12.5;
        vidclk = 1'b0;
        #12.5;
    end
    

endmodule