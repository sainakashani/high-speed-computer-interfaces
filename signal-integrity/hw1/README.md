# HW1 — Transmission-Line Reflections

This assignment focuses on time-domain reflections and how source/load mismatch changes the observed voltage as waves travel back and forth along an interconnect.

| File | Setup | Main observation |
|---|---|---|
| `Q4.asc` | 3.3 V pulse, `Rs=5 Ω`, `Z0=50 Ω`, `Td=1 ns`, open load | Strong positive load reflection |
| `Q5.asc` | 3 V pulse, `Rs=20 Ω`, two `Z0=60 Ω`, `Td=0.5 ns` sections, `RL=180 Ω` | Forward/reflected steps and negative source reflection |
| `Q6.asc` | Same 60 Ω / 180 Ω network with a faster rising edge | Stronger visibility of transmission-line effects as edge time decreases |
| `Q6_p9.asc` | 5 V source, `Rs=40 Ω`, `Z0=150 Ω`, `Td=1 ns`, switched 10 Ω pull-down | Large negative reflection and pronounced ringing |

Open each schematic in LTspice and run its embedded transient analysis.
