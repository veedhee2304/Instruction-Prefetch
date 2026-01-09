
# 🚀 Pipeline Processor with Instruction Prefetch

![Language](https://img.shields.io/badge/Language-Verilog-blue.svg)
![Domain](https://img.shields.io/badge/Domain-Computer%20Architecture-orange.svg)
![Focus](https://img.shields.io/badge/Focus-CPU%20Front--End-green.svg)
![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-red.svg)
![Status](https://img.shields.io/badge/Status-Synthesizable-success.svg)

---

## 📌 Overview

This project implements a **5-stage pipelined CPU front-end** enhanced with an **instruction prefetch mechanism** to maximize instruction throughput and hide instruction memory latency.

The design is written in **synthesizable Verilog**, verified using **cycle-accurate simulation**, and synthesized in **Xilinx Vivado**.

The core idea is to **decouple instruction fetch from execution** using a **prefetch FIFO and FSM-based prefetch controller**, ensuring near-continuous instruction delivery (IPC ≈ 1).

---

## 🎯 Objectives

* Implement a **4–5 stage pipelined processor**
* Design **front-end instruction prefetch logic**
* Add a **prefetch buffer (FIFO)** with bandwidth management
* Handle **data hazards, load-use hazards, and control hazards**
* Maximize **instruction issue rate**
* Validate correctness via **simulation and synthesis**

---

## 🏗️ Architecture

### 🔹 Pipeline Stages

1. **IF** – Instruction Fetch from Prefetch FIFO
2. **ID** – Instruction Decode, Register Read, Hazard Detection
3. **EX** – ALU Operations, Address Calculation
4. **MEM** – Data Memory Access
5. **WB** – Write-Back to Register File

### 🔹 Prefetch Subsystem

* **Prefetch Engine (FSM-based)**

  * Issues fetch requests ahead of execution
  * Restarts fetch on branch redirection
* **Prefetch FIFO (Depth = 8)**

  * Buffers prefetched instructions
  * Supplies 1 instruction per cycle to IF stage
  * Prevents fetch stalls due to memory latency

---

## ⚙️ Key Features

* FSM-controlled **instruction prefetching**
* **FIFO buffering** to hide 3-cycle instruction memory latency
* **Load-use hazard detection** with 1-cycle stall insertion
* **EX/MEM and MEM/WB forwarding**
* **Branch handling with FIFO flush**
* Realistic **multi-cycle instruction memory model**
* Fully **synthesizable RTL**

---

## 🧪 Verification & Testing

### ✔ Testbenches

* Sequential instruction test (steady-state IPC)
* Load-use hazard test (stall validation)
* Branch test (FIFO flush & PC redirection)
* Loop-based test (sustained throughput)

### ✔ Debug Signals

* `dbg_pc` – Program Counter progression
* `dbg_if_insn` – IF-stage instruction stream
* `dbg_pf_occ` – Prefetch FIFO occupancy
* `dbg_reg1` – Register value for correctness

### ✔ Waveform Observations

* Prefetch FIFO fills rapidly and never starves
* PC increments almost every cycle (IPC ≈ 1)
* Correct 1-cycle stall on load-use hazards
* Proper branch flush and restart behavior

---

## 📊 Results

| Metric                        | Value               |
| ----------------------------- | ------------------- |
| Instruction Memory Latency    | 3 cycles            |
| Prefetch FIFO Depth           | 8                   |
| Steady-State IPC              | ~1                  |
| Fetch-Related Stall Reduction | >70%                |
| Synthesis                     | Successful (Vivado) |

---

## 🛠️ Tools & Technologies

* **Verilog HDL**
* **Xilinx Vivado**
* **Vivado Simulator / ModelSim**
* **RTL Design & Verification**
* **Computer Architecture**

---

## 📁 Repository Structure

```
├── pipeline_core.v          # Top-level pipelined CPU with prefetch
├── prefetch_engine.v        # FSM-based prefetch controller
├── prefetch_fifo.v          # Instruction FIFO
├── simple_imem.v            # Instruction memory model
├── data_mem.v               # Data memory model
├── tb_pipeline.v            # Main testbench
├── tb_load_use_test.v       # Load-use hazard testbench
├── README.md
```

---

## 🚀 How to Run

1. Open project in **Xilinx Vivado**
2. Add RTL files to **Design Sources**
3. Add testbenches to **Simulation Sources**
4. Run **Behavioral Simulation**
5. Inspect waveforms (PC, FIFO occupancy, instructions)
6. Run **Synthesis** to validate RTL quality

---

## 📌 Conclusion

This project demonstrates how **instruction prefetching significantly improves pipeline throughput** by hiding memory latency.
The design achieves **near-ideal IPC** while maintaining correctness through robust hazard detection and control logic.

---


Just tell me 😊
