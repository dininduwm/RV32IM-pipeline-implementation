
`timescale 1ns/100ps

module alu(DATA1, DATA2, RESULT, SELECT);

    input [31:0] DATA1, DATA2; //declare the inputs
    input [3:0] SELECT; //declare the select input
    output [31:0] RESULT; //declare the output

    reg [31:0] RESULT; // declare the outputs as registers

    wire [31:0] INTER_FWD, 
                INTER_ADD, 
                INTER_AND, 
                INTER_OR, 
                INTER_SLL, 
                INTER_SRL, 
                INTER_XOR; // intermediate signals to hold the calculations

    // TODO : set the time delay
    // assigning the values to the different operations
    assign #1 INTER_FWD = DATA2; //forward operation  1
    assign #2 INTER_ADD = DATA1 + DATA2; // add operation 2
    assign #1 INTER_AND =  DATA1 & DATA2; // bitwise and operation 1
    assign #1 INTER_OR =  DATA1 | DATA2; // bitwise or operation 1
    assign #1 INTER_XOR =  DATA1 ^ DATA2; // bitwise XOR operation 1
    
    //TODO: check for the side DATA1 and DATA2
    assign #1 INTER_SLL = DATA1 << DATA2; // bitwise left shift logical
    assign #1 INTER_SRL = DATA1 >> DATA2; // bitwise right shift logical

    always @ (*) // this block run if there is any change in DATA1 or DATA2 or SELECT
    begin
        case (SELECT)
        3'b000:
            RESULT = INTER_FWD; 
        3'b001:
            RESULT = INTER_ADD; 
        3'b010:
            RESULT = INTER_AND; 
        3'b011:
            RESULT = INTER_OR; 
        default: RESULT = 0; //result 0 if the other cases
        endcase
    end
    
endmodule