initial begin : test
        integer S5_REPEAT;
        integer s5_i;
        integer s5_row_w;
        integer s5_row_r;
        integer s5_wr_gap;
        integer s5_rd_gap;
        integer s5_wr_interleave_gap;
        integer s5_rd_interleave_gap;

        time    s5_t_start;
        time    s5_t_end;

        real    s5_total_time_ns;
        real    s5_total_bytes;
        real    s5_throughput_gbs;
        real    s5_peak_gbs;
        real    s5_efficiency_percent;

        reg [8*DQ_BITS-1:0] s5_data;

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

        S5_REPEAT = 1000;

        s5_row_w = 1;
        s5_row_r = 0;

        s5_data = {8*DQ_BITS{1'b1}};

        s5_wr_gap = max(tras - trcd, wl + bl/2 + twr) + trp;
        s5_rd_gap = max(tras - trcd, al + bl/2 + trtp) + trp;

        s5_wr_interleave_gap = s5_wr_gap - (trcd + 1);
        s5_rd_interleave_gap = s5_rd_gap - (trcd + 1);

        $display("--------------------------------------------------");
        $display("SCENARIO 5: WB0L1, WB1L1, RB0L1, RB1L1");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("WRITE same-bank gap = %0d cycles", s5_wr_gap);
        $display("READ same-bank gap = %0d cycles", s5_rd_gap);
        $display("WRITE interleave tail gap = %0d cycles", s5_wr_interleave_gap);
        $display("READ interleave tail gap = %0d cycles", s5_rd_interleave_gap);
        $display("Repeat count = %0d", S5_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 5 PREFILL started", $time);

        activate        (0, s5_row_r);
        nop             (trcd - 1);

        write           (0, 0, 1, 0, s5_data);
        nop             (s5_wr_gap - 1);

        activate        (1, s5_row_r);
        nop             (trcd - 1);

        write           (1, 0, 1, 0, s5_data);
        nop             (s5_wr_gap - 1);

        $display("%m at time %t: SCENARIO 5 PREFILL finished", $time);

        s5_t_start = $time;

        for (s5_i = 0; s5_i < S5_REPEAT; s5_i = s5_i + 1) begin
            activate        (0, s5_row_w);
            nop             (trcd - 1);

            write           (0, 0, 1, 0, s5_data);

            activate        (1, s5_row_w);
            nop             (trcd - 1);

            write           (1, 0, 1, 0, s5_data);
            nop             (s5_wr_interleave_gap - 1);

            activate        (0, s5_row_r);
            nop             (trcd - 1);

            read            (0, 0, 1);

            activate        (1, s5_row_r);
            nop             (trcd - 1);

            read            (1, 0, 1);
            nop             (s5_rd_interleave_gap - 1);

            s5_row_r = s5_row_w;
            s5_row_w = s5_row_w + 1;
        end

        s5_t_end = $time;

        s5_total_time_ns  = (s5_t_end - s5_t_start) / 1000.0;
        s5_total_bytes    = S5_REPEAT * 4.0 * bl * DQ_BITS / 8.0;
        s5_throughput_gbs = s5_total_bytes / s5_total_time_ns;
        s5_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s5_efficiency_percent = 100.0 * s5_throughput_gbs / s5_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 5 RESULT");
        $display("Start time          = %t", s5_t_start);
        $display("End time            = %t", s5_t_end);
        $display("Total time          = %0f ns", s5_total_time_ns);
        $display("Useful data         = %0f Bytes", s5_total_bytes);
        $display("Throughput          = %0f GB/s", s5_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s5_peak_gbs);
        $display("Efficiency          = %0f %%", s5_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end