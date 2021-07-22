`include "../../verilog/immediate_select.v"

module immediate_select_tb;

    reg CLK, RESET;
    reg[31:0] INSTRUCTION;
    reg [3:0] SELECT;
    wire [31:0] OUT;

    immediate_select my_immediate_select(INSTRUCTION, SELECT, OUT);
    
    integer n;
    reg [3:0] type;
    reg [31:0] temp;
    
    
    initial begin
        $monitor("TYPE%d --> input: 0x%h | Output: 0x%h ", type, temp, OUT);
        
        // Type1 Instruction
        INSTRUCTION =  $random;
        SELECT = 4'b0000;
        type = 1;
        temp = INSTRUCTION[31:12];
        #2
    
        // Type2 Instruction
        INSTRUCTION =  $random;
        SELECT = 4'b0001;
        type = 2;
        temp = INSTRUCTION[31:12];
        #2

        // Type3 Instruction
        INSTRUCTION =  $random;
        SELECT = 4'b0010;
        type = 3;
        temp = INSTRUCTION[31:20];
        #2
        INSTRUCTION =  $random;
        SELECT = 4'b1010;
        type = 3;
        temp = INSTRUCTION[31:20];
        #2

        // Type4 Instruction
        INSTRUCTION =  $random;
        SELECT = 4'b0011;
        type = 4;
        temp = {INSTRUCTION[31:25], INSTRUCTION[11:7]};
        #2
        
         // Type5 Instruction
        INSTRUCTION =  $random;
        SELECT = 4'b0100;
        type = 5;
        temp = {INSTRUCTION[31:25], INSTRUCTION[11:7]};
        #2
       
         // Type6 Instruction
        INSTRUCTION =  $random;
        SELECT = 4'b0101;
        type = 6;
        temp = INSTRUCTION[29:25]; 
        #2
        
        #20
        $finish;
    end

    // clock genaration.
    always begin
        #10 CLK = ~CLK;
    end

endmodule