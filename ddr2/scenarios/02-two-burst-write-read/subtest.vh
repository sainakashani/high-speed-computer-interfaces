initial begin : test
        integer S2_REPEAT;
        integer s2_i;
        integer s2_row_w;
        integer s2_row_r;
        integer s2_col_gap;
        integer s2_wr_tail_gap;
        integer s2_rd_tail_gap;

        time    s2_t_start;
        time    s2_t_end;

        real    s2_total_time_ns;
        real    s2_total_bytes;
        real    s2_throughput_gbs;
        real    s2_peak_gbs;
        real    s2_efficiency_percent;

        reg [8*DQ_BITS-1:0] s2_data;

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

        S2_REPEAT = 1000;

        s2_row_w = 1;
        s2_row_r = 0;

        s2_data = {8*DQ_BITS{1'b1}};

        s2_col_gap = bl / 2;

        s2_wr_tail_gap = max(tras + trp - (trcd + s2_col_gap), wl + bl/2 + twr + trp);
        s2_rd_tail_gap = max(tras + trp - (trcd + s2_col_gap), al + bl/2 + trtp + trp - 1);

        $display("--------------------------------------------------");
        $display("SCENARIO 2: WB0L2, RB0L2");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("Column command gap = %0d cycles", s2_col_gap);
        $display("Last WRITE-to-next-ACT gap = %0d cycles", s2_wr_tail_gap);
        $display("Last READ-to-next-ACT gap = %0d cycles", s2_rd_tail_gap);
        $display("Repeat count = %0d", S2_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 2 PREFILL started", $time);

        activate        (0, s2_row_r);
        nop             (trcd - 1);

        write           (0, 0, 0, 0, s2_data);
        nop             (s2_col_gap - 1);

        write           (0, 8, 1, 0, s2_data);
        nop             (s2_wr_tail_gap - 1);

        $display("%m at time %t: SCENARIO 2 PREFILL finished", $time);

        s2_t_start = $time;

        for (s2_i = 0; s2_i < S2_REPEAT; s2_i = s2_i + 1) begin
            activate        (0, s2_row_w);
            nop             (trcd - 1);

            write           (0, 0, 0, 0, s2_data);
            nop             (s2_col_gap - 1);

            write           (0, 8, 1, 0, s2_data);
            nop             (s2_wr_tail_gap - 1);

            activate        (0, s2_row_r);
            nop             (trcd - 1);

            read            (0, 0, 0);
            nop             (s2_col_gap - 1);

            read            (0, 8, 1);
            nop             (s2_rd_tail_gap - 1);

            s2_row_r = s2_row_w;
            s2_row_w = s2_row_w + 1;
        end

        s2_t_end = $time;

        s2_total_time_ns  = (s2_t_end - s2_t_start) / 1000.0;
        s2_total_bytes    = S2_REPEAT * 4.0 * bl * DQ_BITS / 8.0;
        s2_throughput_gbs = s2_total_bytes / s2_total_time_ns;
        s2_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s2_efficiency_percent = 100.0 * s2_throughput_gbs / s2_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 2 RESULT");
        $display("Start time          = %t", s2_t_start);
        $display("End time            = %t", s2_t_end);
        $display("Total time          = %0f ns", s2_total_time_ns);
        $display("Useful data         = %0f Bytes", s2_total_bytes);
        $display("Throughput          = %0f GB/s", s2_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s2_peak_gbs);
        $display("Efficiency          = %0f %%", s2_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end