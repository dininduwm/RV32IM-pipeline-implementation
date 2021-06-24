`include "multiplier.v"
`timescale 1ns/100ps

module alu(DATA1, DATA2, RESULT, SELECT, COMP);

    input [7:0] DATA1, DATA2; //declare the inputs
    input [2:0] SELECT; //declare the select input
    output [7:0] RESULT; //declare the output
    output COMP; //comparator output

    reg [7:0] RESULT; // declare the outputs as registers
    wire [7:0] MULRESULT; //result of the multiplier module

    wire [7:0] INTER_FWD, INTER_ADD, INTER_AND, INTER_OR; // intermediate signals to hold the calculations

    // assigning the values to the different operations
    assign #1 INTER_FWD = DATA2; //forward operation  1
    assign #2 INTER_ADD = DATA1 + DATA2; // add operation 2
    assign #1 INTER_AND =  DATA1 & DATA2; // bitwise and operation 1
    assign #1 INTER_OR =  DATA1 | DATA2; // bitwise or operation 1

    //initiating multiplier module
    multiplier mul(DATA1, DATA2, MULRESULT); 

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
        3'b100:
            RESULT = MULRESULT; //result of the multiplier
        default: RESULT = 0; //result 0 if the other cases
        endcase
    end

    assign COMP = ~(RESULT[7]|RESULT[6]|RESULT[5]|RESULT[4]|RESULT[3]|RESULT[2]|RESULT[1]);  //comparator
    
endmodule