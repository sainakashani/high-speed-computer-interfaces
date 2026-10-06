# Scenario 4 — Grouped Short Accesses in One Bank

Pattern: `WB0L1, WB0L1, RB0L1, RB0L1`.

- Minimum total loop: **76 cycles**
- Useful data-bus activity: **16 cycles**
- Efficiency: **21.0526%**
- Approx. throughput: **70.175 MB/s**

More short accesses do not improve utilization when they remain serialized behind the same single-bank row-cycle constraints.
