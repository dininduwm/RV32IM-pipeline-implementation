cd ../Assembler/
python3 assembler.py -i test_prog.s
cd ../cpu/verilog/testbench/
iverilog -o ../../build/out.out testbenchCPU.v
vvp ../../build/out.out  