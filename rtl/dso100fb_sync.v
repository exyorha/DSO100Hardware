module dso100fb_sync (
    input        CLK,
    input        VIDCLK,
    input        RST_N,
    input        VID_RST_N,
    input        EN,
    
    output reg   VID_DE,
    output reg   VID_HSYNC,
    output reg   VID_VSYNC,
      
    output       VIDEO_FETCH,
    output       OVERLAY_EN,
    output       OVERLAY_SYNC,
    output       FETCH_RESET,
    output reg   READ_RESET,
    
    input [11:0] WIDTHBEFOREOVERLAY,
    input [11:0] WIDTHOVERLAY,
    input [11:0] WIDTHAFTEROVERLAY,
    input [11:0] HFRONTPORCH,
    input [11:0] HSYNCPULSE,
    input [11:0] HBACKPORCH,
    input [11:0] HEIGHTBEFOREOVERLAY,
    input [11:0] HEIGHTOVERLAY,
    input [11:0] HEIGHTAFTEROVERLAY,
    input [11:0] VFRONTPORCH,
    input [11:0] VSYNCPULSE,
    input [11:0] VBACKPORCH,
    input        HSYNC_POLARITY,
    input        VSYNC_POLARITY,
    input        DE_POLARITY,
    
    output       FRAME
);

    `define DSO100FB_HSTATE_IDLE                3'b000
    `define DSO100FB_HSTATE_FRONT_PORCH         3'b001
    `define DSO100FB_HSTATE_SYNC_PULSE          3'b010
    `define DSO100FB_HSTATE_BACK_PORCH          3'b011
    `define DSO100FB_HSTATE_BEFORE_OVERLAY      3'b100
    `define DSO100FB_HSTATE_OVERLAY             3'b101
    `define DSO100FB_HSTATE_AFTER_OVERLAY       3'b110
    
    `define DSO100FB_VSTATE_IDLE                3'b000
    `define DSO100FB_VSTATE_FRONT_PORCH         3'b001
    `define DSO100FB_VSTATE_SYNC_PULSE          3'b010
    `define DSO100FB_VSTATE_BACK_PORCH          3'b011
    `define DSO100FB_VSTATE_BEFORE_OVERLAY      3'b100
    `define DSO100FB_VSTATE_OVERLAY             3'b101
    `define DSO100FB_VSTATE_AFTER_OVERLAY       3'b110
     
    reg en_sync, en_video;
    
    reg [2:0] hstate;
    reg [2:0] vstate;
    
    reg frame;
    reg line;
    
    reg [11:0] hcounter;
    reg [11:0] vcounter;
    
    wire hcounter_end;
    wire vcounter_end;
    
    wire de;
    reg hde;
    reg vde;
    reg hsync;
    reg vsync;
    reg v_overlay_en;
    reg h_overlay_en;
    
    wire de_pol;
    wire hsync_pol;
    wire vsync_pol;
    
    reg frame_req;
    reg frame_sync, frame_main, frame_delayed;
    reg frame_ack_sync, frame_ack_video;
    

    reg [11:0] WIDTHBEFOREOVERLAY_vid;
    reg [11:0] WIDTHOVERLAY_vid;
    reg [11:0] WIDTHAFTEROVERLAY_vid;
    reg [11:0] HFRONTPORCH_vid;
    reg [11:0] HSYNCPULSE_vid;
    reg [11:0] HBACKPORCH_vid;
    reg [11:0] HEIGHTBEFOREOVERLAY_vid;
    reg [11:0] HEIGHTOVERLAY_vid;
    reg [11:0] HEIGHTAFTEROVERLAY_vid;
    reg [11:0] VFRONTPORCH_vid;
    reg [11:0] VSYNCPULSE_vid;
    reg [11:0] VBACKPORCH_vid;
    reg        HSYNC_POLARITY_vid;
    reg        VSYNC_POLARITY_vid;
    reg        DE_POLARITY_vid;
    
    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
        begin
            WIDTHBEFOREOVERLAY_vid <= 12'b0;
            WIDTHOVERLAY_vid <= 12'b0;
            WIDTHAFTEROVERLAY_vid <= 12'b0;
            HFRONTPORCH_vid <= 12'b0;
            HSYNCPULSE_vid <= 12'b0;
            HBACKPORCH_vid <= 12'b0;
            HEIGHTBEFOREOVERLAY_vid <= 12'b0;
            HEIGHTOVERLAY_vid <= 12'b0;
            HEIGHTAFTEROVERLAY_vid <= 12'b0;
            VFRONTPORCH_vid <= 12'b0;
            VSYNCPULSE_vid <= 12'b0;
            VBACKPORCH_vid <= 12'b0;
            HSYNC_POLARITY_vid <= 1'b0;
            VSYNC_POLARITY_vid <= 1'b0;
            DE_POLARITY_vid <= 1'b0;
        end
        else
        begin
            WIDTHBEFOREOVERLAY_vid <= WIDTHBEFOREOVERLAY;
            WIDTHOVERLAY_vid <= WIDTHOVERLAY;
            WIDTHAFTEROVERLAY_vid <= WIDTHAFTEROVERLAY;
            HFRONTPORCH_vid <= HFRONTPORCH;
            HSYNCPULSE_vid <= HSYNCPULSE;
            HBACKPORCH_vid <= HBACKPORCH;
            HEIGHTBEFOREOVERLAY_vid <= HEIGHTBEFOREOVERLAY;
            HEIGHTOVERLAY_vid <= HEIGHTOVERLAY;
            HEIGHTAFTEROVERLAY_vid <= HEIGHTAFTEROVERLAY;
            VFRONTPORCH_vid <= VFRONTPORCH;
            VSYNCPULSE_vid <= VSYNCPULSE;
            VBACKPORCH_vid <= VBACKPORCH;
            HSYNC_POLARITY_vid <= HSYNC_POLARITY;
            VSYNC_POLARITY_vid <= VSYNC_POLARITY;
            DE_POLARITY_vid <= DE_POLARITY;
        end
            
    
    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
            frame_req <= 1'b0;
        else
            frame_req <= (frame_req || frame) && !frame_ack_video;
            
    always @ (posedge CLK or negedge RST_N)
        if(!RST_N)
            { frame_delayed, frame_main, frame_sync } <= 3'b000;
        else
            { frame_delayed, frame_main, frame_sync } <= { frame_main, frame_sync, frame_req };
            
    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
            { frame_ack_video, frame_ack_sync } <= 2'b00;
        else
            { frame_ack_video, frame_ack_sync } <= { frame_ack_sync, frame_main };
    
    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
            READ_RESET <= 1'b0;
        else
        begin
            if(frame)
                READ_RESET <= 1'b1;
            else if(frame_ack_video)
                READ_RESET <= 1'b0;
        end
    
    assign FRAME = frame_main && !frame_delayed;
    assign de = hde && vde;
    assign OVERLAY_EN = h_overlay_en && v_overlay_en;
    assign FETCH_RESET = frame_main || frame_delayed;
    
    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
            { en_video, en_sync } <= 2'b00;
        else
            { en_video, en_sync } <= { en_sync, EN };

    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
        begin
            hstate <= `DSO100FB_HSTATE_IDLE;
            hcounter <= 12'b0;
            hsync <= 1'b0;
            hde <= 1'b0;
            h_overlay_en <= 1'b0;
            line <= 1'b0;
        end
        else
        begin
            line <= 1'b0; 
            if(hcounter_end || !en_video)
                case(hstate)
                `DSO100FB_HSTATE_IDLE:
                    if(en_video)
                    begin
                        hstate <= `DSO100FB_HSTATE_FRONT_PORCH;
                        hcounter <= HFRONTPORCH_vid;
                    end
                    
                `DSO100FB_HSTATE_FRONT_PORCH:
                    if(en_video)
                    begin
                        hstate <= `DSO100FB_HSTATE_SYNC_PULSE;
                        hsync <= 1'b1;
                        hcounter <= HSYNCPULSE_vid;
                        line <= 1'b1;
                    end
                    else
                    begin
                        hstate <= `DSO100FB_HSTATE_IDLE;
                    end
                
                `DSO100FB_HSTATE_SYNC_PULSE:
                begin
                    hstate <= `DSO100FB_HSTATE_BACK_PORCH;
                    hsync <= 1'b0;
                    hcounter <= HBACKPORCH_vid;
                end
                
                `DSO100FB_HSTATE_BACK_PORCH:
                begin
                    hde <= 1'b1;
                    
                    if(|WIDTHBEFOREOVERLAY_vid)
                    begin
                        hstate <= `DSO100FB_HSTATE_BEFORE_OVERLAY;
                        hcounter <= WIDTHBEFOREOVERLAY_vid;
                    end
                    else if(|WIDTHOVERLAY_vid)
                    begin
                        hstate <= `DSO100FB_HSTATE_OVERLAY;
                        hcounter <= WIDTHOVERLAY_vid;
                        h_overlay_en <= 1'b1;                    
                    end
                    else
                    begin
                        hstate <= `DSO100FB_HSTATE_AFTER_OVERLAY;
                        hcounter <= WIDTHAFTEROVERLAY_vid;                    
                    end
                end
                
                `DSO100FB_HSTATE_BEFORE_OVERLAY:
                    if(|WIDTHOVERLAY_vid)
                    begin
                        hstate <= `DSO100FB_HSTATE_OVERLAY;
                        hcounter <= WIDTHOVERLAY_vid;
                        h_overlay_en <= 1'b1;
                    end
                    else if(|WIDTHAFTEROVERLAY_vid)
                    begin
                        hstate <= `DSO100FB_HSTATE_AFTER_OVERLAY;
                        hcounter <= WIDTHAFTEROVERLAY_vid;     
                    end
                    else
                    begin
                        hde <= 1'b0;
                        hstate <= `DSO100FB_HSTATE_FRONT_PORCH;
                        hcounter <= HFRONTPORCH_vid;                        
                    end
                    
                `DSO100FB_HSTATE_OVERLAY:
                begin
                    h_overlay_en <= 1'b0;
                    
                    if(|WIDTHAFTEROVERLAY_vid)
                    begin
                        hstate <= `DSO100FB_HSTATE_AFTER_OVERLAY;
                        hcounter <= WIDTHAFTEROVERLAY_vid;     
                    end
                    else
                    begin
                        hde <= 1'b0;
                        hstate <= `DSO100FB_HSTATE_FRONT_PORCH;
                        hcounter <= HFRONTPORCH_vid;                        
                    end
                end
                
                `DSO100FB_HSTATE_AFTER_OVERLAY:
                begin
                    hde <= 1'b0;
                    hstate <= `DSO100FB_HSTATE_FRONT_PORCH;
                    hcounter <= HFRONTPORCH_vid;    
                end
            endcase
            else
                hcounter <= hcounter - 1'b1;
        end
        
    always @ (posedge VIDCLK or negedge VID_RST_N)
    if(!VID_RST_N)
    begin
        vstate <= `DSO100FB_HSTATE_IDLE;
        vcounter <= 12'b0;
        vsync <= 1'b0;
        vde <= 1'b0;
        v_overlay_en <= 1'b0;
        frame <= 1'b0;
    end
    else
    begin
        frame <= 1'b0; 
        if(line || !en_video)
        begin           
            if(vcounter_end || !en_video)
                case(vstate)
                `DSO100FB_VSTATE_IDLE:
                    if(en_video)
                    begin
                        vstate <= `DSO100FB_VSTATE_FRONT_PORCH;
                        vcounter <= HFRONTPORCH_vid;
                    end
                    
                `DSO100FB_VSTATE_FRONT_PORCH:
                begin
                    frame <= 1'b1;
                    if(en_video)
                    begin
                        vstate <= `DSO100FB_VSTATE_SYNC_PULSE;
                        vsync <= 1'b1;
                        vcounter <= VSYNCPULSE_vid;
                    end
                    else
                    begin
                        vstate <= `DSO100FB_VSTATE_IDLE;
                    end
                end
                
                `DSO100FB_VSTATE_SYNC_PULSE:
                begin
                    vstate <= `DSO100FB_VSTATE_BACK_PORCH;
                    vsync <= 1'b0;
                    vcounter <= VBACKPORCH_vid;
                end
                
                `DSO100FB_VSTATE_BACK_PORCH:
                begin
                    vde <= 1'b1;
                    
                    if(|HEIGHTBEFOREOVERLAY_vid)
                    begin
                        vstate <= `DSO100FB_VSTATE_BEFORE_OVERLAY;
                        vcounter <= HEIGHTBEFOREOVERLAY_vid;
                    end
                    else if(|HEIGHTOVERLAY_vid)
                    begin
                        vstate <= `DSO100FB_VSTATE_OVERLAY;
                        vcounter <= HEIGHTOVERLAY_vid;
                        v_overlay_en <= 1'b1;                    
                    end
                    else
                    begin
                        vstate <= `DSO100FB_VSTATE_AFTER_OVERLAY;
                        vcounter <= HEIGHTAFTEROVERLAY_vid;                    
                    end
                end
                
                `DSO100FB_VSTATE_BEFORE_OVERLAY:
                    if(|HEIGHTOVERLAY_vid)
                    begin
                        vstate <= `DSO100FB_VSTATE_OVERLAY;
                        vcounter <= HEIGHTOVERLAY_vid;
                        v_overlay_en <= 1'b1;
                    end
                    else if(|HEIGHTAFTEROVERLAY_vid)
                    begin
                        vstate <= `DSO100FB_VSTATE_AFTER_OVERLAY;
                        vcounter <= HEIGHTAFTEROVERLAY_vid;     
                    end
                    else
                    begin
                        vde <= 1'b0;
                        vstate <= `DSO100FB_VSTATE_FRONT_PORCH;
                        vcounter <= VFRONTPORCH_vid;                        
                    end
                    
                `DSO100FB_VSTATE_OVERLAY:
                begin
                    v_overlay_en <= 1'b0;
                    
                    if(|HEIGHTAFTEROVERLAY_vid)
                    begin
                        vstate <= `DSO100FB_VSTATE_AFTER_OVERLAY;
                        vcounter <= HEIGHTAFTEROVERLAY_vid;     
                    end
                    else
                    begin
                        vde <= 1'b0;
                        vstate <= `DSO100FB_VSTATE_FRONT_PORCH;
                        vcounter <= VFRONTPORCH_vid;                        
                    end
                end
                
                `DSO100FB_VSTATE_AFTER_OVERLAY:
                begin
                    vde <= 1'b0;
                    vstate <= `DSO100FB_VSTATE_FRONT_PORCH;
                    vcounter <= VFRONTPORCH_vid;    
                end
                endcase
            else
              vcounter <= vcounter - 1'b1;
        end
    end


    assign hcounter_end = !(|hcounter[11:1]);
    assign vcounter_end = !(|vcounter[11:1]);
     
    assign de_pol = de ^ DE_POLARITY_vid; 
    assign hsync_pol = hsync ^ HSYNC_POLARITY_vid;
    assign vsync_pol = vsync ^ VSYNC_POLARITY_vid;
    
    always @ (posedge VIDCLK or negedge VID_RST_N)
        if(!VID_RST_N)
        begin
            VID_DE <= 1'b0;
            VID_HSYNC <= 1'b0;
            VID_VSYNC <= 1'b0;
        end
        else
        begin
            VID_DE <= de_pol;
            VID_HSYNC <= hsync_pol;
            VID_VSYNC <= vsync_pol;
        end
    
    assign VIDEO_FETCH = de;
    assign OVERLAY_SYNC = frame;
    
endmodule

