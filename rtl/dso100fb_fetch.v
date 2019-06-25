module dso100fb_fetch (
  input             CLK,
  input             RST_N,
  
  input             FETCH_EN,
  input      [31:0] FETCH_FB_BASE,
  input      [22:0] FETCH_FB_LENGTH,

  output        [71:0] MCMD_TDATA,
  input                MCMD_TREADY,
  output reg           MCMD_TVALID,
  
  input          [7:0] MSTS_TDATA,
  output               MSTS_TREADY,
  input                MSTS_TVALID
);

    assign MCMD_TDATA = {
        16'b0,
        FETCH_FB_BASE,
        9'b010000001,
        FETCH_FB_LENGTH
    };
    
    assign MSTS_TREADY = 1'b1;
    
    always @ (posedge CLK or negedge RST_N)
        if(!RST_N)
            MCMD_TVALID <= 1'b0;
        else
            MCMD_TVALID <= FETCH_EN && MCMD_TREADY;
            
endmodule
