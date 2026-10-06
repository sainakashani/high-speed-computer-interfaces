# Phase 3 — PCIe Transaction Layer

This phase exercises PCIe configuration, memory transactions, BAR behavior, multi-function support, throughput, and a GPIO-style endpoint.

## Key experiments

### Memory Write / Read
A dedicated transaction writes and reads back coursework-specific data through the PIO path; reported readback succeeded.

### Throughput benchmark
Ten sequential write/read iterations transferred **80 useful bytes = 640 useful bits** over **20.0789 µs**, giving approximately **31.874 Mb/s**. This is a testbench-specific useful-throughput result, not the PCIe Gen1 line rate.

### 256 KB BAR0
BAR0 was configured as a 32-bit memory BAR with **256 KB** range. Successful readback was reported at offsets `0x00000000`, `0x00020000`, and `0x0003FFFC`.

### Multi-function endpoint
Configuration checks were exercised for PF0 and PF1. The report records combined Device/Vendor IDs:
- PF0: `0x9011_10EE`
- PF1: `0x9211_10EE`

### Memory-mapped GPIO
The endpoint memory behavior was replaced by a GPIO-style map:

| Offset | Register | Role |
|---:|---|---|
| `0x00` | `GPIO_OUT` | output value |
| `0x04` | `GPIO_DIR` | direction control |
| `0x08` | `GPIO_IN` | loopback / simulated input |
| `0x0C` | `GPIO_STATUS` | status flags |

Output, direction, and loopback checks passed in the reported run. The **GPIO_STATUS check did not fully pass**: observed `0x00000005` differed from the expected status condition. The discrepancy is kept visible intentionally.
