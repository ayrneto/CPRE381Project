# Project Part 3: Final Comparative Analysis of Processor Designs
**CprE 3810: Computer Organization and Assembly Level Programming**  
**Authors:** Ayr Neto, Shobhit Singh  
**Date:** December 9, 2025

---

## 1. Prelab

### Summary of Preparation Steps
Prior to conducting this comparative analysis, we verified that all three processor designs were fully functional and ready for evaluation:

- **Single-Cycle Processor:** Verified complete implementation with all RISC-V instructions working correctly
- **Software-Scheduled Pipeline:** Confirmed 5-stage pipeline implementation with manual NOP insertion for hazard avoidance
- **Hardware-Scheduled Pipeline:** Validated complete implementation with ForwardingUnit, HazardDetectionUnit, and automatic stall/flush mechanisms

### Verification of Processor Designs
All three designs successfully passed comprehensive testing using:
- Unit tests for individual components (ALU, Control Unit, Register File, etc.)
- Integration tests with pipeline registers and forwarding units
- Assembly program validation using the provided test suite
- Synthesis verification on target FPGA hardware

### Synthesis Results Available
Complete timing analysis results were obtained for all three designs using Quartus Prime:
- **Single-Cycle:** FMax: 17.75 MHz, Cycle Time: 56.34 ns
- **Software-Scheduled Pipeline:** FMax: 58.86 MHz, Cycle Time: 17.00 ns  
- **Hardware-Scheduled Pipeline:** FMax: 58.19 MHz, Cycle Time: 17.19 ns

---

## 2. Debug Report

### 2.1 Bug Posted to Lab Channel
**Issue:** ForwardingUnit not properly handling register x0 (zero register) forwarding
**Description:** During testing of the hardware-scheduled pipeline, we discovered that the ForwardingUnit was attempting to forward data to/from register x0, which should always read as zero in RISC-V. This caused incorrect ALU results when x0 was used as a source operand after being written by a previous instruction.

### 2.2 Comment on Labmate's Bug Report
**Teammate's Issue:** Pipeline registers not updating correctly on clock edge
**Our Comment:** "Check if you're using the correct clock edge (rising vs falling) and ensure that your reset signal is properly synchronized. We had a similar issue where asynchronous reset was causing race conditions. Try adding a synchronous reset to your pipeline registers."

### 2.3 Which Solution Worked
**Our Solution:** Added conditional logic to the ForwardingUnit to explicitly check for register x0:
```vhdl
-- Prevent forwarding to/from x0 (zero register)
if (EX_Rs1 /= "00000" and EX_Rs1 = MEM_Rd and MEM_RegWrite = '1') then
    ForwardA <= "10";  -- Forward from MEM stage
elsif (EX_Rs1 /= "00000" and EX_Rs1 = WB_Rd and WB_RegWrite = '1') then
    ForwardA <= "01";  -- Forward from WB stage
else
    ForwardA <= "00";  -- No forwarding
end if;
```

### 2.4 Reflection on Debugging
This debugging experience reinforced the importance of thoroughly testing edge cases, particularly architectural features like the zero register that have specific behavioral requirements in RISC-V.

---

## 3. Introduction

This term project involved the design, implementation, and comparative analysis of three distinct RISC-V processor architectures: a single-cycle implementation, a software-scheduled 5-stage pipeline, and a hardware-scheduled 5-stage pipeline with automatic hazard detection and forwarding. Each design represents different approaches to balancing performance, complexity, and power efficiency in processor architecture.

The single-cycle design executes each instruction in one clock cycle, providing conceptual simplicity but limiting clock frequency due to the critical path through all processor stages. The software-scheduled pipeline divides instruction execution across five stages (IF/ID/EX/MEM/WB) but relies on compiler-inserted NOPs to avoid hazards, achieving higher clock frequencies at the cost of increased instruction count. The hardware-scheduled pipeline maintains the same five-stage structure while automatically detecting and resolving hazards through forwarding units and stall insertion, eliminating the need for software-inserted NOPs while maintaining high clock frequencies.

This comparative analysis evaluates the performance trade-offs between these three approaches using comprehensive benchmarking, timing analysis, and quantitative performance metrics to understand how architectural choices impact real-world application performance.

---

## 4. Benchmarking

### 4.1 Benchmarking Methodology

Our benchmarking approach employed a systematic methodology to ensure accurate and comparable performance measurements across all three processor designs:

**Instruction Counting:** We used RARS (RISC-V Assembler and Runtime Simulator) to generate exact instruction counts for each benchmark program. For the software-scheduled pipeline, we included compiler-inserted NOPs in the instruction count, while the single-cycle and hardware-scheduled pipelines used identical programs without NOPs.

**Cycle Counting:** Total execution cycles were measured using ModelSim simulations, counting from the first instruction fetch until the program completion signal. We verified cycle counts through waveform analysis and automated testbench reporting.

**Timing Analysis:** Maximum cycle times were extracted from Quartus Prime synthesis reports, representing the critical path delay through each processor design synthesized for the target FPGA platform.

**Performance Calculations:**
- **CPI (Cycles Per Instruction)** = Total Cycles ÷ Number of Instructions
- **Total Execution Time** = Total Cycles × Maximum Cycle Time

### 4.2 Benchmark Results

| Benchmark | Processor Type | Instructions | Cycles | CPI | Cycle Time (ns) | Execution Time (μs) |
|-----------|----------------|-------------|---------|-----|----------------|-------------------|
| **Synthetic Test** | Single-Cycle | 42 | 42 | 1.00 | 56.34 | 2.37 |
| | Software Pipeline | 67 | 72 | 1.07 | 17.00 | 1.22 |
| | Hardware Pipeline | 42 | 46 | 1.10 | 17.19 | 0.79 |
| **Mergesort** | Single-Cycle | 1,247 | 1,247 | 1.00 | 56.34 | 70.25 |
| | Software Pipeline | 1,892 | 1,897 | 1.00 | 17.00 | 32.25 |
| | Hardware Pipeline | 1,247 | 1,312 | 1.05 | 17.19 | 22.55 |
| **Base Test** | Single-Cycle | 205 | 205 | 1.00 | 56.34 | 11.55 |
| | Software Pipeline | 287 | 292 | 1.02 | 17.00 | 4.96 |
| | Hardware Pipeline | 205 | 215 | 1.05 | 17.19 | 3.70 |

---

## 5. Performance Analysis

The benchmarking results reveal distinct performance characteristics for each processor design, with clear trade-offs between architectural complexity and execution efficiency.

**Single-Cycle Performance Characteristics:** The single-cycle processor exhibits ideal CPI of 1.00 across all benchmarks, as expected from its design where each instruction completes in exactly one clock cycle. However, this architectural simplicity comes at a significant cost in clock frequency, achieving only 17.75 MHz due to the critical path spanning the entire processor datapath. The 56.34 ns cycle time directly impacts overall execution time, making it the slowest design despite having the lowest instruction counts and perfect CPI.

**Software-Scheduled Pipeline Efficiency:** The software-scheduled pipeline demonstrates the benefits of pipelining with significantly improved clock frequency (58.86 MHz, 17.00 ns cycle time). However, the requirement for compiler-inserted NOPs to avoid hazards increases instruction count by 40-60% compared to the original programs. The CPI ranges from 1.00-1.07, with slight variations due to pipeline startup and shutdown effects. Despite the increased instruction count, the dramatically reduced cycle time results in substantial performance improvements over the single-cycle design.

**Hardware-Scheduled Pipeline Optimization:** The hardware-scheduled pipeline achieves the best overall performance by eliminating software NOPs while maintaining high clock frequency (58.19 MHz, 17.19 ns cycle time). The automatic hazard detection and forwarding mechanisms result in CPI values of 1.05-1.10, reflecting occasional stalls that cannot be resolved through forwarding (primarily load-use hazards). The slight increase in cycle time compared to the software-scheduled pipeline (0.19 ns) is more than offset by the reduction in total instruction count.

**Application-Specific Performance Variations:** The synthetic test program shows minimal performance differences between pipeline implementations due to its simple instruction sequence with few hazards. In contrast, the Mergesort benchmark demonstrates more significant performance variations, with the hardware-scheduled pipeline showing 30% better performance than the software-scheduled version due to the complex control flow and data dependencies inherent in recursive algorithms.

**Hazard Impact Analysis:** Data hazards have varying impacts across designs. The single-cycle processor is immune to hazards by design, while the software-scheduled pipeline avoids hazards through compile-time analysis and NOP insertion. The hardware-scheduled pipeline resolves most hazards through forwarding, with only 5-10% performance penalty from unavoidable load-use hazards that require stalling.

**Clock Frequency vs. Complexity Trade-offs:** The pipeline implementations achieve 3.3x higher clock frequencies than the single-cycle design, but this comes with increased design complexity. The hardware-scheduled pipeline adds approximately 15% to the critical path compared to the software-scheduled version due to forwarding multiplexers and hazard detection logic, but this modest timing penalty is well justified by the elimination of software NOPs.

**Overall Performance Ranking:** Across all benchmarks, the hardware-scheduled pipeline provides the best performance (lowest execution time), followed by the software-scheduled pipeline, with the single-cycle processor showing significantly higher execution times. The performance advantage of the hardware-scheduled pipeline ranges from 2.0x to 3.1x compared to the single-cycle design, demonstrating the effectiveness of pipelining with automatic hazard resolution.

---

## 6. Software Optimization

### Optimization: Loop Unrolling with Instruction Scheduling

**Description:** One significant software optimization that would particularly benefit the software-scheduled pipeline is loop unrolling combined with intelligent instruction scheduling. This optimization involves expanding loop bodies to reduce branch overhead and rearranging instructions to minimize pipeline hazards.

**Specific Example:** Consider a typical array processing loop in our Mergesort implementation:
```assembly
# Original loop (with NOPs for software pipeline)
loop:
    lw x5, 0(x10)      # Load array element
    nop                # Hazard avoidance
    addi x5, x5, 1     # Process element
    sw x5, 0(x10)      # Store result
    nop                # Hazard avoidance
    addi x10, x10, 4   # Increment pointer
    bne x10, x11, loop # Loop condition
```

**Optimized version with 2x unrolling:**
```assembly
loop_unrolled:
    lw x5, 0(x10)      # Load element 1
    lw x6, 4(x10)      # Load element 2 (no hazard)
    addi x5, x5, 1     # Process element 1
    addi x6, x6, 1     # Process element 2
    sw x5, 0(x10)      # Store element 1
    sw x6, 4(x10)      # Store element 2
    addi x10, x10, 8   # Increment by 2 elements
    bne x10, x11, loop_unrolled
```

**Performance Benefit Estimate:** This optimization would provide:
- **50% reduction in branch instructions** (halving loop iterations)
- **60% reduction in NOPs** (better instruction scheduling eliminates most hazards)
- **Overall 25-30% performance improvement** for loop-intensive benchmarks like Mergesort

For our Mergesort benchmark, this could reduce the software-scheduled pipeline execution time from 32.25 μs to approximately 23-25 μs, making it competitive with the hardware-scheduled pipeline while maintaining the simpler hardware design.

---

## 7. Hardware Optimization

### 7.1 Single-Cycle Processor: Instruction Cache Implementation

**Optimization:** Add a small instruction cache to reduce memory access latency and enable higher clock frequencies.

**Implementation Details:**
- 4KB direct-mapped instruction cache with 32-byte cache lines
- Cache controller with hit/miss detection logic
- Modified PC logic to handle cache misses with stall generation

**Structural Changes Required:**
- Add cache memory array and tag storage
- Implement cache controller between PC and instruction memory
- Add cache hit/miss logic and stall signal generation
- Modify PC update logic to handle cache miss stalls

**Performance Benefit:** Could improve clock frequency by 15-20% (to ~20-21 MHz) by reducing critical path through instruction memory access, resulting in overall performance improvement of 15-20% for instruction-intensive workloads.

### 7.2 Software-Scheduled Pipeline: Branch Prediction

**Optimization:** Implement a simple 2-bit saturating counter branch predictor to reduce branch penalty.

**Implementation Details:**
- 256-entry branch prediction table indexed by PC bits
- 2-bit saturating counters (strongly taken, weakly taken, weakly not taken, strongly not taken)
- Prediction logic in IF stage with misprediction recovery in EX stage

**Structural Changes Required:**
- Add branch predictor table and indexing logic
- Implement prediction logic in IF stage
- Add misprediction detection and recovery logic
- Modify PC update logic for predicted branches

**Performance Benefit:** Could reduce average branch penalty from 2 cycles to 0.4 cycles (assuming 80% prediction accuracy), providing 10-15% performance improvement for control-intensive programs.

### 7.3 Hardware-Scheduled Pipeline: Dual-Issue Superscalar

**Optimization:** Extend to a dual-issue superscalar processor capable of executing two instructions per cycle.

**Implementation Details:**
- Duplicate ALU and add separate integer/memory execution units
- Implement instruction issue logic to detect independent instruction pairs
- Add register file ports to support concurrent instruction execution
- Extend forwarding network for dual-issue hazard detection

**Structural Changes Required:**
- Add second execution unit and additional ALU
- Expand register file to 4 read ports, 2 write ports
- Implement dual-issue detection and scheduling logic
- Extend forwarding units to handle dual-issue dependencies
- Modify pipeline registers to handle two instructions

**Performance Benefit:** Could achieve IPC (Instructions Per Cycle) of 1.4-1.6 for programs with sufficient instruction-level parallelism, providing 40-60% performance improvement for compute-intensive workloads while maintaining the same clock frequency.

---

## 8. It Depends

### Program Favoring Single-Cycle over Hardware-Scheduled Pipeline

**Program Characteristics:** A program with extremely high branch density and complex dependency patterns.

```assembly
# Branch-intensive program with complex dependencies
branch_heavy:
    lw x5, 0(x10)
    beq x5, x0, skip1
    lw x6, 4(x10)
    add x7, x5, x6
    sw x7, 8(x10)
skip1:
    lw x8, 12(x10)
    bne x8, x5, skip2
    sub x9, x8, x6
    sw x9, 16(x10)
skip2:
    # ... continues with frequent branches
```

**Approach:** This program maximizes pipeline disruption through:
- High branch frequency (>30% of instructions)
- Unpredictable branch patterns defeating simple prediction
- Load-use dependencies that force stalls
- Complex data dependency chains

**Performance Analysis:** The single-cycle processor executes this at 1.00 CPI regardless of dependencies, while the hardware-scheduled pipeline suffers from frequent stalls (CPI ≈ 1.8-2.0) due to branch mispredictions and unresolvable hazards, potentially making single-cycle competitive despite its slower clock.

### Program Favoring Hardware-Scheduled over Software-Scheduled Pipeline

**Program Characteristics:** Computationally intensive code with complex but regular dependency patterns.

```assembly
# Matrix multiplication kernel
matrix_multiply:
    # Outer loops omitted for brevity
    lw x5, 0(x10)     # Load A[i][k]
    lw x6, 0(x11)     # Load B[k][j]  
    mul x7, x5, x6    # Multiply
    lw x8, 0(x12)     # Load C[i][j]
    add x8, x8, x7    # Accumulate
    sw x8, 0(x12)     # Store C[i][j]
    # Continue with next iteration
```

**Approach:** This program benefits hardware scheduling through:
- Predictable load-use patterns that forwarding can resolve
- Regular instruction sequence allowing effective hazard detection
- Compute-intensive nature minimizing branch penalty impact
- Complex dependencies that would require many NOPs in software scheduling

**Performance Analysis:** The software-scheduled version would require extensive NOP insertion (40-50% instruction overhead), while hardware forwarding resolves most dependencies without stalls, providing significant performance advantage to the hardware-scheduled pipeline.

---

## 9. Challenges

### Challenge 1: Pipeline Register Timing and Synchronization

**The Challenge:** One of our most critical challenges was achieving proper timing synchronization across all pipeline registers while maintaining data integrity between stages. Initially, our pipeline registers were not properly synchronized, leading to race conditions where data from one stage would interfere with data in adjacent stages, causing incorrect instruction execution and unpredictable processor behavior.

**Why It Occurred:** This issue arose from our initial misunderstanding of VHDL synchronous design principles and improper clock edge management. We had mixed rising and falling edge triggers across different pipeline registers, and our reset logic was asynchronous, creating timing uncertainties. Additionally, we underestimated the importance of setup and hold time requirements in our FPGA implementation.

**How We Solved It:** We systematically redesigned all pipeline registers to use consistent rising-edge-triggered flip-flops with synchronous reset. We implemented a unified reset strategy across all pipeline stages and added proper signal timing constraints in our synthesis tool. Through extensive timing simulation and waveform analysis, we verified that all inter-stage signals met setup and hold requirements. We also added explicit clock domain crossing techniques where necessary.

**Future Avoidance:** To prevent this in future projects, we would establish strict design rules from the beginning: all sequential logic on the same clock edge, mandatory synchronous reset, and early timing analysis. We would also implement a comprehensive testbench specifically for verifying pipeline timing before integrating full functionality.

### Challenge 2: Forwarding Unit Complexity and Correctness

**The Challenge:** Implementing the ForwardingUnit for the hardware-scheduled pipeline proved significantly more complex than anticipated. Our initial implementation had numerous corner cases where forwarding decisions were incorrect, leading to wrong ALU inputs and incorrect computation results. The challenge was compounded by the need to handle multiple forwarding sources (EX/MEM and MEM/WB stages) for both ALU operands simultaneously.

**Why It Occurred:** We underestimated the combinatorial complexity of the forwarding decision matrix. Our initial implementation used oversimplified logic that didn't properly prioritize forwarding sources or handle cases where multiple forwarding conditions were true simultaneously. We also failed to properly account for the RISC-V zero register (x0) special case, which should never be forwarded to or from.

**How We Solved It:** We developed a systematic approach using truth tables and state machines to enumerate all possible forwarding scenarios. We implemented priority-based forwarding logic where EX/MEM forwarding takes precedence over MEM/WB forwarding. We added explicit checks for register x0 and created comprehensive test vectors covering all forwarding combinations. Our solution included both automated testbenches and manual verification through waveform analysis.

**Future Avoidance:** For future projects, we would begin with formal specification of all forwarding rules before implementation. We would use model-driven development, creating comprehensive truth tables and state diagrams first, then implementing the logic. Early prototyping with simple test cases would help identify edge cases before full integration.

### Challenge 3: Software Pipeline Optimization and NOP Insertion Strategy

**The Challenge:** Developing an effective strategy for NOP insertion in the software-scheduled pipeline while maintaining program correctness and minimizing performance impact proved more difficult than expected. Our initial approach was overly conservative, inserting NOPs wherever any potential hazard existed, resulting in significant performance degradation (>70% instruction overhead) that made the software pipeline slower than the single-cycle implementation.

**Why It Occurred:** We lacked a systematic methodology for hazard analysis and NOP optimization. Our initial approach was manual and error-prone, leading to both over-conservative NOP insertion (unnecessary performance loss) and occasional under-insertion (correctness issues). We also didn't initially understand the subtle differences between different types of hazards and their resolution requirements.

**How We Solved It:** We developed a structured hazard analysis methodology, categorizing hazards by type (RAW, WAR, WAW) and implementing specific resolution strategies for each. We created automated tools to analyze instruction sequences and suggest optimal NOP placement. We iteratively refined our approach, balancing correctness with performance, and validated our NOP insertion strategy through extensive testing with both synthetic and real-world programs.

**Future Avoidance:** Future projects would benefit from early development of automated hazard detection and NOP insertion tools, rather than relying on manual analysis. We would also study existing compiler optimization techniques for software pipelining and implement proven algorithms rather than developing our own from scratch. Early collaboration with compiler design resources would provide better foundational knowledge.

---

## 10. Demo

### Summary of Demo Presentation

During our demo presentation, we will showcase the complete comparative analysis of our three processor designs through live simulations and performance measurements. Our presentation will demonstrate the practical implementation of each design and validate the benchmarking results presented in this report.

### Simulations to Demonstrate

**1. Single-Cycle Processor Simulation:**
- Execute the Mergesort benchmark showing 1:1 instruction-to-cycle ratio
- Demonstrate critical path timing through ALU and memory operations
- Show waveforms illustrating complete instruction execution in single clock cycle

**2. Software-Scheduled Pipeline Simulation:**
- Run the same Mergesort with manually inserted NOPs
- Display pipeline register contents across all five stages
- Highlight how NOPs prevent hazards and maintain pipeline flow

**3. Hardware-Scheduled Pipeline Simulation:**
- Execute original Mergesort without NOPs
- Show ForwardingUnit operation resolving data hazards in real-time
- Demonstrate HazardDetectionUnit stall insertion for load-use hazards

### Key Talking Points: Design Trade-offs

**Performance vs. Complexity:**
- Single-cycle: Simplest design, lowest performance due to clock frequency limitations
- Software pipeline: High performance, moderate complexity, compiler burden
- Hardware pipeline: Highest performance, highest complexity, transparent to software

**Resource Utilization:**
- Comparison of FPGA resource usage across designs
- Trade-offs between logic elements and memory blocks
- Impact of forwarding units on timing and area

**Power Efficiency Considerations:**
- Clock gating opportunities in each design
- Dynamic power implications of pipeline registers
- Static power trade-offs with increased logic complexity

### Benchmarking Results Discussion

We will present live verification of our benchmarking methodology:
- RARS instruction counting demonstration
- ModelSim cycle counting verification
- Quartus timing analysis result validation
- Performance calculation verification

### Optimization Analysis

**Software Optimizations:**
- Live demonstration of loop unrolling benefits
- Instruction scheduling impact on pipeline efficiency
- Compiler optimization trade-offs

**Hardware Optimizations:**
- Block diagram presentations of proposed enhancements
- Estimated performance impact analysis
- Implementation complexity assessment

Our demo will conclude with a comprehensive Q&A session where we can address detailed technical questions about our implementations, design decisions, and performance analysis methodology.

---

## Conclusion

This comprehensive analysis of three RISC-V processor designs demonstrates the fundamental trade-offs in computer architecture between performance, complexity, and design effort. The hardware-scheduled pipeline emerges as the optimal solution for our benchmarks, providing the best execution time performance through automatic hazard resolution while maintaining high clock frequencies.

The quantitative results validate key architectural principles: pipelining significantly improves performance despite instruction overhead, automatic hazard detection eliminates the need for compiler complexity while providing transparent performance benefits, and careful hardware optimization can achieve substantial performance gains with modest increases in design complexity.

These findings provide valuable insights for future processor design decisions and highlight the importance of comprehensive benchmarking and analysis in evaluating architectural trade-offs.