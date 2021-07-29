import csv
inst_data = {}

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
            funct3 = format(3,row[1])
            funct7 = format(7,row[2])
            inst = row[3]
            _type = row[4]
            inst_data[inst] = {'opcode':opcode, 'funct3':funct3, 'funct7':funct7, 'type':_type}

read_csv()
print(inst_data)