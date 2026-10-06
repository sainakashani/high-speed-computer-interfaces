initial begin : test
        integer S6_REPEAT;
        integer s6_i;
        integer s6_b;

        integer s6_row_w0;
        integer s6_row_w1;
        integer s6_row_w2;
        integer s6_row_w3;

        integer s6_col_gap;

        time    s6_t_start;
        time    s6_t_end;

        real    s6_total_time_ns;
        real    s6_total_bytes;
        real    s6_throughput_gbs;
        real    s6_peak_gbs;
        real    s6_efficiency_percent;

        reg [8*DQ_BITS-1:0] s6_data;

        cke     <=  1'b0;
        cs_n    <=  1'b1;
        ras_n   <=  1'b1;
        cas_n   <=  1'b1;
        we_n    <=  1'b1;
        ba      <=  {BA_BITS{1'bz}};
        a       <=  {ADDR_BITS{1'bz}};
        odt     <=  1'b0;
        dq_en   <=  1'b0;
        dqs_en  <=  1'b0;

        cke     <=  1'b1;

        power_up;

        precharge       (0, 1);
        nop             (trp);

        load_mode       (2, 0);
        nop             (tmrd-1);

        load_mode       (3, 0);
        nop             (tmrd-1);

        load_mode       (1, 13'b0_0_0_000_0_000_1_0_0);
        nop             (tmrd-1);

        load_mode       (0, 13'b0_000_1_0_000_0_011 | (twr-1)<<9 | taa<<4);
        nop             (tmrd-1);

        precharge       (0, 1);
        nop             (trp);

        refresh;
        nop             (trfc-1);

        refresh;
        nop             (trfc-1);

        load_mode       (0, 13'b0_000_0_0_000_0_011 | (twr-1)<<9 | taa<<4);
        nop             (tmrd-1);

        load_mode       (1, 13'b0_0_0_111_0_000_1_0_0);
        nop             (tmrd-1);

        load_mode       (1, 13'b0_0_0_000_0_000_1_0_0);
        nop             (tmrd-1);

        nop             (200);

        S6_REPEAT = 1000;

        s6_row_w0 = 0;
        s6_row_w1 = 1;
        s6_row_w2 = 2;
        s6_row_w3 = 3;

        s6_data = {8*DQ_BITS{1'b1}};

        s6_col_gap = bl / 2;

        $display("--------------------------------------------------");
        $display("SCENARIO 6: WB0L32, WB1L32, WB2L32, WB3L32");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("Column command gap = %0d cycles", s6_col_gap);
        $display("Repeat count = %0d", S6_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 6 PIPELINE PRIMING started", $time);

        activate        (0, s6_row_w0);
        nop             (trcd - 1);

        $display("%m at time %t: SCENARIO 6 PIPELINE PRIMING finished", $time);

        s6_t_start = $time;

        for (s6_i = 0; s6_i < S6_REPEAT; s6_i = s6_i + 1) begin

            for (s6_b = 0; s6_b < 32; s6_b = s6_b + 1) begin
                if (s6_b == 0) begin
                    write           (0, s6_b*8, 0, 0, s6_data);
                    activate        (1, s6_row_w1);
                    nop             (2);
                end else if (s6_b == 31) begin
                    write           (0, s6_b*8, 1, 0, s6_data);
                    nop             (3);
                end else begin
                    write           (0, s6_b*8, 0, 0, s6_data);
                    nop             (3);
                end
            end

            for (s6_b = 0; s6_b < 32; s6_b = s6_b + 1) begin
                if (s6_b == 0) begin
                    write           (1, s6_b*8, 0, 0, s6_data);
                    activate        (2, s6_row_w2);
                    nop             (2);
                end else if (s6_b == 31) begin
                    write           (1, s6_b*8, 1, 0, s6_data);
                    nop             (3);
                end else begin
                    write           (1, s6_b*8, 0, 0, s6_data);
                    nop             (3);
                end
            end

            for (s6_b = 0; s6_b < 32; s6_b = s6_b + 1) begin
                if (s6_b == 0) begin
                    write           (2, s6_b*8, 0, 0, s6_data);
                    activate        (3, s6_row_w3);
                    nop             (2);
                end else if (s6_b == 31) begin
                    write           (2, s6_b*8, 1, 0, s6_data);
                    nop             (3);
                end else begin
                    write           (2, s6_b*8, 0, 0, s6_data);
                    nop             (3);
                end
            end

            for (s6_b = 0; s6_b < 32; s6_b = s6_b + 1) begin
                if (s6_b == 0) begin
                    write           (3, s6_b*8, 0, 0, s6_data);

                    s6_row_w0 = s6_row_w0 + 4;

                    activate        (0, s6_row_w0);
                    nop             (2);
                end else if (s6_b == 31) begin
                    write           (3, s6_b*8, 1, 0, s6_data);
                    nop             (3);
                end else begin
                    write           (3, s6_b*8, 0, 0, s6_data);
                    nop             (3);
                end
            end

            s6_row_w1 = s6_row_w1 + 4;
            s6_row_w2 = s6_row_w2 + 4;
            s6_row_w3 = s6_row_w3 + 4;
        end

        s6_t_end = $time;

        s6_total_time_ns  = (s6_t_end - s6_t_start) / 1000.0;
        s6_total_bytes    = S6_REPEAT * 4.0 * 32.0 * bl * DQ_BITS / 8.0;
        s6_throughput_gbs = s6_total_bytes / s6_total_time_ns;
        s6_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s6_efficiency_percent = 100.0 * s6_throughput_gbs / s6_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 6 RESULT");
        $display("Start time          = %t", s6_t_start);
        $display("End time            = %t", s6_t_end);
        $display("Total time          = %0f ns", s6_total_time_ns);
        $display("Useful data         = %0f Bytes", s6_total_bytes);
        $display("Throughput          = %0f GB/s", s6_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s6_peak_gbs);
        $display("Efficiency          = %0f %%", s6_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end