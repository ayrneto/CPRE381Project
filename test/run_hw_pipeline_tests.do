vlib work
vmap work work

echo ============================
echo Compiling Design Files for Hardware-Scheduled Pipeline
echo ============================

# Compile supporting components first
vcom ../AddSub_32b.vhd
vcom ../NBitRegister.vhd
vcom ../RegisterFile.vhd
vcom ../LogicUnit.vhd
vcom ../mux2to1_32b.vhd
vcom ../Extender.vhd
vcom ../PC.vhd
vcom ../mem.vhd

# Compile main components
vcom ../ControlUnit.vhd
vcom ../BarrelShifter.vhd
vcom ../ALU.vhd

# Compile pipeline registers
vcom ../IF_ID.vhd
vcom ../ID_EX.vhd
vcom ../EX_Mem.vhd
vcom ../Mem_WB.vhd

# Compile NEW hardware-scheduled pipeline components
vcom ../ForwardingUnit.vhd
vcom ../HazardDetectionUnit.vhd
vcom ../ForwardMuxA.vhd
vcom ../ForwardMuxB.vhd

# Compile main processor
vcom ../RISCV_Processor.vhd

# Compile testbenches
vcom tb_ForwardingUnit.vhd
vcom tb_HazardDetectionUnit.vhd
vcom tb_ForwardMuxA.vhd
vcom tb_ForwardMuxB.vhd
vcom tb_RISCV_Processor_HW.vhd

echo ============================
echo Running ForwardingUnit Testbench
echo ============================
vsim -voptargs=+acc work.tb_ForwardingUnit
run 1 ns
add wave -r sim:/tb_ForwardingUnit/*
run 200 ns
wave zoom full
quit -sim

echo ============================
echo Running HazardDetectionUnit Testbench  
echo ============================
vsim -voptargs=+acc work.tb_HazardDetectionUnit
run 1 ns
add wave -r sim:/tb_HazardDetectionUnit/*
run 200 ns
wave zoom full
quit -sim

echo ============================
echo Running ForwardMuxA Testbench
echo ============================
vsim -voptargs=+acc work.tb_ForwardMuxA
run 1 ns
add wave -r sim:/tb_ForwardMuxA/*
run 150 ns
wave zoom full
quit -sim

echo ============================
echo Running ForwardMuxB Testbench
echo ============================
vsim -voptargs=+acc work.tb_ForwardMuxB
run 1 ns
add wave -r sim:/tb_ForwardMuxB/*
run 150 ns
wave zoom full
quit -sim

echo ============================
echo Running Hardware-Scheduled Processor Testbench
echo ============================
vsim -voptargs=+acc work.tb_RISCV_Processor_HW
run 1 ns
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_ForwardA
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_ForwardB
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_PCWrite
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_IF_ID_Write
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_FlushMux_Sel
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_ALUResult
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_NextInstAddr
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_ID_Inst
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_EX_rs1
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_EX_rs2
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_MEM_rd
add wave -r sim:/tb_RISCV_Processor_HW/uut/s_WB_rd
run 600 ns
wave zoom full
quit -sim

echo ============================
echo Hardware-Scheduled Pipeline Tests Complete
echo ============================
echo Results Summary:
echo - ForwardingUnit: Tests data hazard detection and forwarding control
echo - HazardDetectionUnit: Tests load-use hazard detection and stalling
echo - ForwardMuxA/B: Tests forwarding mux functionality  
echo - RISCV_Processor_HW: Tests complete hardware-scheduled pipeline
echo ============================
echo Compare with software-scheduled version to see improvements:
echo - No manual NOPs required
echo - Automatic hazard resolution
echo - Better performance through forwarding
echo ============================