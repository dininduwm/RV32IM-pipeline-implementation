import subprocess
import csv

control_logic_out = []
inst_name = []


# function to format the text
def format(numOfDigits, num):
    return str(num).zfill(numOfDigits)

# function to compare the result
def compareResult(value1, value2, ins):        
    value1 = list(value1)
    value2 = list(value2)
    for i in range(len(value1)):
        if value1[i] != value2[i]:
            if (value1[i] != 'x') and (value2[i] != 'x'): 
                print('\nChecking {}\t- > '.format(ins), end = '')               
                print('\n{}\n{}'.format(''.join(value1), ''.join(value2)))
                print('Test Failed\n')
                return False
    print('Checking {}\t- > '.format(ins), end = '')
    print("Test Pass")
    return True

# function to genarate the instruction
def genarateInstruction(opcode, funct3, funct7):
    return funct7 + ('x'*5) + ('x'*5) + funct3 + ('x'*5) + opcode


# reading the csv file
with open('RV32IM.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    write_file = open('testbench_input.txt', 'w')

    first_line = True
    for row in csv_reader:
        opcode = format(7, row[0])
        funct3 = format(3,row[1])
        funct7 = format(7,row[2])
        inst = row[3]
        alu_signal = format(1,row[4]) + format(1, row[5]) + format(3, row[6])
        reg_write = format(1, row[7])
        mem_write = format(1, row[8]) + format(2, row[9])
        mem_read =  format(1, row[10]) + format(3, row[11])
        branch_control = format(1, row[12]) + format(3, row[13])
        immediate = format(1, row[14]) + format(3,row[15])
        op1_sel = format(1, row[16])
        op2_sel = format(1, row[17])
        reg_write_sel = format(2, row[18])
        
        # print(opcode, funct3, funct7, alu_signal, reg_write, mem_write, mem_read, branch_control, immediate, op1_sel, op2_sel, reg_write_sel )
        
        
        if not first_line:
            control_logic_out.append(alu_signal + reg_write + mem_write + mem_read + branch_control + immediate + op1_sel + op2_sel + reg_write_sel )
            inst_name.append(inst)
            write_file.write(genarateInstruction(opcode, funct3, funct7)+'\n')
        
        first_line = False
    
    write_file.close() 
        

def compileAndRun(filename):
    compil = "iverilog -o " + filename.replace('.v', '') + ".out " + filename
    command = "cd .. ; cd verilog; " + compil +"; vvp " + filename.replace('.v', '') + ".out"


    output = subprocess.Popen(command, stdout=subprocess.PIPE, shell= True).communicate()[0].decode('utf-8')
    output = output.split('\n')
    output.pop()
    return output

output = compileAndRun('control_unit_testbench.v')
# print(output)
passcount = 0
# looping throug the tests
for i in range(len(output)):
    # print("Checking {} Instruction".format(inst_name[i]))
    if (compareResult(output[i], control_logic_out[i], inst_name[i])):
        passcount += 1

print("{}/{} Test cases passed".format(passcount, len(output)))

# print(output)

# compileAndRun("../alu.v")