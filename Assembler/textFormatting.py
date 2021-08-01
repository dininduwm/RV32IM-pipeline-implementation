# this file analyze the assembly code and identify the lables and
# different structures of code.

# instruction list
Instructions = []

def populate():
    # opening the assembly file
    f = open('test_prog.s', "r")
    # loop through the file and handle the instrctions separately
    for ins in f:
        Instructions.append(ins.strip())

# loop through the instructions and do the nessary stuff
def formatInstructions(Instructions):
    for ins in Instructions:
        formatInstruction(ins)

# format the different types of instructions
def formatInstruction(ins):
    # final instruction
    finalIns = []
    tmp_split = ins.split()
    instruction_name = tmp_split.pop(0)
    # spliting by the ','
    for tmp in tmp_split:
        # splitting by comma
        tmp_split_2 = tmp.split(',')
        tmp_split_2 = list(filter(lambda a: a != '', tmp_split_2))

        # segmented list before putting together
        segmented_list = []

        for item in tmp_split_2:
            # removing letter x 
            item = item.replace('x', '')
            # identifyng the sections with brackets
            if '(' and ')' in item:
                # removing ) from the string
                item = item.replace(')', '')
                tmp_split_3 = item.split('(')
                segmented_list.extend(tmp_split_3)
            else:
                segmented_list.append(item)

        finalIns.extend(segmented_list)

    print(instruction_name, finalIns)


populate()
print(Instructions)
formatInstructions(Instructions)