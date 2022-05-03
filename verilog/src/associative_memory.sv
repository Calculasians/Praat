`include "const.vh"

module associative_memory #(
    parameter AM_NUM_FOLDS, 
	parameter AM_NUM_FOLDS_WIDTH, 
	parameter AM_FOLD_WIDTH    
) (
    input                       clk,
    input                       rst,

    input                       hvin_valid,
    output                      hvin_ready,
    input  [`HV_DIMENSION-1:0]  hvin,

    output                      dout_valid,
    input                       dout_ready,
    output reg [3:0]            keyword
);

    reg  [AM_FOLD_WIDTH-1:0]        similarity_hv;
    reg  [`DISTANCE_WIDTH-1:0]      distance_ON;
    reg  [`DISTANCE_WIDTH-1:0]      distance_OFF;
    reg  [`DISTANCE_WIDTH-1:0]      distance_GO;
    reg  [`DISTANCE_WIDTH-1:0]      distance_STOP;
    reg  [`DISTANCE_WIDTH-1:0]      distance_LEFT;
    reg  [`DISTANCE_WIDTH-1:0]      distance_RIGHT;
    reg  [`DISTANCE_WIDTH-1:0]      distance_YES;
    reg  [`DISTANCE_WIDTH-1:0]      distance_NO;
    reg  [`DISTANCE_WIDTH-1:0]      distance_UP;    
    reg  [`DISTANCE_WIDTH-1:0]      distance_DOWN;    
    wire [`DISTANCE_WIDTH-1:0]      distance;
    reg  [`DISTANCE_WIDTH-1:0]      curr_min;

    reg  [AM_NUM_FOLDS_WIDTH-1:0]   fold_counter;
    reg  [3:0]                      prototype_counter;

    // TODO: copy prototype vectors in
    localparam PROTOTYPE_ON     = 2000'b;
    localparam PROTOTYPE_OFF    = 2000'b;
    localparam PROTOTYPE_GO     = 2000'b;
    localparam PROTOTYPE_STOP   = 2000'b;
    localparam PROTOTYPE_LEFT   = 2000'b;
    localparam PROTOTYPE_RIGHT  = 2000'b;
    localparam PROTOTYPE_YES    = 2000'b;
    localparam PROTOTYPE_NO     = 2000'b;
    localparam PROTOTYPE_UP     = 2000'b;
    localparam PROTOTYPE_DOWN   = 2000'b;

    hv_binary_adder #(
        .AM_NUM_FOLDS       (AM_FOLD_WIDTH),
        .AM_NUM_FOLDS_WIDTH (AM_NUM_FOLDS_WIDTH),
        .AM_FOLD_WIDTH      (AM_FOLD_WIDTH)
    ) BIN_ADDER (
        .hv         (similarity_hv),
        .distance   (distance)
    );

    assign hvin_fire    = hvin_valid && hvin_ready;
    assign hvin_ready   = prototype_counter == 0 && fold_counter == 0;

    assign dout_fire    = dout_valid && dout_ready;
    assign dout_valid   = prototype_counter == 10;

    always @(posedge clk) begin
        if (rst || dout_fire)
            prototype_counter   <= 0;
        else if (fold_counter == AM_NUM_FOLDS-1)
            prototype_counter   <= prototype_counter + 1;
    end

    always @(posedge clk) begin
        if (rst || fold_counter == AM_NUM_FOLDS-1 || dout_fire)
            fold_counter    <= 0;
        else if (hvin_fire || (fold_counter > 0 && fold_counter < AM_NUM_FOLDS-1) ||
                        (fold_counter == 0 && prototype_counter > 0 && prototype_counter < 10))
            fold_counter    <= fold_counter + 1;
    end

    always @(*) begin
        case (prototype_counter)
            0: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_ON[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            1: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_OFF[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            2: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_GO[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            3: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_STOP[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            4: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_LEFT[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            5: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_RIGHT[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            6: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_YES[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            7: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_NO[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            8: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_UP[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            9: similarity_hv = hvin[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH] ^ PROTOTYPE_DOWN[(fold_counter * AM_FOLD_WIDTH) +: AM_FOLD_WIDTH];
            default: similarity_hv = {AM_FOLD_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_ON <= (fold_counter == 0) ? distance : distance_ON + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_OFF <= (fold_counter == 0) ? distance : distance_OFF + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_GO <= (fold_counter == 0) ? distance : distance_GO + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_STOP <= (fold_counter == 0) ? distance : distance_STOP + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_LEFT <= (fold_counter == 0) ? distance : distance_LEFT + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_RIGHT <= (fold_counter == 0) ? distance : distance_RIGHT + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_YES <= (fold_counter == 0) ? distance : distance_YES + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_NO <= (fold_counter == 0) ? distance : distance_NO + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_UP <= (fold_counter == 0) ? distance : distance_UP + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 0)
            distance_DOWN <= (fold_counter == 0) ? distance : distance_DOWN + distance;
    end

    always @(posedge clk) begin
        if (prototype_counter == 1 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_OFF + distance < distance_ON) ? 1 : 0;
            curr_min    <= (distance_OFF + distance < distance_ON) ? distance_OFF + distance : distance_ON;
        end else if (prototype_counter == 2 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_GO + distance < curr_min) ? 2 : keyword;
            curr_min    <= (distance_GO + distance < curr_min) ? distance_GO + distance : curr_min;
        end else if (prototype_counter == 3 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_STOP + distance < curr_min) ? 3 : keyword;
            curr_min    <= (distance_STOP + distance < curr_min) ? distance_STOP + distance : curr_min;
        end else if (prototype_counter == 4 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_LEFT + distance < curr_min) ? 4 : keyword;
            curr_min    <= (distance_LEFT + distance < curr_min) ? distance_LEFT + distance : curr_min;
        end else if (prototype_counter == 5 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_RIGHT + distance < curr_min) ? 5 : keyword;
            curr_min    <= (distance_RIGHT + distance < curr_min) ? distance_RIGHT + distance : curr_min;
        end else if (prototype_counter == 6 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_YES + distance < curr_min) ? 6 : keyword;
            curr_min    <= (distance_YES + distance < curr_min) ? distance_YES + distance : curr_min;
        end else if (prototype_counter == 7 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_NO + distance < curr_min) ? 7 : keyword;
            curr_min    <= (distance_NO + distance < curr_min) ? distance_NO + distance : curr_min;
        end else if (prototype_counter == 8 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_UP + distance < curr_min) ? 8 : keyword;
            curr_min    <= (distance_UP + distance < curr_min) ? distance_UP + distance : curr_min;
        end else if (prototype_counter == 9 && fold_counter == AM_NUM_FOLDS-1) begin
            keyword     <= (distance_DOWN + distance < curr_min) ? 9 : keyword;
            curr_min    <= (distance_DOWN + distance < curr_min) ? distance_DOWN + distance : curr_min;
        end
    end

endmodule : associative_memory
