initial begin : test
        integer S7_REPEAT;
        integer s7_i;
        integer s7_b;
        integer s7_pf;

        integer s7_row_r0;
        integer s7_row_r1;
        integer s7_row_r2;
        integer s7_row_r3;

        integer s7_col_gap;
        integer s7_wr_tail_gap;

        time    s7_t_start;
        time    s7_t_end;

        real    s7_total_time_ns;
        real    s7_total_bytes;
        real    s7_throughput_gbs;
        real    s7_peak_gbs;
        real    s7_efficiency_percent;

        reg [8*DQ_BITS-1:0] s7_data;

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

        S7_REPEAT = 1000;

        s7_row_r0 = 0;
        s7_row_r1 = 1;
        s7_row_r2 = 2;
        s7_row_r3 = 3;

        s7_data = {8*DQ_BITS{1'b1}};

        s7_col_gap = bl / 2;
        s7_wr_tail_gap = wl + bl/2 + twr + trp;

        $display("--------------------------------------------------");
        $display("SCENARIO 7: RB0L32, RB1L32, RB2L32, RB3L32");
        $display("Speed Grade = sg3E");
        $display("BL = %0d, DQ_BITS = %0d", bl, DQ_BITS);
        $display("tCK = %0f ns", tck/1000.0);
        $display("CL = %0d, WL = %0d, AL = %0d, RL = %0d", cl, wl, al, rl);
        $display("trcd = %0d, trp = %0d, tras = %0d, twr = %0d, trtp = %0d", trcd, trp, tras, twr, trtp);
        $display("Column command gap = %0d cycles", s7_col_gap);
        $display("Write tail gap used for prefill = %0d cycles", s7_wr_tail_gap);
        $display("Repeat count = %0d", S7_REPEAT);
        $display("--------------------------------------------------");

        $display("%m at time %t: SCENARIO 7 PREFILL started", $time);

        for (s7_pf = 0; s7_pf < S7_REPEAT; s7_pf = s7_pf + 1) begin
            activate        (0, 4*s7_pf + 0);
            nop             (trcd - 1);

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 31) begin
                    write           (0, s7_b*8, 1, 0, s7_data);
                    nop             (s7_wr_tail_gap - 1);
                end else begin
                    write           (0, s7_b*8, 0, 0, s7_data);
                    nop             (s7_col_gap - 1);
                end
            end

            activate        (1, 4*s7_pf + 1);
            nop             (trcd - 1);

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 31) begin
                    write           (1, s7_b*8, 1, 0, s7_data);
                    nop             (s7_wr_tail_gap - 1);
                end else begin
                    write           (1, s7_b*8, 0, 0, s7_data);
                    nop             (s7_col_gap - 1);
                end
            end

            activate        (2, 4*s7_pf + 2);
            nop             (trcd - 1);

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 31) begin
                    write           (2, s7_b*8, 1, 0, s7_data);
                    nop             (s7_wr_tail_gap - 1);
                end else begin
                    write           (2, s7_b*8, 0, 0, s7_data);
                    nop             (s7_col_gap - 1);
                end
            end

            activate        (3, 4*s7_pf + 3);
            nop             (trcd - 1);

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 31) begin
                    write           (3, s7_b*8, 1, 0, s7_data);
                    nop             (s7_wr_tail_gap - 1);
                end else begin
                    write           (3, s7_b*8, 0, 0, s7_data);
                    nop             (s7_col_gap - 1);
                end
            end
        end

        $display("%m at time %t: SCENARIO 7 PREFILL finished", $time);

        s7_row_r0 = 0;
        s7_row_r1 = 1;
        s7_row_r2 = 2;
        s7_row_r3 = 3;

        $display("%m at time %t: SCENARIO 7 PIPELINE PRIMING started", $time);

        activate        (0, s7_row_r0);
        nop             (trcd - 1);

        $display("%m at time %t: SCENARIO 7 PIPELINE PRIMING finished", $time);

        s7_t_start = $time;

        for (s7_i = 0; s7_i < S7_REPEAT; s7_i = s7_i + 1) begin

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 0) begin
                    read            (0, s7_b*8, 0);
                    activate        (1, s7_row_r1);
                    nop             (2);
                end else if (s7_b == 31) begin
                    read            (0, s7_b*8, 1);
                    nop             (3);
                end else begin
                    read            (0, s7_b*8, 0);
                    nop             (3);
                end
            end

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 0) begin
                    read            (1, s7_b*8, 0);
                    activate        (2, s7_row_r2);
                    nop             (2);
                end else if (s7_b == 31) begin
                    read            (1, s7_b*8, 1);
                    nop             (3);
                end else begin
                    read            (1, s7_b*8, 0);
                    nop             (3);
                end
            end

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 0) begin
                    read            (2, s7_b*8, 0);
                    activate        (3, s7_row_r3);
                    nop             (2);
                end else if (s7_b == 31) begin
                    read            (2, s7_b*8, 1);
                    nop             (3);
                end else begin
                    read            (2, s7_b*8, 0);
                    nop             (3);
                end
            end

            for (s7_b = 0; s7_b < 32; s7_b = s7_b + 1) begin
                if (s7_b == 0) begin
                    read            (3, s7_b*8, 0);

                    if (s7_i < S7_REPEAT - 1) begin
                        s7_row_r0 = s7_row_r0 + 4;
                        activate        (0, s7_row_r0);
                        nop             (2);
                    end else begin
                        nop             (3);
                    end
                end else if (s7_b == 31) begin
                    read            (3, s7_b*8, 1);
                    nop             (3);
                end else begin
                    read            (3, s7_b*8, 0);
                    nop             (3);
                end
            end

            if (s7_i < S7_REPEAT - 1) begin
                s7_row_r1 = s7_row_r1 + 4;
                s7_row_r2 = s7_row_r2 + 4;
                s7_row_r3 = s7_row_r3 + 4;
            end
        end

        s7_t_end = $time;

        s7_total_time_ns  = (s7_t_end - s7_t_start) / 1000.0;
        s7_total_bytes    = S7_REPEAT * 4.0 * 32.0 * bl * DQ_BITS / 8.0;
        s7_throughput_gbs = s7_total_bytes / s7_total_time_ns;
        s7_peak_gbs = (2.0 * DQ_BITS / 8.0) / (tck / 1000.0);
        s7_efficiency_percent = 100.0 * s7_throughput_gbs / s7_peak_gbs;

        $display("--------------------------------------------------");
        $display("SCENARIO 7 RESULT");
        $display("Start time          = %t", s7_t_start);
        $display("End time            = %t", s7_t_end);
        $display("Total time          = %0f ns", s7_total_time_ns);
        $display("Useful data         = %0f Bytes", s7_total_bytes);
        $display("Throughput          = %0f GB/s", s7_throughput_gbs);
        $display("Peak theoretical BW = %0f GB/s", s7_peak_gbs);
        $display("Efficiency          = %0f %%", s7_efficiency_percent);
        $display("--------------------------------------------------");

        test_done;
    end