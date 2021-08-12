cd ../../Assembler/
ls
python3 assembler.py -i test_prog.s
cd ../cpu/verilog/
iverilog -o out.out testbenchCPU.v
vvp out.out  