module async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 11,
    parameter WR_THRESHOLD = 1'b0,
    localparam WORDS = 1 << DEPTH
) (
    input                     RD_CLK,
    input                     RD_RST_N,
    input                     RD,
    output reg                RD_EMPTY,
    output reg [WIDTH - 1: 0] RD_DATA,
    
    input                     WR_CLK,
    input                     WR_RST_N,
    input                     WR,
    output reg                WR_FULL,
    input      [WIDTH - 1:0]  WR_DATA,
    output                    WR_LESS_THAN_HALF_FULL,
    output reg                WR_ABOVE_THRESHOLD
);
        
    reg [DEPTH:0] rptr;
    reg [DEPTH:0] wptr;
    
    wire [DEPTH - 1:0] wr_addr;
    wire [DEPTH - 1:0] rd_addr;
               
    reg [WIDTH - 1:0] mem [0:WORDS - 1];
    
    reg [DEPTH:0] wq1_rptr;
    reg [DEPTH:0] wq2_rptr;
        
    reg [DEPTH:0] rq1_wptr;
    reg [DEPTH:0] rq2_wptr;
        
    reg [DEPTH:0] rbin;
    wire [DEPTH:0] rgraynext, rbinnext;
        
    wire rempty_val;
    
    reg [DEPTH:0] wbin;
    wire [DEPTH:0] wgraynext, wbinnext;
        
    wire wfull_val;
        
    wire [DEPTH:0] wq2_rptr_bin;
    wire [DEPTH:0] wq2_rptr_fullval;        
    wire [DEPTH:0] wr_available;
        
    always @ (posedge WR_CLK)
    begin
        if(WR && !WR_FULL)
            mem[wr_addr] <= WR_DATA;
    end
    
    always @ (posedge RD_CLK)
        RD_DATA <= mem[rd_addr];

    always @ (posedge WR_CLK or negedge WR_RST_N)
        if(!WR_RST_N)
            { wq2_rptr, wq1_rptr } <= 0;
        else
            { wq2_rptr, wq1_rptr } <= { wq1_rptr, rptr };
           
    always @ (posedge RD_CLK or negedge RD_RST_N)
        if(!RD_RST_N)
            { rq2_wptr, rq1_wptr } <= 0;
        else
            { rq2_wptr, rq1_wptr } <= { rq1_wptr, wptr };
            
    always @ (posedge RD_CLK or negedge RD_RST_N)
        if(!RD_RST_N)
            { rbin, rptr } <= 0;
        else
            { rbin, rptr } <= { rbinnext, rgraynext };
    
    assign rd_addr = rbin[DEPTH - 1:0];
    
    assign rbinnext = rbin + (RD & ~RD_EMPTY);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;
    
    assign rempty_val = (rgraynext == rq2_wptr);
    
    always @ (posedge RD_CLK or negedge RD_RST_N)
        if(!RD_RST_N)
            RD_EMPTY <= 1'b1;
        else
            RD_EMPTY <= rempty_val;
        
    always @ (posedge WR_CLK or negedge WR_RST_N)
        if(!WR_RST_N)
            { wbin, wptr } <= 0;
        else
            { wbin, wptr } <= { wbinnext, wgraynext };
            
    assign wr_addr = wbin[DEPTH - 1:0];
    
    assign wbinnext = wbin + (WR & ~WR_FULL);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;
    
    assign wq2_rptr_fullval = { ~wq2_rptr[DEPTH:DEPTH - 1], wq2_rptr[DEPTH - 2:0] };
    assign wfull_val = wgraynext == wq2_rptr_fullval;
    
    assign WR_LESS_THAN_HALF_FULL = (wgraynext[DEPTH] ^ wq2_rptr[DEPTH]) == 1'b0;
    
    always @ (posedge WR_CLK or negedge WR_RST_N)
        if(!WR_RST_N)
            WR_FULL <= 1'b0;
        else
            WR_FULL <= wfull_val;
         
         
    genvar i;
    generate
        for(i = 0; i <= DEPTH; i = i + 1)
        begin : gray2bin
            assign wq2_rptr_bin[i] = ^(wq2_rptr_fullval >> i);
        end
    endgenerate
    
    assign wr_available = wq2_rptr_bin - wbin;
    
    always @ (posedge WR_CLK or negedge WR_RST_N)
        if(!WR_RST_N)
            WR_ABOVE_THRESHOLD <= 1'b0;
        else
            WR_ABOVE_THRESHOLD <= wr_available > WR_THRESHOLD;
        
    
endmodule
