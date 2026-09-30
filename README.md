# Traffic-Light FSM Controller

A synchronous Moore finite-state-machine based traffic-light controller designed and verified using SystemVerilog.

## Overview

This project implements a synchronous traffic-light controller for two intersecting roads.

The controller uses a four-state Moore FSM. A counter is used alongside the state register to control how long the controller remains in each traffic-light state.

## State Machine

The controller contains four states:

| State | Road A | Road B | Duration |
|-------|--------|--------|----------|
| S0    | Green  | Red    | 5 cycles |
| S1    | Yellow | Red    | 2 cycles |
| S2    | Red    | Green  | 5 cycles |
| S3    | Red    | Yellow | 2 cycles |

The normal state sequence is:

    S0 -> S1 -> S2 -> S3 -> S0

This corresponds to:

    Road A Green
         |
         v
    Road A Yellow
         |
         v
    Road B Green
         |
         v
    Road B Yellow
         |
         v
    Road A Green

## Architecture

The controller consists of:

- State register
- Counter register
- Next-state logic
- Next-counter logic
- Moore output logic
- Synchronous active-low reset

The state register determines the current traffic-light phase, while the counter determines how long that state has been active.

## State Timing

Each state remains active for a fixed number of clock cycles.

    S0 -> 5 cycles
    S1 -> 2 cycles
    S2 -> 5 cycles
    S3 -> 2 cycles

When the required duration is reached:

1. The controller transitions to the next state.
2. The counter is reset to zero.
3. The new state begins its timing cycle.

For example, the S0 sequence is:

    Clock Edge    State    Counter
    --------------------------------
         1          S0        0
         2          S0        1
         3          S0        2
         4          S0        3
         5          S0        4
         6          S1        0

Thus, S0 remains active for exactly five clock cycles.

## Reset

The controller uses a synchronous active-low reset.

When `reset = 0` at a rising clock edge:

    State   -> S0
    Counter -> 0

The controller therefore starts with:

    Road A -> Green
    Road B -> Red

## Moore Output Logic

The traffic-light outputs depend only on the current FSM state.

    S0 -> Road A Green,  Road B Red
    S1 -> Road A Yellow, Road B Red
    S2 -> Road A Red,    Road B Green
    S3 -> Road A Red,    Road B Yellow

The controller does not directly depend on external inputs for its normal state transitions; the counter determines when each timed transition occurs.

## Verification

The controller was verified using a SystemVerilog testbench.

The verification checks:

- Reset behavior
- Initial state
- Traffic-light output combinations
- State sequencing
- Counter-based state transitions
- State duration
- Complete S0 -> S1 -> S2 -> S3 -> S0 cycle

The testbench uses clock-edge based checking with a small simulation delay after each rising edge to allow sequential state updates to settle.

Waveforms were also inspected to verify the relationship between:

- Clock
- Reset
- State
- Counter
- Traffic-light outputs

## Files

design.sv
testbench.sv
README.md

### design.sv

Contains the complete SystemVerilog implementation of the traffic-light controller.

### testbench.sv

Contains the functional verification environment, clock generation, reset sequence, output checks, and final pass/fail report.

## Tools

- SystemVerilog
- Icarus Verilog
- EDA Playground
- EPWave

## Learning Focus

This project was developed to strengthen understanding of:

- Moore finite-state machines
- Synchronous sequential design
- State registers
- Counter-based timing
- Next-state logic
- Moore output logic
- Synchronous reset
- SystemVerilog RTL design
- Testbench development
- Waveform-based verification
