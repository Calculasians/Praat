`include "const.vh"

module keyword_spotting_exploration #(
    parameter NUM_FOLDS = `NUM_FOLDS,
    parameter AM_NUM_FOLDS = `AM_NUM_FOLDS
) (
    input                                   CLK_125MHZ_FPGA,
    input                                   rst,

    input                                   fin_valid,
    output                                  fin_ready,
    input  [`STOP_FEATURE_WIDTH-1:0]        stop_feature, // detect stops
    input  [`S_FEATURE_WIDTH-1:0]           s_feature,    // detect [s]
    input  [`F_FEATURE_WIDTH-1:0]           f_feature,    // detect [f]
    input  [`AMP_FEATURE_WIDTH-1:0]         amp_feature,  // detect amplitude
    input  [`FORMANT_FEATURE_WIDTH-1:0]     f1_feature,   // detect formant 1
    input  [`FORMANT_FEATURE_WIDTH-1:0]     f2_feature,   // detect formant 2

    output                                  dout_valid,
    input                                   dout_ready,
    output [3:0]                            keyword
);

	localparam NUM_FOLDS_WIDTH		= `ceilLog2(NUM_FOLDS);
	localparam FOLD_WIDTH			= `HV_DIMENSION / NUM_FOLDS;

	localparam AM_NUM_FOLDS_WIDTH	= `ceilLog2(AM_NUM_FOLDS);
	localparam AM_FOLD_WIDTH 		= `HV_DIMENSION / AM_NUM_FOLDS;

    // From hv_gen
    wire                            hv_gen_dout_valid;
    wire [FOLD_WIDTH-1:0]           hv_gen_im_out;
    wire [FOLD_WIDTH-1:0]           hv_gen_cim_out;

    // From se
    wire                            se_din_ready;
    wire                            se_hvout_valid;
    wire [`HV_DIMENSION-1:0]        se_hvout;

    // From te
    wire                            te_hvin_ready;
    wire                            te_hvout_valid;
    wire [`HV_DIMENSION-1:0]        te_hvout;

    // From am
    wire                            am_hvin_ready;

    hv_generator #(
		.NUM_FOLDS          (NUM_FOLDS),
		.NUM_FOLDS_WIDTH    (NUM_FOLDS_WIDTH),
		.FOLD_WIDTH         (FOLD_WIDTH)
    ) hv_gen (
        .clk                    (clk),
        .rst                    (rst),
        
        .fin_valid              (fin_valid),
        .fin_ready              (fin_ready),
        .stop_feature           (stop_feature),
        .s_feature              (s_feature),
        .f_feature              (f_feature),
        .amp_feature            (amp_feature),
        .f1_feature             (f1_feature),
        .f2_feature             (f2_feature),

        .dout_valid             (hv_gen_dout_valid),
        .dout_ready             (se_din_ready),
        .im_out                 (hv_gen_im_out),
        .cim_out                (hv_gen_cim_out)
    );

    spatial_encoder #(
		.NUM_FOLDS          (NUM_FOLDS),
		.NUM_FOLDS_WIDTH    (NUM_FOLDS_WIDTH),
		.FOLD_WIDTH         (FOLD_WIDTH)
    ) se (
        .clk                (clk),
        .rst                (rst),

        .din_valid          (hv_gen_dout_valid),
        .din_ready          (se_din_ready),
        .im                 (hv_gen_im_out),
        .cim                (hv_gen_cim_out),

        .hvout_valid        (se_hvout_valid),
        .hvout_ready        (te_hvin_ready),
        .hvout              (se_hvout)
    );

    temporal_encoder te (
        .clk                (clk),
        .rst                (rst),

        .hvin_valid         (se_hvout_valid),
        .hvin_ready         (te_hvin_ready),
        .hvin               (se_hvout),

        .hvout_valid        (te_hvout_valid),
        .hvout_ready        (am_hvin_ready),
        .hvout              (te_hvout)
    );

    associative_memory #(
		.AM_NUM_FOLDS          (AM_NUM_FOLDS),
		.AM_NUM_FOLDS_WIDTH    (AM_NUM_FOLDS_WIDTH),
		.AM_FOLD_WIDTH         (AM_FOLD_WIDTH)
    ) am (
        .clk                (clk),
        .rst                (rst),

        .hvin_valid         (te_hvout_valid),
        .hvin_ready         (am_hvin_ready),
        .hvin               (te_hvout),

        .dout_valid         (dout_valid),
        .dout_ready         (dout_ready),
        .keyword            (keyword)
    );

endmodule : keyword_spotting_exploration
