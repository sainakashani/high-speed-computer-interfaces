# Phase 2 — PCIe Data Link Layer and Fault Injection

## Protocol analysis

The phase-2 report studies DLLPs used for ACK/NAK, flow-control initialization and updates, and power-management signaling. At the Data Link layer, a TLP is protected by a **2-byte sequence number** and a **4-byte LCRC**; the coursework also discusses pipelined ACK/replay behavior.

## Fault-injection experiments

| Experiment | Perturbation | Observed result in the coursework model |
|---|---|---|
| Active-TLP pulse | Short bit-time-scale disturbance during traffic | End-to-end PIO test still passed in the recorded run; no explicit NAK/replay was observed |
| Training disturbance | Pulse applied during link training | Link recovered/continued and later functional checks passed |
| Idle/gap disturbance | Pulse inserted outside active packet traffic | Functional checks passed |
| Burst-noise sweep | Increasing contiguous error window, up to 100,000 bit-times | No LTSSM state change was captured in the observation window; functional test still completed |
| Constant differential hold | Natural transitions suppressed for increasing durations | Observed failure threshold lay between roughly **20 µs and 40 µs** in this simulation setup |

## Interpretation discipline

The report distinguishes injected fault, protocol evidence, and final functional behavior. For the short-pulse cases, a visible NAK/replay was not captured, so those runs are not presented as direct proof that a particular detector fired.
