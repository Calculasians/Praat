`timescale 1ns / 1ps

module z1top #(
    parameter N = 18
) (
    input           CLK_125MHZ_FPGA,
    input           SCLR,
    input  [N-1:0]  XN_RE,
    input  [N-1:0]  XN_IM,
    input           FD_IN,
    output          RFFD,
    output [N-1:0]  XK_RE,
    output [N-1:0]  XK_IM,
    output [3:0]    BLK_EXP,
    output          FD_OUT,
    output          DATA_VALID
);

    dft_0 dft_0 (
        .CLK        (CLK_125MHZ_FPGA),
        .SCLR       (SCLR),
        .XN_RE      (XN_RE),
        .XN_IM      (XN_IM),
        .FD_IN      (FD_IN),
        .RFFD       (RFFD),
        .SIZE       (4),
        .FWD_INV    (1'b1),
        .XK_RE      (XK_RE),
        .XK_IM      (XK_IM),
        .BLK_EXP    (BLK_EXP),
        .FD_OUT     (FD_OUT),
        .DATA_VALID (DATA_VALID)
    );

endmodule