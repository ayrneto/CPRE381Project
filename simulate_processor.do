## RISC-V Processor Simulation Script for QuestaSim/ModelSim
## Place this in your project directory and run in ModelSim

# Create and map work library
vlib work
vmap work work

# Compile all VHDL design files
echo "Compiling VHDL Design Files..."

vcom -2008 AddSub_32b.vhd
vcom -2008 LogicUnit.vhd  
vcom -2008 BarrelShifter.vhd
vcom -2008 ALU.vhd
vcom -2008 Extender.vhd
vcom -2008 ControlUnit.vhd
vcom -2008 mux2to1_32b.vhd
vcom -2008 PC.vhd
vcom -2008 RISCV_Processor.vhd

# Compile testbench
vcom -2008 tb_RISCV_Processor.vhd

# Start simulation
echo "Starting Processor Simulation..."
vsim -voptargs=+acc work.tb_RISCV_Processor

# Add waves to view signals
add wave -divider "Clock and Reset"
add wave -radix binary /tb_RISCV_Processor/s_CLK
add wave -radix binary /tb_RISCV_Processor/s_RST

add wave -divider "Instruction Memory Interface"  
add wave -radix binary /tb_RISCV_Processor/s_InstLd
add wave -radix hex /tb_RISCV_Processor/s_InstAddr
add wave -radix hex /tb_RISCV_Processor/s_InstExt

add wave -divider "Processor Internals"
add wave -radix hex /tb_RISCV_Processor/DUT/s_NextInstAddr
add wave -radix hex /tb_RISCV_Processor/DUT/s_Inst
add wave -radix hex /tb_RISCV_Processor/s_ALUOut

# Run simulation
run 1000 ns

# Fit waveform to window
wave zoom full