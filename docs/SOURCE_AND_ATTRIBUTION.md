# Source and Attribution Notes

This repository is intentionally curated to distinguish student coursework from third-party/vendor material.

## Included

- LTspice `.asc` schematics created for the signal-integrity assignments.
- Seven DDR2 `subtest.vh` scenario files containing the coursework scheduling/test logic.
- English technical documentation derived from the submitted reports and simulation results.

## Reviewed but not redistributed

- Student-authored Persian coursework report PDFs were reviewed to extract technical results, experiment structure, limitations, and measured values. They are omitted from the public repository to keep the portfolio lightweight and focused on browsable technical content.

## Intentionally excluded

### AMD/Xilinx PCIe example-design sources

The PCIe archives contain generated/example-design Verilog and simulation infrastructure from AMD/Xilinx, including files carrying explicit proprietary/confidential notices. The coursework modified and instrumented that environment, but this portfolio does not republish the vendor source tree.

The PCIe READMEs document the student changes and results: analyzer integration, x4 lane work, skew experiments, error injection, BAR tests, multi-function behavior, throughput instrumentation, and GPIO endpoint behavior.

### Course-provided PCIe analyzer / assignment material

The phase-0 archive includes assignment instructions and provided PHY-analysis utilities. They are reference/course material rather than student-authored deliverables and are not included here.

### Micron DDR2 model and datasheet

The DDR2 archive includes a Micron model/testbench, a Micron 2 Gb DDR2 SDRAM datasheet, and course handouts. Those files are not redistributed. Only the seven coursework scenario drivers and documentation are retained.

### Generated simulation output

Large transcripts, waveform databases, simulator work directories, duplicated generated sources, and multi-megabyte decoded PHY traces are excluded. Their conclusions are summarized in the READMEs.

## Reproduction note

To rerun PCIe or DDR2 simulations, obtain the appropriate vendor/course model or example-design package independently and apply/recreate the documented student experiment logic in that environment. LTspice experiments in `signal-integrity/` are self-contained.
