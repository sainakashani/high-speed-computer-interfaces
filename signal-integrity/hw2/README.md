# HW2 — Termination, Discontinuities, and Stub Effects

This assignment moves from basic reflection theory to common high-speed interconnect design choices.

| File | Experiment | Sweep / configuration |
|---|---|---|
| `p12.asc` | Open-ended 50 Ω line | Source termination comparison |
| `p13.asc` | Edge-time vs. propagation delay | Fast 0.5 ns edge |
| `p18.asc` | Impedance discontinuity | `Zmid = 25, 50, 75 Ω` |
| `p19.asc` | Electrical length of a low-impedance section | Middle-section delay sweep |
| `p20.asc` | Shorted stub | Stub-delay sweep |

## Interpretation

- Matching source impedance to the line suppresses repeated source-side reflection.
- A short impedance discontinuity can be electrically negligible, while the same impedance error becomes increasingly visible as its delay grows relative to edge time.
- A stub behaves as a reflection path; increasing stub electrical length increases the reflected disturbance and ringing.
