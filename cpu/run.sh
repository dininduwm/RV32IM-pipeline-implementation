cd ../Assembler/
python3 assembler.py -i $1 -o test_prog.bin
cd ../cpu/verilog/testbench/
iverilog -o ../../build/out.out testbenchCPU.v
vvp ../../build/out.out  

# echo $1