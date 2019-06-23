module dso100fb_fetch (
  input             CLK,
  input             RST_N,
  
  input             FETCH_EN,
  input      [31:0] FETCH_FB_BASE,
  input      [31:0] FETCH_FB_END,

  output     [31:0] HADDR,
  output      [2:0] HBURST,
  output      [3:0] HPROT,
  input      [31:0] HRDATA,
  input             HREADY,
  input             HRESP,
  output      [2:0] HSIZE,
  output reg  [1:0] HTRANS,
  output     [31:0] HWDATA,
  output            HWRITE,
  output            HMASTLOCK,
  
  input             FIFO_LESS_THAN_WRITE_THRESHOLD,
  input             FIFO_FULL,
  
  output            FIFO_WRITE,
  output     [31:0] FIFO_DATA
);

    `define DSO100FB_FETCH_STATE_IDLE               2'b00
    `define DSO100FB_FETCH_STATE_WAITING_FOR_FIFO   2'b01
    `define DSO100FB_FETCH_STATE_FETCHING           2'b10
    
    reg [31:2] shadow_base;
    reg [31:2] shadow_end;
    
    reg [31:2] address_counter;
    
    reg [1:0] fetch_state;
    
    reg init_address;
    wire wraparound;
    
    assign wraparound = address_counter == shadow_end;
        
    always @ (posedge CLK)
        if(init_address || (FIFO_WRITE && wraparound))
            address_counter <= shadow_base;
        else if(FIFO_WRITE)
            address_counter <= address_counter + 32'b1;
                
    always @ (posedge CLK or negedge RST_N)
        if(!RST_N)
        begin
            shadow_base <= 30'b0;
            shadow_end <= 30'b0;
            fetch_state <= `DSO100FB_FETCH_STATE_IDLE;
            init_address <= 1'b0;
            HTRANS <= 2'b00;
        end
        else
        begin
            init_address <= 1'b0;
            
            case(fetch_state)
            `DSO100FB_FETCH_STATE_IDLE:
                if(FETCH_EN)
                begin
                    shadow_base <= FETCH_FB_BASE[31:2];
                    shadow_end <= FETCH_FB_END[31:2];
                    init_address <= 1'b1;
                    fetch_state <= `DSO100FB_FETCH_STATE_WAITING_FOR_FIFO;
                end
                
            `DSO100FB_FETCH_STATE_WAITING_FOR_FIFO:
                if(!FETCH_EN)
                begin
                    fetch_state <= `DSO100FB_FETCH_STATE_IDLE;
                end
                else if(FIFO_LESS_THAN_WRITE_THRESHOLD)
                begin
                    fetch_state <= `DSO100FB_FETCH_STATE_FETCHING;
                    HTRANS <= 2'b10;                    
                end
                
            `DSO100FB_FETCH_STATE_FETCHING:
                if(HREADY)
                begin
                    if(FIFO_FULL)
                    begin
                        HTRANS <= 2'b00;
                        fetch_state <= `DSO100FB_FETCH_STATE_WAITING_FOR_FIFO;
                    end
                    else
                    begin
                        if(address_counter[9:2] == 8'b1111_1111 || wraparound)
                            HTRANS <= 2'b10;   
                        else
                            HTRANS <= 2'b11;
                    end
                end
            default: ;
            endcase
        end
        
    assign HADDR = { address_counter, 2'b00 };
    assign HBURST = 3'b001;
    assign HPROT = 4'b1111;
        
    assign HSIZE = 2'b010;
    
    assign HWDATA = 32'b0;
    assign HWRITE = 1'b0;
    assign HMASTLOCK = 1'b0;
    
    assign FIFO_WRITE = |HTRANS & HREADY & !FIFO_FULL;
    assign FIFO_DATA = HRDATA;
    
endmodule
