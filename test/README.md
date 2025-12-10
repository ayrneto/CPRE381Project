# Hardware-Scheduled Pipeline Test Suite

This directory contains comprehensive testbenches for validating the hardware-scheduled RISC-V pipeline implementation.

## Test Files Created

### Unit Tests (Individual Components)
- `tb_ForwardingUnit.vhd` - Tests data forwarding logic
- `tb_HazardDetectionUnit.vhd` - Tests load-use hazard detection  
- `tb_ForwardMuxA.vhd` - Tests ALU input A forwarding multiplexer
- `tb_ForwardMuxB.vhd` - Tests ALU input B forwarding multiplexer

### Integration Tests (Complete System)
- `tb_RISCV_Processor_HW.vhd` - Tests complete hardware-scheduled processor
- `tb_Pipeline_Comparison.vhd` - Compares software vs hardware scheduling performance

### Test Scripts
- `run_hw_pipeline_tests.do` - Runs basic hardware pipeline tests with waveforms
- `run_complete_test_suite.do` - Comprehensive test suite with detailed reporting

## Key Features Tested

### 1. Data Forwarding
- **EX/MEM to ALU forwarding** - Forwards ALU results from previous instruction
- **MEM/WB to ALU forwarding** - Forwards writeback data from two instructions ago
- **Store data forwarding** - Ensures store instructions get correct data
- **Forwarding priority** - EX/MEM has priority over MEM/WB when both match

### 2. Hazard Detection
- **Load-use hazards** - Detects when load result is needed immediately
- **Pipeline stalling** - Automatically stalls PC and IF/ID register
- **Control signal flushing** - Converts hazardous instruction to NOP
- **No x0 forwarding** - Correctly ignores writes to zero register

### 3. Performance Improvements
- **Eliminates manual NOPs** - No more software scheduling required
- **Better instruction throughput** - Fewer pipeline bubbles
- **Dynamic hazard resolution** - Hardware handles dependencies automatically

## How to Run Tests

### Option 1: Complete Test Suite (Recommended)
```bash
cd TopLevel/test
vsim -do run_complete_test_suite.do
```

This runs all tests with comprehensive reporting and creates waveform files.

### Option 2: Basic Hardware Pipeline Tests
```bash
cd TopLevel/test  
vsim -do run_hw_pipeline_tests.do
```

This runs the hardware pipeline tests with interactive waveforms.

### Option 3: Individual Tests
```bash
cd TopLevel/test
vsim work.tb_ForwardingUnit      # Test forwarding unit only
vsim work.tb_HazardDetectionUnit # Test hazard detection only
```

## Expected Results

### Unit Test Results
- **ForwardingUnit**: All 10 test cases should pass, validating correct forwarding logic
- **HazardDetectionUnit**: All 10 test cases should pass, validating stall/flush behavior  
- **ForwardMuxA/B**: All mux selection test cases should pass

### Integration Test Results
- **Hardware-Scheduled Processor**: Should execute test program without manual NOPs
- **Performance Comparison**: Hardware version should be significantly faster than software version

## Test Program Details

The integration tests use a carefully designed test program that includes:

1. **Data dependencies** - Instructions that depend on previous results
2. **Load-use hazards** - Load followed immediately by use of loaded data
3. **Store forwarding** - Store instructions using forwarded data
4. **Multiple forwarding scenarios** - Complex dependency chains

### Software-Scheduled Version (with NOPs)
```assembly
addi x1, x0, 1
addi x2, x0, 2  
nop; nop; nop        # Manual NOPs required
add x3, x2, x1
# ... more instructions with NOPs
```

### Hardware-Scheduled Version (no NOPs)
```assembly
addi x1, x0, 1
addi x2, x0, 2
add x3, x2, x1       # Hardware forwarding handles dependency
# ... automatic hazard resolution
```

## Debugging

If tests fail:

1. **Check waveforms** - Generated `.ps` files show signal timing
2. **Review assert messages** - Testbenches include detailed error reporting
3. **Verify component compilation** - Ensure all VHDL files compile without errors
4. **Check signal connections** - Verify processor instantiation matches component ports

## Performance Metrics

The comparison test measures:
- **Cycle count** - Total cycles to complete same program
- **Instruction throughput** - Instructions per cycle
- **Stall frequency** - How often pipeline stalls occur
- **Code density** - Instructions without NOPs vs with NOPs

Expected improvement: 20-40% better performance with hardware scheduling.