module dso100fb_video_mix_saturating_add (
    input [7:0] A,
    input [7:0] B,
    output [7:0] O
);

    wire [8:0] sum;

    assign sum = { 1'b0, A } + { 1'b0, B };

    assign O = sum[7:0] | { 8 { sum[8] } };

endmodule

module dso100fb_video_mix (
    input             VIDCLK,
    input             RST_N,

    input             VIDEO_FETCH,
    input             VIDEO_EMPTY,
    input      [31:0] VIDEO_DATA,

    input             OVERLAY_EN,
    input             OVERLAY_VALID,
    input      [31:0] OVERLAY_DATA,

    input             DE,
    input             HSYNC,
    input             VSYNC,

    output reg [31:0] VID_DATA,
    output reg        VID_DE,
    output reg        VID_HSYNC,
    output reg        VID_VSYNC
);

    reg video_valid, video_valid2;
    reg [31:0] video_data_delayed;
    wire [31:0] video_data;

    reg overlay_valid, overlay_valid2;
    reg [31:0] overlay_data_delayed;
    wire [31:0] overlay_data;

    wire [31:0] mixed_data;

    reg de2, hsync2, vsync2;

    always @ (posedge VIDCLK or negedge RST_N)
        if(!RST_N)
            { video_valid2, video_valid } <= 2'b0;
        else
            { video_valid2, video_valid } <= { video_valid, VIDEO_FETCH && !VIDEO_EMPTY };

    always @ (posedge VIDCLK or negedge RST_N)
        if(!RST_N)
            { overlay_valid2, overlay_valid } <= 2'b00;
        else
            { overlay_valid2, overlay_valid } <= { overlay_valid, OVERLAY_EN && OVERLAY_VALID };

    always @ (posedge VIDCLK or negedge RST_N)
        if(!RST_N)
            video_data_delayed <= 32'b0;
        else
            video_data_delayed <= VIDEO_DATA;

    always @ (posedge VIDCLK or negedge RST_N)
        if(!RST_N)
            overlay_data_delayed <= 32'b0;
        else
            overlay_data_delayed <= OVERLAY_DATA;

    assign video_data = (video_valid2 && de2) ? video_data_delayed : 32'b0;
    assign overlay_data = (overlay_valid2 && de2) ? overlay_data_delayed : 32'b0;

    genvar byte;
    generate
        for(byte = 0; byte < 4; byte = byte + 1)
        begin : add_byte
            dso100fb_video_mix_saturating_add add (
                .A(video_data[(byte + 1) * 8 - 1:(byte * 8)]),
                .B(overlay_data[(byte + 1) * 8 - 1:(byte * 8)]),
                .O(mixed_data[(byte + 1) * 8 - 1:(byte * 8)])
            );
        end
    endgenerate

    always @ (posedge VIDCLK or negedge RST_N)
        if(!RST_N)
        begin
            VID_DATA <= 32'b0;
            { VID_DE, de2 } <= 2'b0;
            { VID_HSYNC, hsync2 } <= 2'b0;
            { VID_VSYNC, vsync2 } <= 2'b0;
        end
        else
        begin
            VID_DATA <= mixed_data;
            { VID_DE, de2 } <= { de2, DE };
            { VID_HSYNC, hsync2 } <= { hsync2, HSYNC };
            { VID_VSYNC, vsync2 } <= { vsync2, VSYNC };
        end

endmodule
