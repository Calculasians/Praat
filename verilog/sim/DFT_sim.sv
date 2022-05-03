`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000

module DFT_sim();
    localparam N = 18;

    reg clk = 0;
    reg rst = 0;
    reg  [N-1:0]    XN_RE;
    reg  [N-1:0]    XN_IM;
    reg             FD_IN;
    wire            RFFD;
    wire [N-1:0]    XK_RE;
    wire [N-1:0]    XK_IM;
    wire [3:0]      BLK_EXP;
    wire            FD_OUT;
    wire            DATA_VALID;

    integer i;

    z1top #(
        .N(N)
    ) z1tp (
        .CLK_125MHZ_FPGA (clk),
        .SCLR            (rst),
        .XN_RE           (XN_RE),
        .XN_IM           ({N{1'b0}}),
        .FD_IN           (FD_IN),
        .RFFD            (RFFD),
        .XK_RE           (XK_RE),
        .XK_IM           (XK_IM),
        .BLK_EXP         (BLK_EXP),
        .FD_OUT          (FD_OUT),
        .DATA_VALID      (DATA_VALID)
    );

    // Notice that this code causes the `clk` signal to constantly
    // switch up and down every 4 time steps.
    always #(4) clk <= ~clk;

    initial begin
        FD_IN = 1'b0;
        XN_RE = {N{1'b0}};

        repeat (10) @(posedge clk);

        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;

        repeat (100) @(posedge clk);

        while (~RFFD) 
            @(posedge clk);
        
        for (i = 0; i < 4; i=i+1) begin
            if (i == 0)
                FD_IN = 1'b1;
            else 
                FD_IN = 1'b0;
            XN_RE = i;
            @(posedge clk);
        end

        XN_RE = {N{1'b0}};

        while (~RFFD) 
            @(posedge clk);

        for (i = 0; i < 4; i=i+1) begin
            if (i == 0)
                FD_IN = 1'b1;
            else 
                FD_IN = 1'b0;
            XN_RE = i;
            @(posedge clk);
        end

        XN_RE = {N{1'b0}};

        repeat (5000) @(posedge clk);

        $finish();
    end
endmodule

