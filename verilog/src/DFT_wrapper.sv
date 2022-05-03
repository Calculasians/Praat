module DFT_wrapper (


);

    typedef enum {
        IDLE,
        WAIT_RFFD,
        
    } state_t;

    dft_0 dft_0 (
        .CLK        (),
        .XN_RE      (),
        .XN_IM      (),
        .FD_IN      (1'b1),
        .RFFD       (),
        .SIZE       (),
        .FORWARD    (),
        .XK_RE      (),
        .XK_IM      (),
        .BLK_EXP    (),
        .FD_OUT     (),
        .DATA_VALID ()
    );

endmodule : DFT_wrapper