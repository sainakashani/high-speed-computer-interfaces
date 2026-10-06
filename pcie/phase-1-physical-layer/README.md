# Phase 1 — PCIe Physical Layer

## Baseline link

The starting point was a **PCIe Gen1 x1** Root Port ↔ Endpoint simulation. The analysis path observed the serial stream and reconstructed symbols through:

1. serial-to-parallel conversion,
2. comma alignment,
3. 8b/10b decoding,
4. descrambling after link training.

Descrambling was enabled only after the LTSSM passed the early training states (`cfg_ltssm_state > 6'h09` in the coursework setup). The report identifies common control symbols including K28.5 (comma), K23.7 (PAD), K28.0 (SKP), K28.2 (SDP), K27.7 (STP), and K29.7 (END).

## Training and link bring-up

TS1/TS2 ordered sets and LTSSM progression were inspected until the link reached the operational state. The simulated link negotiated **Gen1 at 2.5 GT/s, x1**.

## x4 extension and byte striping

A separate x4 configuration was generated and each lane was analyzed independently in both directions. The decoded output showed **byte striping** rather than packet duplication: symbols from a packet were distributed across lanes.

The report records a larger transfer containing **261 four-lane stripes = 1044 decoded symbols**, consistent with a large 256-DW transaction plus protocol overhead.

## Lane-skew experiment

The Root Port → Endpoint path was simulated with added lane delays of **0, 0.1, 0.2, and 0.3 ns**. Within this tested simulation model, the link still trained and the PIO functional test completed. This is a simulation result for the tested setup, not a general PCIe compliance limit.

## Concepts also analyzed

- Polarity inversion and receiver compensation.
- Lane reversal and logical lane remapping.
- SKP ordered sets and clock-compensation context.
