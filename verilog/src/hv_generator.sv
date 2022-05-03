`include "const.vh"

module hv_generator #(
    parameter NUM_FOLDS,
    parameter NUM_FOLDS_WIDTH,
    parameter FOLD_WIDTH
) (
    input                                   clk,
    input                                   rst,

    input                                   fin_valid, // TODO: implement controller that doesn't assert fin_valid if ~var_feature
    output                                  fin_ready,
    input  [`STOP_FEATURE_WIDTH-1:0]        stop_feature, // detect stops
    input  [`S_FEATURE_WIDTH-1:0]           s_feature,    // detect [s]
    input  [`F_FEATURE_WIDTH-1:0]           f_feature,    // detect [f]
    input  [`AMP_FEATURE_WIDTH-1:0]         amp_feature,  // detect amplitude
    input  [`FORMANT_FEATURE_WIDTH-1:0]     f1_feature,   // detect formant 1
    input  [`FORMANT_FEATURE_WIDTH-1:0]     f2_feature,   // detect formant 2

    output                                  dout_valid,
    input                                   dout_ready,
    output [FOLD_WIDTH-1:0]                 im_out,
    output [FOLD_WIDTH-1:0]                 cim_out
);

    localparam seed_hv = {`SEED_HV_MSB, `SEED_HV_LSB};

    reg  [NUM_FOLDS_WIDTH-1:0]              fold_counter;
    reg  [`NUM_CHANNEL_WIDTH-1:0]           channel_counter;
    reg  [NUM_FOLDS_WIDTH-1:0]              fold_counter_delay;
    reg  [`NUM_CHANNEL_WIDTH-1:0]           channel_counter_delay;
    wire [`MAX_FEATURE_WIDTH-1:0]           curr_feature;
    reg  [FOLD_WIDTH-1:0]                   im;
    wire [`HV_DIMENSION-1:0]                cim;

    reg  [`STOP_FEATURE_WIDTH-1:0]          stop_memory;
    reg  [`S_FEATURE_WIDTH-1:0]             s_memory;
    reg  [`F_FEATURE_WIDTH-1:0]             f_memory;
    reg  [`AMP_FEATURE_WIDTH-1:0]           amp_memory;
    reg  [`FORMANT_FEATURE_WIDTH-1:0]       f1_memory;
    reg  [`FORMANT_FEATURE_WIDTH-1:0]       f2_memory;

    reg                                     im_state;
    localparam IM_IDLE              = 1'b0;
    localparam IM_PROCESS_FEATURES  = 1'b1;

    reg                                     cim_state;
    localparam CIM_IDLE         = 1'b0;
    localparam CIM_FIDX_INC     = 1'b1;

    assign fin_fire     = fin_valid && fin_ready;

    assign curr_feature = (channel_counter == 0 && fold_counter == 0) ? {7{1'b0}, stop_feature} :
                          (channel_counter == 0 && fold_counter != 0) ? {7{1'b0}, stop_memory} :
                          (channel_counter == 1) ? {7{1'b0}, s_memory} :
                          (channel_counter == 2) ? {6{1'b0}, f_memory} :
                          (channel_counter == 3) ? {6{1'b0}, amp_memory} :
                          (channel_counter == 4) ? f1_memory :
                          (channel_counter == 5) ? f2_memory : 
                          {`MAX_FEATURE_WIDTH{1'b0}};

    cim_memory_wrapper cmw (
        .curr_feature   (curr_feature),
        .cim_fidx       (channel_counter),
        .cim            (cim)
    );

    always @(posedge clk) begin
        if (rst) begin
            channel_counter <= 0;
            fold_counter    <= 0;
            cim_state       <= CIM_IDLE;
        end
   
        case (curr_state) 
            CIM_IDLE: begin
                if (fin_fire) begin
                    channel_counter <= channel_counter + 1;
                    fold_counter    <= 0;
                    cim_state       <= CIM_FIDX_INC;
                end
            end

            CIM_FIDX_INC: begin
                if (channel_counter == `NUM_CHANNEL-1) begin
                    if (fold_counter == NUM_FOLDS-1) begin
                        fold_counter    <= 0;
                        cim_state       <= CIM_IDLE;
                    end else begin
                        fold_counter    <= fold_counter + 1;
                    end

                    channel_counter <= 0;
                end else begin
                    channel_counter <= channel_counter + 1;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        channel_counter_delay   <= channel_counter;
        fold_counter_delay      <= fold_counter;
    end

    always @(posedge clk) begin
        if (rst) begin
            im_state        <= IDLE;
        end

        case (im_state)
            IM_IDLE: begin
                if (fin_fire) begin
                    im_state        <= IM_PROCESS_FEATURES;

                    im              <= {seed_hv[0 +: FOLD_WIDTH-1], seed_hv[FOLD_WIDTH-1]} ^ {seed_hv[0], seed_hv[1 +: FOLD_WIDTH-1]};
                    stop_memory     <= stop_feature;
                    s_memory        <= s_feature;
                    f_memory        <= f_feature;
                    amp_memory      <= amp_feature;
                    f1_memory       <= f1_feature;
                    f2_memory       <= f2_feature;
                end
            end

            IM_PROCESS_FEATURES: begin // For each fold, go through all the channels
                if (channel_counter_delay == `NUM_CHANNEL-1) begin
                    if (fold_counter_delay == NUM_FOLDS-1) begin
                        im          <= {seed_hv[0 +: FOLD_WIDTH-1], seed_hv[FOLD_WIDTH-1]} ^ {seed_hv[0], seed_hv[1 +: FOLD_WIDTH-1]};
                        im_state    <= IM_IDLE;
                    end else begin
                        im          <= {seed_hv[((fold_counter_delay + 1) * FOLD_WIDTH) +: FOLD_WIDTH-1], seed_hv[((fold_counter_delay + 1) * FOLD_WIDTH) + (FOLD_WIDTH-1)]} ^ {seed_hv[((fold_counter_delay + 1) * FOLD_WIDTH)], seed_hv[(((fold_counter_delay + 1) * FOLD_WIDTH) + 1) +: FOLD_WIDTH-1]};
                    end
                end else begin
                    im  <= {im[FOLD_WIDTH-2:0], im[FOLD_WIDTH-1]} ^ {im[0], im[FOLD_WIDTH-1:1]};
                end
            end
        endcase
    end

    assign fin_ready    = (cim_state == CIM_IDLE && im_state == IM_IDLE);
    assign dout_valid   = (im_state != IDLE);

    assign im_out       = im;
    assign cim_out      = cim[(fold_counter_delay * FOLD_WIDTH) +: FOLD_WIDTH];

endmodule : hv_generator
