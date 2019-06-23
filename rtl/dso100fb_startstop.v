module dso100fb_startstop (
  input CLK,
  input RST_N,

  input START,
  input STOP,
  output reg STARTED,
  output reg STOPPED,
  output reg [1:0] STATE,
  
  output reg FETCH_EN,
  output reg LCD_ENABLE,
  output reg SYNC_ENABLE,
  input FRAME,
  output reg BL_ENABLE
);

`define DSO100FB_STATE_STOPPED  2'b00
`define DSO100FB_STATE_STARTING 2'b01
`define DSO100FB_STATE_STARTED  2'b10
`define DSO100FB_STATE_STOPPING 2'b11

`define DSO100FB_STARTSTOP_STATE_IDLE           3'b000
`define DSO100FB_STARTSTOP_STATE_LCD_POWERUP1   3'b001
`define DSO100FB_STARTSTOP_STATE_LCD_POWERUP2   3'b010
`define DSO100FB_STARTSTOP_STATE_RUNNING        3'b011
`define DSO100FB_STARTSTOP_STATE_LCD_POWERDOWN1 3'b100
`define DSO100FB_STARTSTOP_STATE_LCD_POWERDOWN2 3'b101
`define DSO100FB_STATE_FIFO_RUNDOWN             3'b110

    reg [2:0] internal_state;

    always @ (posedge CLK or negedge RST_N)
        if(!RST_N)
        begin
            STATE <= `DSO100FB_STATE_STOPPED;
            internal_state <= `DSO100FB_STARTSTOP_STATE_IDLE;
            FETCH_EN <= 1'b0;
            LCD_ENABLE <= 1'b0;
            SYNC_ENABLE <= 1'b0;
            STARTED <= 1'b0;
            STOPPED <= 1'b0;
            BL_ENABLE <= 1'b0;
        end
        else
        begin
            STARTED <= 1'b0;
            STOPPED <= 1'b0;
            
            case(internal_state)
            `DSO100FB_STARTSTOP_STATE_IDLE:
                if(START)
                begin
                    STATE <= `DSO100FB_STATE_STARTING;
                    FETCH_EN <= 1'b1;
                    internal_state <= `DSO100FB_STARTSTOP_STATE_LCD_POWERUP1;
                    LCD_ENABLE <= 1'b1;
                    SYNC_ENABLE <= 1'b1;
                end
                            
            `DSO100FB_STARTSTOP_STATE_LCD_POWERUP1:
                if(FRAME)
                    internal_state <= `DSO100FB_STARTSTOP_STATE_LCD_POWERUP2;
                    
            `DSO100FB_STARTSTOP_STATE_LCD_POWERUP2:
                if(FRAME)
                begin
                    BL_ENABLE <= 1'b1;
                    internal_state <= `DSO100FB_STARTSTOP_STATE_RUNNING;
                    STATE <= `DSO100FB_STATE_STARTED;
                    STARTED <= 1'b1;
                end
                
            `DSO100FB_STARTSTOP_STATE_RUNNING:
                if(STOP)
                begin
                    STATE <= `DSO100FB_STATE_STOPPING;
                    internal_state <= `DSO100FB_STARTSTOP_STATE_LCD_POWERDOWN1;
                    BL_ENABLE <= 1'b0;
                end
                    
            `DSO100FB_STARTSTOP_STATE_LCD_POWERDOWN1:
                if(FRAME)
                    internal_state <= `DSO100FB_STARTSTOP_STATE_LCD_POWERDOWN2;
                    
            `DSO100FB_STARTSTOP_STATE_LCD_POWERDOWN2:
                if(FRAME)
                begin
                    FETCH_EN <= 1'b0;
                    internal_state <= `DSO100FB_STATE_FIFO_RUNDOWN;
                end
                
            `DSO100FB_STATE_FIFO_RUNDOWN:
                if(FRAME)
                begin
                    STATE <= `DSO100FB_STATE_STOPPED;
                    FETCH_EN <= 1'b0;
                    internal_state <= `DSO100FB_STARTSTOP_STATE_IDLE;
                    LCD_ENABLE <= 1'b0;
                    SYNC_ENABLE <= 1'b0;
                    STOPPED <= 1'b1;
                end
            endcase
        end
        
endmodule
