
a = '021010010010'


# Instruction = toBin(12, separatedIns[3]) + space + toBin(5, separatedIns[2]) + space + inst_data[separatedIns[0]]['funct3'] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']

# immediate = toBin(12, separatedIns[3])
immediate = '123456789'
Instruction = immediate[2:7]
print(Instruction)