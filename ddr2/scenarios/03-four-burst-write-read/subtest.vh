initial begin : test
        integer S3_REPEAT;
        integer s3_i;
        integer s3_row_w;
        integer s3_row_r;
        integer s3_col_gap;
        integer s3_wr_tail_gap;
        integer s3_rd_tail_gap;

        time    s3_t_start;
        time    s3_t_end;

        real    s3_total_time_ns;
        real    s3_total_bytes;
        real    s3_throughput_gbs;
        real    s3_peak_gbs;
        real    s3_efficiency_percent;

        reg [8*DQ_BITS-1:0] s3_data;

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

        S3_REPEAT = 1000;

        s3_row_w = 1;
        s3_row_r = 0;

        s3_data = {8*DQ_BITS{1'b1}};

        s3_col_gap = bl / 2;

        s3_wr_tail_gap = max(tras + trp - (trcd + 3*s3_col_gap), wl + bl/2 + twr + trp);
        s3_rd_tail_gap = max(tras + trp - (trcd + 3*s3_col_gap), al + bl/2 + trtp + trp - 1);

        $display("--------------------------------------------------");
        $display("SCENARIO 3: WB0L4, RB0L4");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("Column command gap = %0d cycles", s3_col_gap);
        $display("Last WRITE-to-next-ACT gap = %0d cycles", s3_wr_tail_gap);
        $display("Last READ-to-next-ACT gap = %0d cycles", s3_rd_tail_gap);
        $display("Repeat count = %0d", S3_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 3 PREFILL started", $time);

        activate        (0, s3_row_r);
        nop             (trcd - 1);

        write           (0, 0,  0, 0, s3_data);
        nop             (s3_col_gap - 1);

        write           (0, 8,  0, 0, s3_data);
        nop             (s3_col_gap - 1);

        write           (0, 16, 0, 0, s3_data);
        nop             (s3_col_gap - 1);

        write           (0, 24, 1, 0, s3_data);
        nop             (s3_wr_tail_gap - 1);

        $display("%m at time %t: SCENARIO 3 PREFILL finished", $time);

        s3_t_start = $time;

        for (s3_i = 0; s3_i < S3_REPEAT; s3_i = s3_i + 1) begin
            activate        (0, s3_row_w);
            nop             (trcd - 1);

            write           (0, 0,  0, 0, s3_data);
            nop             (s3_col_gap - 1);

            write           (0, 8,  0, 0, s3_data);
            nop             (s3_col_gap - 1);

            write           (0, 16, 0, 0, s3_data);
            nop             (s3_col_gap - 1);

            write           (0, 24, 1, 0, s3_data);
            nop             (s3_wr_tail_gap - 1);

            activate        (0, s3_row_r);
            nop             (trcd - 1);

            read            (0, 0,  0);
            nop             (s3_col_gap - 1);

            read            (0, 8,  0);
            nop             (s3_col_gap - 1);

            read            (0, 16, 0);
            nop             (s3_col_gap - 1);

            read            (0, 24, 1);
            nop             (s3_rd_tail_gap - 1);

            s3_row_r = s3_row_w;
            s3_row_w = s3_row_w + 1;
        end

        s3_t_end = $time;

        s3_total_time_ns  = (s3_t_end - s3_t_start) / 1000.0;
        s3_total_bytes    = S3_REPEAT * 8.0 * bl * DQ_BITS / 8.0;
        s3_throughput_gbs = s3_total_bytes / s3_total_time_ns;
        s3_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s3_efficiency_percent = 100.0 * s3_throughput_gbs / s3_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 3 RESULT");
        $display("Start time          = %t", s3_t_start);
        $display("End time            = %t", s3_t_end);
        $display("Total time          = %0f ns", s3_total_time_ns);
        $display("Useful data         = %0f Bytes", s3_total_bytes);
        $display("Throughput          = %0f GB/s", s3_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s3_peak_gbs);
        $display("Efficiency          = %0f %%", s3_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end