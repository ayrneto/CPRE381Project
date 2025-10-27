vlib work
vmap work work

echo ============================
echo Compiling Design Files
echo ============================

vcom ControlUnit.vhd
vcom tb_ControlUnit.vhd
vcom BarrelShifter.vhd
vcom tb_BarrelShifter.vhd

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

