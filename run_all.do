vlib work
vmap work work

echo ============================
echo Compiling Design Files
echo ============================

# Compile supporting components first
vcom AddSub_32b.vhd
vcom LogicUnit.vhd
vcom mux2to1_32b.vhd
vcom Extender.vhd
vcom PC.vhd

# Compile main components
vcom ControlUnit.vhd
vcom BarrelShifter.vhd
vcom ALU.vhd

# Compile testbenches
vcom tb_ControlUnit.vhd
vcom tb_BarrelShifter.vhd
vcom tb_ALU.vhd
vcom tb_Extender.vhd
vcom tb_FetchLogic.vhd

echo ============================
echo Running Control Unit Testbench
echo ============================
vsim -voptargs=+acc work.tb_ControlUnit
run 1 ns
add wave -r sim:/tb_ControlUnit/*
run 200 ns
quit -sim

echo ============================
echo Running Barrel Shifter Testbench
echo ============================
vsim -voptargs=+acc work.tb_BarrelShifter
run 1 ns
add wave -r sim:/tb_BarrelShifter/*
run 200 ns
quit -sim

echo ============================
echo Running ALU Testbench
echo ============================
vsim -voptargs=+acc work.tb_ALU
run 1 ns
add wave -r sim:/tb_ALU/*
run 500 ns
quit -sim

echo ============================
echo Running Extender Testbench
echo ============================
vsim -voptargs=+acc work.tb_Extender
run 1 ns
add wave -r sim:/tb_Extender/*
run 300 ns
quit -sim

echo ============================
echo Running Fetch Logic Testbench
echo ============================
vsim -voptargs=+acc work.tb_FetchLogic
run 1 ns
add wave -r sim:/tb_FetchLogic/*
run 400 ns
quit -sim

echo ============================
echo All Testbenches Complete
echo ============================

