# DDR2 Timing and Throughput Scheduling

Seven simulation scenarios explore how DDR2 timing constraints, burst length, row changes, and bank interleaving determine sustained throughput.

## Model assumptions

- DDR2 organization: **x4**
- Clock period: **`tCK = 3 ns`**
- Peak modeled bus throughput: **~333.333 MB/s**
- Initialization is excluded from the throughput window.
- Scenarios obey `tRCD`, `tRP`, `tWR`, `tRAS`, `tRTP`, and related timing constraints.

## Scenario results

| # | Scenario | Efficiency | Approx. throughput |
|---:|---|---:|---:|
| 1 | `WB0L1, RB0L1` | 21.0526% | ~70.175 MB/s |
| 2 | `WB0L2, RB0L2` | 38.09% | ~126.98 MB/s |
| 3 | `WB0L4, RB0L4` | 55.1724% | ~183.908 MB/s |
| 4 | `WB0L1, WB0L1, RB0L1, RB0L1` | 21.0526% | ~70.175 MB/s |
| 5 | `WB0L1, WB1L1, RB0L1, RB1L1` | 42.1052% | ~140.351 MB/s |
| 6 | four-bank long write stream | **100%** | **~333.333 MB/s** |
| 7 | four-bank long read stream | **100%** | **~333.333 MB/s** |

The sequence demonstrates burst amortization, bank-level parallelism, and steady-state command hiding. Scenario 4 is a useful negative result: more operations do not improve utilization when they remain serialized behind the same single-bank bottleneck.
