`timescale 1ns / 1ps
`include "const.vh"

module keyspot_tb;

    localparam clock_period         = 8; // in ns

    localparam num_entry            = 970;
    localparam max_wait_time        = 0; // set to 0 to not wait between classifications
    localparam max_wait_time_width  = `ceilLog2(max_wait_time);

    localparam num_folds    = `NUM_FOLDS;
    localparam am_num_folds = `AM_NUM_FOLDS;

    reg clk, rst;

    initial clk = 0;
    initial rst = 0;
    always #(clock_period/2) clk = ~clk;

    reg                                     fin_valid;
    wire                                    fin_ready;
    reg    [`STOP_FEATURE_WIDTH-1:0]        stop_feature; // detect stops
    reg    [`S_FEATURE_WIDTH-1:0]           s_feature;    // detect [s]
    reg    [`F_FEATURE_WIDTH-1:0]           f_feature;    // detect [f]
    reg    [`AMP_FEATURE_WIDTH-1:0]         amp_feature;  // detect amplitude
    reg    [`FORMANT_FEATURE_WIDTH-1:0]     f1_feature;   // detect formant 1
    reg    [`FORMANT_FEATURE_WIDTH-1:0]     f2_feature;   // detect formant 2

    wire                                    dout_valid;
    reg                                     dout_ready;
    wire   [3:0]                            keyword;

    keyword_spotting_exploration #(
        .NUM_FOLDS      (num_folds),
        .AM_NUM_FOLDS   (am_num_folds)
    ) kse (
        .CLK_125MHZ_FPGA            (clk),
        .rst            (rst),

        .fin_valid      (fin_valid),
        .fin_ready      (fin_ready),
        .stop_feature   (stop_feature),
        .s_feature      (s_feature),
        .f_feature      (f_feature),
        .amp_feature    (amp_feature),
        .f1_feature     (f1_feature),
        .f2_feature     (f2_feature),

        .dout_valid     (dout_valid),
        .dout_ready     (dout_ready),
        .keyword        (keyword)
    );

    integer feature_file;
    integer get_feature;
    reg [`TOTAL_FEATURE_WIDTH-1:0] feature_memory [num_entry-1:0];

    initial begin
        initialize_memory();

        @(posedge clk);

        fin_valid   = 1'b0;
        dout_ready  = 1'b0;

		repeat (2) @(posedge clk);
		rst = 1'b1;
		repeat (5) @(posedge clk);
		rst = 1'b0;
		repeat (2) @(posedge clk);

		fork
			start_fin_sequence();
			// start_fin_monitor();

			start_dout_sequence();
			// start_dout_monitor();
		join

        $finish();
    end

    function void initialize_memory();
        integer i;

        feature_file    = $fopen("C:/Users/hydsu/OneDrive/Desktop/Praat/tb_database/hvs/features_binary.txt", "r");

        if (feature_file == 0) begin
            $display("Data Fetch Error");
            $finish();
        end

        for (i = 0; i < num_entry; i = i + 1) begin
            get_feature = $fscanf(feature_file, "%b\n", feature_memory[i]);
        end


    endfunction : initialize_memory

    task start_fin_sequence;

        integer i = 0;

        reg [1:0] do_wait;
        reg [max_wait_time_width-1:0] wait_time;

        while (i < num_entry) begin

			do_wait = $random() % 4;
			if (do_wait < 2) begin
				wait_time = $random() % max_wait_time;
				repeat (wait_time) @(posedge clk);
			end

            fin_valid = 1'b1;
            stop_feature    = feature_memory[i][11+11+5+5+4+4-1:11+11+5+5+4];
            s_feature       = feature_memory[i][11+11+5+5+4-1:11+11+5+5];
            f_feature       = feature_memory[i][11+11+5+5-1:11+11+5];
            amp_feature     = feature_memory[i][11+11+5-1:11+11];
            f1_feature      = feature_memory[i][11+11-1:11];
            f2_feature      = feature_memory[i][11-1:0];

            @(negedge clk);
            if (fin_ready) begin
                @(posedge clk);
                i = i + 1;
            end

            @(posedge clk);
            fin_valid = 1'b0;

        end

    endtask : start_fin_sequence

    task start_dout_sequence;

		integer i = 0;

		reg [max_wait_time_width-1:0] wait_time;

		while (i < num_entry) begin

			wait_time = $random() % max_wait_time;
			repeat (wait_time) @(posedge clk);
			dout_ready = 1'b1;

			@(negedge clk);
			if (dout_valid) i = i + 1;

			@(posedge clk);
			dout_ready = 1'b0;

		end

    endtask : start_dout_sequence

endmodule : keyspot_tb
