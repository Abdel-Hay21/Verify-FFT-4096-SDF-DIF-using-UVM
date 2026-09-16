# 🔬 4096-Point FFT — UVM Verification Environment

<p align=center>
  <img src=https://img.shields.io/badge/Language-SystemVerilog-blue?style=for-the-badge/>
  <img src=https://img.shields.io/badge/Methodology-UVM-orange?style=for-the-badge/>
  <img src=https://img.shields.io/badge/Simulator-QuestaSim-green?style=for-the-badge/>
  <img src=https://img.shields.io/badge/Points-4096-purple?style=for-the-badge/>
  <img src=https://img.shields.io/badge/Architecture-SDF%20Pipelined-red?style=for-the-badge/>
</p>

> A production-grade UVM verification environment for a **4096-point pipelined Decimation-In-Frequency (DIF) FFT** implemented using a **Single-path Delay Feedback (SDF)** architecture with fixed-point convergent rounding.

---

## 📋 Table of Contents

- [Design Overview](#-design-overview)
- [Architecture Deep Dive](#-architecture-deep-dive)
- [Verification Environment](#-verification-environment)
- [Test Scenarios](#-test-scenarios)
- [Known Bug — Inter-Frame Gap Small Break](#-known-bug--inter-frame-gap-small-break)
- [Coverage](#-coverage)
- [Assertions](#-formal-assertions)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run)

---

## 🧠 Design Overview

The DUT is a **4096-point FFT processor** built as a 12-stage pipelined SDF (Single-path Delay Feedback) engine. The design accepts a continuous stream of time-domain complex samples and produces frequency-domain complex output, either **scrambled** (natural pipeline order) or **ordered** (bit-reversed reordered).

| Parameter | Value |
|---|---|
| FFT Size | 4096 points |
| Number of Stages | 12 |
| Data Width | 12-bit (configurable) |
| Architecture | SDF Pipelined DIF |
| Output Modes | Scrambled / Ordered (bit-reversal RAM) |
| Arithmetic | Fixed-point with convergent rounding |
| Twiddle Factors | ROM-based (2048 entries) |

### I/O Interface

`
Inputs  : clk, rst_n, valid_in, in_r [11:0], in_i [11:0]
Outputs : valid_out, frame_done, out_r [11:0], out_i [11:0], out_index [11:0]
`

- **valid_in** — activates the pipeline; can be de-asserted between frames
- **valid_out** — asserted during the 4096 output samples of a frame
- **frame_done** — single-cycle pulse at the last output of every frame
- **out_index** — current output bin index (bit-reversed in scrambled mode)

---

## 🏗️ Architecture Deep Dive

### SDF Pipeline

Each of the 12 stages (fft_sdf_stg) implements a **Single-path Delay Feedback butterfly**. Data flows through them in series, with each stage operating on progressively smaller FIFO buffers:

`
Stage 1 -> FIFO=2048 -> Stage 2 -> FIFO=1024 -> ... -> Stage 12 -> FIFO=1
`

### Stage FSM — 4 States

Every stage is controlled by an independent **Moore FSM** (fft_stg_fsm) with four states:

| State | Action |
|---|---|
| IDLE_S | Wait for valid_in |
| FILL_S | Push N/2 input samples into the delay FIFO |
| BF_S | Enable butterfly — compute sum and difference simultaneously with FIFO read |
| DRAIN_S | Flush stored differences through the twiddle-factor rotator |

### Fixed-Point Precision Path

The fraction length is carefully tracked through all 12 stages (verified against MATLAB fft_types.m):

`
Input(Q1.11) -> Stg1(Q2.9) -> Stg2(Q4.8) -> Stg3(Q4.8) -> Stg4(Q5.7)
Stg5(Q6.6)  -> Stg6(Q6.6) -> Stg7(Q7.5) -> Stg8(Q7.5) -> Stg9(Q8.4)
Stg10(Q8.4) -> Stg11(Q9.3) -> Stg12(Q9.3)
`

**Convergent rounding** (round-half-to-even) is applied at every stage to prevent systematic bias accumulation.

---

## ✅ Verification Environment

The environment is built following the **full UVM methodology** with a clean, layered architecture:

`
+------------------------------------------------------------+
|                         FFT_test                           |
|  +------------------------------------------------------+  |
|  |                    FFT_environment                   |  |
|  |                                                      |  |
|  |  +-----------+   +------------+  +-------------+    |  |
|  |  | FFT_agent |   | Predictor  |  |  Scoreboard |    |  |
|  |  | +-------+ |   |            |  |             |    |  |
|  |  | | Driver| |   | Reference  |  |  DUT FIFO   |    |  |
|  |  | +-------+ |-->|   Model   |-->|  REF FIFO   |    |  |
|  |  | |Monitor| |   |            |  |   Compare   |    |  |
|  |  | +-------+ |   +------------+  +-------------+    |  |
|  |  +-----------+          |                            |  |
|  |        |                |         +-------------+    |  |
|  |        +----------------+-------->|  Coverage   |    |  |
|  |                                   +-------------+    |  |
|  +------------------------------------------------------+  |
+------------------------------------------------------------+
`

### Component Breakdown

#### Agent (verif/agent/)

| File | Role |
|---|---|
| FFT_seq_item.sv | Transaction item with all input/output fields, inline constraints, and post_randomize() file-driven input loading |
| FFT_driver.sv | Drives randomized transactions to DUT via virtual interface on every negedge |
| FFT_monitor.sv | Passively samples all DUT signals on every negedge and broadcasts via analysis port |
| FFT_sequencer.sv | Standard UVM sequencer connecting sequences to the driver |

#### Environment (verif/environment/)

| File | Role |
|---|---|
| FFT_predictor.sv | uvm_subscriber — receives every monitored transaction, forwards it to the reference model, and sends the expected result to the scoreboard |
| FFT_scoreboard.sv | Dual-FIFO comparator: gets actual (DUT) and expected (REF) items and flags mismatches with detailed error messages |
| FFT_coverage.sv | Functional coverage collector with coverpoints for all key signals and cross-coverage groups |
| FFT_environment.sv | Instantiates and wires all components together |
| FFT_virtual_sequencer.sv | Virtual sequencer holding a handle to the agent sequencer for coordinated multi-sequence control |

#### Reference Model (verif/reference_model/)

The FFT_reference_model is a **cycle-accurate golden model** that:
- Loads expected FFT output from output_data_scrambled.txt (pre-generated via MATLAB)
- Tracks raw_count and computes the expected out_index via 12-bit reversal
- Returns an expected FFT_sequence_item for every valid output cycle

#### Sequences (verif/sequences/)

| Sequence | Description |
|---|---|
| FFT_Reset_sequence | Applies active-low reset — drives rst_n=0, valid_in=0 |
| FFT_Continuous_Frames_sequence | Back-to-back frames — valid_in=1 for 8192 cycles |
| FFT_Small_Break_Between_Frames_sequence | 4096 valid then 3-cycle gap then valid again |
| FFT_Large_Break_Between_Frames_sequence | 4096 valid then 8192-cycle gap then 4096 valid then idle |

All sequences are orchestrated by a single **FFT_virtual_sequence** that runs them in order, giving full scenario coverage in one simulation run.

---

## 🧪 Test Scenarios

The virtual sequence exercises the DUT through the following ordered plan:

| # | Sequence | Duration | Purpose |
|---|---|---|---|
| 1 | Reset | 1 cycle | Initialize DUT to clean state |
| 2 | Continuous Frames | 8192 cycles | Verify back-to-back frames |
| 3 | Small Break | 8195 cycles | Frame, 3-cycle idle gap, frame |
| 4 | Large Break | 20480 cycles | Frame, 8192-cycle idle, frame |

---

## 🐛 Known Bug — Inter-Frame Gap (Small Break)

> **Discovered during verification with FFT_Small_Break_Between_Frames_sequence**

### Root Cause

The bug lives in **fft_stg_fsm.v** in the DRAIN_S next-state transition:

`erilog
// BUGGY CODE (current)
DRAIN_S: begin
    if (count_done) begin
        if (valid_in)
            next_state = BF_S;   // skips FILL_S !
        else
            next_state = IDLE_S;
    end
end
`

When a small inter-frame gap (fewer than N/2 cycles) ends **exactly at the same clock edge** that count_done fires in DRAIN_S, valid_in is already re-asserted. The FSM shortcuts directly to BF_S, completely skipping FILL_S.

### What Goes Wrong

The SDF architecture **requires** that every new frame starts by filling the delay FIFO with N/2 fresh samples before the butterfly can pair them with samples emerging from the other side. By bypassing FILL_S, the butterfly pairs:

- **New frame samples** (current input) with
- **Stale leftover values** still sitting in the FIFO from the previous frame

This produces **corrupted output data** for the second frame, while no assertion fires because valid_out still toggles at the right time — making the bug invisible without scoreboard comparison.

### Impact Summary

| Scenario | Behaviour |
|---|---|
| Continuous frames | CORRECT — DRAIN_S ends when valid_in is low |
| Large break | CORRECT — FSM reaches IDLE_S, then FILL_S on restart |
| **Small break (gap shorter than N/2)** | **CORRUPTED OUTPUT — FILL_S is skipped** |

### Fix Hint

`erilog
// CORRECT
if (valid_in)
    next_state = FILL_S;   // always refill FIFO before butterfly
`

---

## 📊 Coverage

The FFT_coverage component collects functional coverage across:

`systemverilog
covergroup cover_group;
  cp_rst_n        : coverpoint rst_n    { bins active, inactive }
  cp_valid_in     : coverpoint valid_in { bins inactive, active,
                                          trans 0->1, trans 1->0 }
  cp_valid_out    : coverpoint valid_out
  cp_frame_done   : coverpoint frame_done
  cp_out_index    : coverpoint out_index { bins zero, low[1:1023],
                                           mid[1024:3071], high[3072:4094],
                                           max, wrap_around }

  cross_valid_in_rst_n       : cross cp_valid_in,  cp_rst_n
  cross_valid_out_index      : cross cp_valid_out, cp_out_index
  cross_valid_out_frame_done : cross cp_valid_out, cp_frame_done
endgroup
`

Coverage results are saved to FFT_uvm.ucdb and reported to Code_Coverage_Report.txt.

---

## 🔒 Formal Assertions

Five SVA properties are bound to the DUT via FFT_bind.sv:

| Assertion | Checks |
|---|---|
| check_reset | All outputs zero one cycle after rst_n de-asserts |
| check_valid_latency | After 4096 consecutive valid_in cycles, valid_out fires for exactly 4096 cycles |
| check_frame_done | frame_done asserts on the cycle after the 4096th valid output |
| check_frame_done_pulse | frame_done is a single-cycle pulse (never held high for two cycles) |
| check_out_index_format | out_index matches raw_count (ordered) or bit-reversal of raw_count (scrambled) |

---

## 📁 Project Structure

`
FFT_uvm/
├── rtl/
│   ├── fft_4096_dif.v                Top-level 12-stage FFT
│   ├── fft_sdf_stg.v                 Generic SDF stage
│   ├── fft_stg_fsm.v                 Per-stage control FSM  <- Bug here
│   ├── fft_butterfly_unit.v          Butterfly adder/subtractor
│   ├── fft_fifo.v                    Shift-register delay FIFO
│   ├── fft_rotator.v                 Complex twiddle multiplier
│   ├── fft_twiddle_rom.v             2048-entry twiddle ROM
│   ├── fft_convergent_rounding.v     Fixed-point rounding
│   ├── fft_bit_reversal_complex.v    Bit-reversal reorder RAM
│   ├── fft_valid_out_gen.v           Output counter and frame_done
│   ├── fft_modulo_N_counter.v        Modulo-N counter primitive
│   ├── fft_dff.v                     Generic D flip-flop
│   └── fft_stg_mux.v                 2:1 mux primitive
│
├── verif/
│   ├── interface/
│   │   └── FFT_interface.sv
│   ├── agent/
│   │   ├── FFT_seq_item.sv
│   │   ├── FFT_driver.sv
│   │   ├── FFT_monitor.sv
│   │   ├── FFT_sequencer.sv
│   │   └── FFT_agent.sv
│   ├── reference_model/
│   │   └── FFT_reference_model.sv
│   ├── environment/
│   │   ├── FFT_predictor.sv
│   │   ├── FFT_scoreboard.sv
│   │   ├── FFT_coverage.sv
│   │   ├── FFT_environment.sv
│   │   └── FFT_virtual_sequencer.sv
│   ├── sequences/
│   │   ├── sequences/
│   │   │   ├── FFT_Reset_sequence.sv
│   │   │   ├── FFT_Continuous_Frames_sequence.sv
│   │   │   ├── FFT_Small_Break_Between_Frames_sequence.sv
│   │   │   └── FFT_Large_Break_Between_Frames_sequence.sv
│   │   └── virtual/
│   │       └── FFT_virtual_sequence.sv
│   ├── config/
│   │   └── FFT_config_obj.sv
│   ├── assertions/
│   │   ├── FFT_assertions.sv
│   │   └── FFT_bind.sv
│   ├── test/
│   │   └── FFT_test.sv
│   └── top/
│       └── FFT_top.sv
│
├── test/
│   ├── run.do
│   ├── wave.do
│   ├── input_data_scrambled.txt
│   ├── output_data_scrambled.txt
│   ├── FFT_uvm.ucdb
│   ├── FFT_CodeCoverage.ucdb
│   └── Code_Coverage_Report.txt
│
└── doc/
    └── FFT_uvm.pdf
`

---

## 🚀 How to Run

### Prerequisites

- QuestaSim / ModelSim with UVM 1.2 support
- MATLAB (optional, for regenerating reference data)

### Simulation

`	cl
# From the test/ directory
vsim -do run.do
`

The script automatically:
1. Creates and maps the work library
2. Compiles the interface, RTL, and all UVM components in dependency order
3. Elaborates with +acc and code-coverage instrumentation
4. Runs the full virtual sequence to completion
5. Saves FFT_uvm.ucdb and generates Code_Coverage_Report.txt

### Regenerating Reference Data (MATLAB)

The input_data_scrambled.txt and output_data_scrambled.txt files hold 12-bit binary values (one per line, real then imaginary interleaved) for 4096-point frames. They are generated with MATLAB fft() using the same fixed-point Q-notation parameters matched to the RTL.

---

## 👤 Author

Faculty project — RTL design and UVM verification environment built from scratch.
