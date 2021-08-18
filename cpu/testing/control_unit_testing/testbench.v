`include "../../verilog/control_unit_module/control_unit.v"
`include "../../verilog/supported_modules/mux2to1_3bit.v"

module control_unit_tb;

    reg CLK, RESET;
    reg[31:0] INSTRUCTION;
    wire reg_file_write, oparand_1_select, oparand_2_select;
    wire [4:0] alu_signal;
    wire [2:0] main_mem_write;
    wire [3:0] main_mem_read;
    wire [3:0] branch_control, immediate_select;
    wire [1:0] reg_write_select; 

    // instruction register file to store all the instructions
    reg [31:0] ins_file [0:46];  

    // iniating the control unit module
    control_unit myConUnit( INSTRUCTION, 
                            alu_signal, 
                            reg_file_write, 
                            main_mem_write, 
                            main_mem_read, 
                            branch_control, 
                            immediate_select, 
                            oparand_1_select, 
                            oparand_2_select, 
                            reg_write_select, 
                            RESET );
    // varible for the loop
    integer n;
    
    initial begin
        // load the instructions from the register file
        $readmemb("testbench_input.txt", ins_file);        
        CLK = 1'b0;
        #1

        for (n=0; n<= 46; n=n+1) 
        begin
            INSTRUCTION = ins_file[n];

            #4
            // $display(" reg_write:%b\n op1:%b\n op2:%b\n alu:%b\n mem_write:%b\n mem_read:%b\n branch:%b\n immedi:%b\n reg_write_sel:%b\n", reg_file_write, oparand_1_select, oparand_2_select, alu_signal, main_mem_write, main_mem_read,
            //             branch_control, immediate_select, reg_write_select );
            $display("%b%b%b%b%b%b%b%b%b", 
                            alu_signal, 
                            reg_file_write, 
                            main_mem_write, 
                            main_mem_read, 
                            branch_control, 
                            immediate_select, 
                            oparand_1_select, 
                            oparand_2_select, 
                            reg_write_select);
        end

        #20
        $finish;
    end

    // clock genaration.
    always begin
        #10 CLK = ~CLK;
    end

endmodule