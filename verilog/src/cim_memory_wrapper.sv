`include "const.vh"

module cim_memory_wrapper (
    input                               clk,

    input  [`MAX_FEATURE_WIDTH-1:0]     curr_feature,
    input  [`NUM_CHANNEL_WIDTH-1:0]     cim_fidx,
    output reg [`HV_DIMENSION-1:0]      cim
);

    localparam STOP_BASE_ADDR = 0;
    localparam S_BASE_ADDR = `STOP_NUM_FEATURES;
    localparam F_BASE_ADDR = `STOP_NUM_FEATURES + `S_NUM_FEATURES;
    localparam AMP_BASE_ADDR = `STOP_NUM_FEATURES + `S_NUM_FEATURES + `F_NUM_FEATURES;
    localparam FORMANT_BASE_ADDR = `STOP_NUM_FEATURES + `S_NUM_FEATURES + `F_NUM_FEATURES + `AMP_NUM_FEATURES;

    reg  [11:0] addr;

    wire [`HV_DIMENSION-1:0] Q;

    always @(posedge clk) begin
        cim <= Q;
    end

    always @(*) begin
        case (cim_fidx)
            0: addr = STOP_BASE_ADDR + curr_feature;
            1: addr = S_BASE_ADDR + curr_feature;
            2: addr = F_BASE_ADDR + curr_feature;
            3: addr = AMP_BASE_ADDR + curr_feature;
            4: addr = FORMANT_BASE_ADDR + curr_feature;
            5: addr = FORMANT_BASE_ADDR + curr_feature;
            default: addr = 0;
        endcase
    end

    cim_rom crm (
        .addr   (addr),
        .dout_rom   (Q)
    );

endmodule : cim_memory_wrapper
