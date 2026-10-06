initial begin : test
        integer S1_REPEAT;
        integer s1_i;
        integer row_w;
        integer row_r;
        integer s1_wr_gap;
        integer s1_rd_gap;

        time    s1_t_start;
        time    s1_t_end;

        real    s1_total_time_ns;
        real    s1_total_bytes;
        real    s1_throughput_gbs;
        real    s1_peak_gbs;
        real    s1_efficiency_percent;

        reg [8*DQ_BITS-1:0] s1_data;

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

        S1_REPEAT = 1000;

        row_w = 1;
        row_r = 0;

        s1_data = {8*DQ_BITS{1'b1}};

        s1_wr_gap = max(tras - trcd, wl + bl/2 + twr) + trp;
        s1_rd_gap = max(tras - trcd, al + bl/2 + trtp) + trp;

        $display("--------------------------------------------------");
        $display("SCENARIO 1: WB0L1, RB0L1");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("WR-to-next-ACT gap = %0d cycles", s1_wr_gap);
        $display("RD-to-next-ACT gap = %0d cycles", s1_rd_gap);
        $display("Repeat count = %0d", S1_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 1 PREFILL started", $time);

        activate        (0, row_r);
        nop             (trcd - 1);

        write           (0, 0, 1, 0, s1_data);
        nop             (s1_wr_gap - 1);

        $display("%m at time %t: SCENARIO 1 PREFILL finished", $time);

        s1_t_start = $time;

        for (s1_i = 0; s1_i < S1_REPEAT; s1_i = s1_i + 1) begin
            activate        (0, row_w);
            nop             (trcd - 1);

            write           (0, 0, 1, 0, s1_data);
            nop             (s1_wr_gap - 1);

            activate        (0, row_r);
            nop             (trcd - 1);

            read_verify     (0, 0, 1, 0, s1_data);
            nop             (s1_rd_gap - 1);

            row_r = row_w;
            row_w = row_w + 1;
        end

        s1_t_end = $time;

        s1_total_time_ns  = (s1_t_end - s1_t_start) / 1000.0;
        s1_total_bytes    = S1_REPEAT * 2.0 * bl * DQ_BITS / 8.0;
        s1_throughput_gbs = s1_total_bytes / s1_total_time_ns;
        s1_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s1_efficiency_percent = 100.0 * s1_throughput_gbs / s1_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 1 RESULT");
        $display("Start time          = %t", s1_t_start);
        $display("End time            = %t", s1_t_end);
        $display("Total time          = %0f ns", s1_total_time_ns);
        $display("Useful data         = %0f Bytes", s1_total_bytes);
        $display("Throughput          = %0f GB/s", s1_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s1_peak_gbs);
        $display("Efficiency          = %0f %%", s1_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end