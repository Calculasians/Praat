`include "const.vh"

module spatial_encoder #(
    parameter NUM_FOLDS,
    parameter NUM_FOLDS_WIDTH,
    parameter FOLD_WIDTH
) (
    input                               clk,
    input                               rst,

    input                               din_valid,
    output                              din_ready,
    input  [FOLD_WIDTH-1:0]             im,
    input  [FOLD_WIDTH-1:0]             cim,

    output reg                          hvout_valid,
    input                               hvout_ready,
    output reg [`HV_DIMENSION-1:0]      hvout
);

    wire din_fire;
    wire accum_fold_valid;

    wire [FOLD_WIDTH-1:0]           binded_im_cim;
    reg  [`NUM_CHANNEL_WIDTH-1:0]   channel_counter;
    reg  [NUM_FOLDS_WIDTH-1:0]      fold_counter;
    reg  [`NUM_CHANNEL_WIDTH-1:0]   accumulator [FOLD_WIDTH];
    reg  [FOLD_WIDTH-1:0]           accum_fold;

    reg                     state;
    localparam IDLE             = 1'b0;
    localparam PROCESS_FEATURES = 1'b1;

    assign din_fire         = din_valid && din_ready;
    assign binded_im_cim    = im ^ cim;

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            state  <= IDLE;
        end

        case (state)
            IDLE: begin
                if (din_fire) begin
                    state           <= PROCESS_FEATURES;
                    fold_counter    <= 0;
                    channel_counter <= 0;
                    for (i = 0; i < FOLD_WIDTH; i = i + 1) accumulator[i] <= {{`NUM_CHANNEL_WIDTH-1{1'b0}}, binded_im_cim[i]};
                end
            end

            PROCESS_FEATURES: begin
                if (channel_counter == `NUM_CHANNEL-1) begin
                    if (fold_counter == NUM_FOLDS-1) begin
                        fold_counter    <= 0;
                        state           <= IDLE;
                    end else begin
                        fold_counter    <= fold_counter + 1;
                    end

                    for (i = 0; i < FOLD_WIDTH; i = i + 1) accumulator[i] <= {{`NUM_CHANNEL_WIDTH-1{1'b0}}, binded_im_cim[i]};
                    channel_counter     <= 0;
                end else begin
                    for (i = 0; i < FOLD_WIDTH; i = i + 1) accumulator[i] <= accumulator[i] + {{`NUM_CHANNEL_WIDTH-1{1'b0}}, binded_im_cim[i]};
                    channel_counter     <= channel_counter + 1;
                end
            end
        endcase
    end

    assign din_ready        = (state == IDLE);
    assign accum_fold_valid = (state == PROCESS_FEATURES && channel_counter == `NUM_CHANNEL-1);
    assign last_accum_fold_valid = (state == PROCESS_FEATURES && channel_counter == `NUM_CHANNEL-1 && fold_counter == NUM_FOLDS-1);
    always @(posedge clk) begin
        hvout_valid <= last_accum_fold_valid;
    end

    integer j;
    always @(*) begin
        for (j = 0; j < FOLD_WIDTH; j = j + 1) accum_fold[j] = (accumulator[j] > `HALF_NUM_CHANNEL) ? 1'b1 : 1'b0;
    end

    integer k;
    always @(posedge clk) begin
        for (k = 0; k < `HV_DIMENSION; k = k + 1) begin
            if (accum_fold_valid) begin
                if (k >= fold_counter * FOLD_WIDTH && k < fold_counter * FOLD_WIDTH + FOLD_WIDTH) begin
                    hvout[k] <= accumulator[k - (fold_counter * FOLD_WIDTH)];
                end
            end
        end
    end


endmodule : spatial_encoder
