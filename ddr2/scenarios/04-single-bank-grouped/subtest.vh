initial begin : test
        integer S4_REPEAT;
        integer s4_i;
        integer s4_row_w1;
        integer s4_row_w2;
        integer s4_row_r1;
        integer s4_row_r2;
        integer s4_wr_gap;
        integer s4_rd_gap;

        time    s4_t_start;
        time    s4_t_end;

        real    s4_total_time_ns;
        real    s4_total_bytes;
        real    s4_throughput_gbs;
        real    s4_peak_gbs;
        real    s4_efficiency_percent;

        reg [8*DQ_BITS-1:0] s4_data;

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

        S4_REPEAT = 1000;

        s4_row_w1 = 2;
        s4_row_w2 = 3;
        s4_row_r1 = 0;
        s4_row_r2 = 1;

        s4_data = {8*DQ_BITS{1'b1}};

        s4_wr_gap = max(tras - trcd, wl + bl/2 + twr) + trp;
        s4_rd_gap = max(tras - trcd, al + bl/2 + trtp) + trp;

        $display("--------------------------------------------------");
        $display("SCENARIO 4: WB0L1, WB0L1, RB0L1, RB0L1");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("WRITE-to-next-ACT gap = %0d cycles", s4_wr_gap);
        $display("READ-to-next-ACT gap = %0d cycles", s4_rd_gap);
        $display("Repeat count = %0d", S4_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 4 PREFILL started", $time);

        activate        (0, s4_row_r1);
        nop             (trcd - 1);

        write           (0, 0, 1, 0, s4_data);
        nop             (s4_wr_gap - 1);

        activate        (0, s4_row_r2);
        nop             (trcd - 1);

        write           (0, 0, 1, 0, s4_data);
        nop             (s4_wr_gap - 1);

        $display("%m at time %t: SCENARIO 4 PREFILL finished", $time);

        s4_t_start = $time;

        for (s4_i = 0; s4_i < S4_REPEAT; s4_i = s4_i + 1) begin
            activate        (0, s4_row_w1);
            nop             (trcd - 1);

            write           (0, 0, 1, 0, s4_data);
            nop             (s4_wr_gap - 1);

            activate        (0, s4_row_w2);
            nop             (trcd - 1);

            write           (0, 0, 1, 0, s4_data);
            nop             (s4_wr_gap - 1);

            activate        (0, s4_row_r1);
            nop             (trcd - 1);

            read            (0, 0, 1);
            nop             (s4_rd_gap - 1);

            activate        (0, s4_row_r2);
            nop             (trcd - 1);

            read            (0, 0, 1);
            nop             (s4_rd_gap - 1);

            s4_row_r1 = s4_row_w1;
            s4_row_r2 = s4_row_w2;
            s4_row_w1 = s4_row_w1 + 2;
            s4_row_w2 = s4_row_w2 + 2;
        end

        s4_t_end = $time;

        s4_total_time_ns  = (s4_t_end - s4_t_start) / 1000.0;
        s4_total_bytes    = S4_REPEAT * 4.0 * bl * DQ_BITS / 8.0;
        s4_throughput_gbs = s4_total_bytes / s4_total_time_ns;
        s4_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s4_efficiency_percent = 100.0 * s4_throughput_gbs / s4_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 4 RESULT");
        $display("Start time          = %t", s4_t_start);
        $display("End time            = %t", s4_t_end);
        $display("Total time          = %0f ns", s4_total_time_ns);
        $display("Useful data         = %0f Bytes", s4_total_bytes);
        $display("Throughput          = %0f GB/s", s4_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s4_peak_gbs);
        $display("Efficiency          = %0f %%", s4_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end