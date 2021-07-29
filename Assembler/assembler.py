import sys
import csv
from itertools import chain


# instruction sets grouped by the type
inst_data = {}

# arg types
argList = {'inp_file': '', 'out_file': ''}
# arg keywords
argKeys = {'-i': 'inp_file', '-o': 'out_file'}

# function to format the text


def format(numOfDigits, num):
    return str(num).zfill(numOfDigits)

# read the csv and create the instruction data dictionary


def read_csv():
    # reading the csv file
    with open('RV32IM.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')

        for row in csv_reader:
            opcode = format(7, row[0])
            funct3 = format(3, row[1])
            funct7 = format(7, row[2])
            inst = row[3]
            _type = row[4]
            inst_data[inst] = {'opcode': opcode,
                               'funct3': funct3, 'funct7': funct7, 'type': _type}

# handling the separate assembly instructions


def handleInstruction(Instruction):
    separatedIns = list(map(lambda a: a.strip(), Instruction.split(',')))
    # converting to the instrction to upper case
    separatedIns = list(map(lambda a: a.upper(), separatedIns))
    if len(separatedIns) > 0:
        separatedIns[0] = list(
            map(lambda a: a.strip(), separatedIns[0].split()))
        separatedIns = list(chain.from_iterable(separatedIns))
        print(separatedIns)

        Instruction = None
        # handle R-Type instructions
        if(inst_data[separatedIns[0]]['type'] == "R-Type"):
            Instruction = inst_data[separatedIns[0]]['funct7'] + toBin(5, separatedIns[3]) + toBin(
                5, separatedIns[2]) + inst_data[separatedIns[0]]['funct3'] + toBin(5, separatedIns[1]) + inst_data[separatedIns[0]]['opcode']
            print(Instruction)
# taking the file name if passed as an argument


def handleArgs():
    n = len(sys.argv)
    for i in range(1, n):
        if (sys.argv[i].strip() in argKeys):
            argList[argKeys[sys.argv[i]]] = sys.argv[i+1]


# opening the assemblyfile and reading through the file
def handleInpFile():
    if argList['inp_file'] == '':
        print('Input file not found')
        sys.exit(1)

    # opening the assembly file
    f = open(argList['inp_file'], "r")
    # loop through the file and handle the instrctions separately
    for ins in f:
        handleInstruction(ins)

# convert a given number to binary according to a given format


def toBin(numOfDigits, num):
    return format(numOfDigits, "{0:b}".format(num))

# saving data to a .bin file


def saveToFile(line):
    file = argList['inp_file'].split('.')[0] + '.bin'
    if not (argList['out_file'] == ''):
        file = argList['out_file']
    # saving the new line to the output file
    f = open(file, "a")
    f.write("Now the file has more content!")
    f.close()


if __name__ == "__main__":
    # handdle the argments
    handleArgs()
    # input file reding sequence
    handleInpFile()
