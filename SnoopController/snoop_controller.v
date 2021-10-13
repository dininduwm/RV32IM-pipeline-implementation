`timescale 1ns/100ps
`include "../cpu/verilog/supported_modules/mux16to1_28bit.v"
`include "../cpu/verilog/supported_modules/mux16to1_128bit.v"
/*
Inputs
CPU_X_INPUT_DATA_NOT_AVAILABLE -> this will signal the specific PE that has made a request from the snoop bus  
CPU_X_INPUT_ADDR_BUS; 
CPU_X_INPUT_DATA_BUS; 
CPU_X_INPUT_NEW_DATA_INTERUPT; 
CPU_X_INPUT_DATA_AVAILABLE;
*/

module snoopcontroller(BROADCAST_ADDR_BUS, 
                       BROADCAST_DATA_BUS, 
                       BROADCAST_INTERRUPT, 
                       CPU_1_INPUT_ADDR_BUS, 
                       CPU_1_INPUT_DATA_BUS, 
                       CPU_1_INPUT_NEW_DATA_INTERUPT, 
                       CPU_1_REQUEST_DATA_INTERUPT,
                       CPU_1_INPUT_REQUEST_DATA_INTERUPT,
                       CPU_1_INPUT_DATA_NOT_AVAILABLE, 
                       CPU_1_INPUT_DATA_AVAILABLE,
                       CPU_1_OUTPUT_DATA_FOUND,
                       CPU_1_OUTPUT_DATA_NOT_FOUND,

                       CPU_2_INPUT_ADDR_BUS, 
                       CPU_2_INPUT_DATA_BUS, 
                       CPU_2_INPUT_NEW_DATA_INTERUPT, 
                       CPU_2_REQUEST_DATA_INTERUPT,
                       CPU_2_INPUT_REQUEST_DATA_INTERUPT,
                       CPU_2_INPUT_DATA_NOT_AVAILABLE, 
                       CPU_2_INPUT_DATA_AVAILABLE,
                       CPU_2_OUTPUT_DATA_FOUND,
                       CPU_2_OUTPUT_DATA_NOT_FOUND);
    // for broadcasting
    output reg [27:0]   BROADCAST_ADDR_BUS; 
    output reg [127:0]  BROADCAST_DATA_BUS; 
    output reg BROADCAST_INTERRUPT;

    // for PE1 cache 
    output reg CPU_1_REQUEST_DATA_INTERUPT;
    output reg CPU_1_OUTPUT_DATA_NOT_FOUND;
    output reg CPU_1_OUTPUT_DATA_FOUND;

    input [27:0] CPU_1_INPUT_ADDR_BUS; 
    input [127:0] CPU_1_INPUT_DATA_BUS; 
    input CPU_1_INPUT_REQUEST_DATA_INTERUPT;
    input CPU_1_INPUT_NEW_DATA_INTERUPT; 
    input CPU_1_INPUT_DATA_AVAILABLE;
    input CPU_1_INPUT_DATA_NOT_AVAILABLE; 

    // for PE2 cache
    output reg CPU_2_REQUEST_DATA_INTERUPT;
    output reg CPU_2_OUTPUT_DATA_NOT_FOUND;
    output reg CPU_2_OUTPUT_DATA_FOUND;

    input CPU_2_INPUT_DATA_NOT_AVAILABLE; 
    input [27:0] CPU_2_INPUT_ADDR_BUS; 
    input [127:0] CPU_2_INPUT_DATA_BUS; 
    input CPU_2_INPUT_REQUEST_DATA_INTERUPT;
    input CPU_2_INPUT_NEW_DATA_INTERUPT; 
    input CPU_2_INPUT_DATA_AVAILABLE;


    

    wire SELECTED_PE_ADDR; // Address that was multiplexed out of all PEs
    wire SELECTED_PE_DATA; // Data that was multiplexed out of all PEs
    wire [3:0] PE_IDX; // the PE index that is used to for the mux

    PE_ADDR_mux mux16to1_28bit(CPU_1_INPUT_ADDR_BUS, CPU_2_INPUT_ADDR_BUS, 28'b0, 28'b0,
                               28'b0, 28'b0, 28'b0, 28'b0,
                               28'b0, 28'b0, 28'b0, 28'b0,
                               28'b0, 28'b0, 28'b0, 28'b0, SELECTED_PE_ADDR, PE_IDX);

    PE_DATA_mux mux16to1_128bit(CPU_1_INPUT_DATA_BUS, CPU_2_INPUT_DATA_BUS, 128'b0, 128'b0,
                               128'b0, 128'b0, 128'b0, 128'b0,
                               128'b0, 128'b0, 128'b0, 128'b0,
                               128'b0, 128'b0, 128'b0, 128'b0, SELECTED_PE_ADDR, PE_IDX);

    // ********* set the PE index to the relavant PE in order multiplex **********
    always @(posedge CPU_1_INPUT_REQUEST_DATA_INTERUPT, posedge CPU_1_INPUT_NEW_DATA_INTERUPT ) 
    begin
        PE_IDX = 0;
    end

    always @(posedge CPU_2_INPUT_REQUEST_DATA_INTERUPT, posedge CPU_2_INPUT_NEW_DATA_INTERUPT ) 
    begin
        PE_IDX = 1;
    end
    // ***************************************************************************


    /* 
    This will noftify the Snoop controller that it's chache has been updated in a specific PE (x).
    At this time the CPU_x_INPUT_ADDR_BUS and CPU_x_INPUT_DATA_BUS will contain 
    the data and the address of the newly updated cache block. 

    Then the duty of the snoop controller is to get the data and address from that specific PE and 
    put in the broadcast bus and notify all PE's that there is new data avalable in the bus 
    with the help of BROADCAST_INTERRUPT.
    */
    always @ (posedge CPU_1_INPUT_NEW_DATA_INTERUPT, posedge CPU_2_INPUT_NEW_DATA_INTERUPT) begin 
        
        #0.005 // this delay will make time for the multiplexing 
        BROADCAST_ADDR_BUS = SELECTED_PE_ADDR;
        BROADCAST_DATA_BUS = SELECTED_PE_DATA;

        #0.001
        BROADCAST_INTERRUPT = 1'b1;
        #0.004
        BROADCAST_INTERRUPT = 1'b0;
    end


    /*
    This will handle a request from a PE to the snoop controller. If a specific PE got a cache miss and that
    PE is checking wheather the missed cache block is available in the caches of other PEs.

    Then the snoop controller should ask for that requested ADDR from each PE in the system by signaling
    CPU_1_REQUEST_DATA_INTERUPT. Then each PE will respond to the Snoop Controller through CPU_1_INPUT_DATA_AVAILABLE
    CPU_1_INPUT_DATA_NOT_AVAILABLE about the availability of that ADDR. Now the snoop controller can respond to the PE
    that made the request in the begining about the availabilty of the data relevent to ADDR through 
    CPU_1_OUTPUT_DATA_NOT_FOUND and  CPU_1_OUTPUT_DATA_FOUND.
    */
    
    always @ (posedge CPU_1_INPUT_REQUEST_DATA_INTERUPT, posedge CPU_2_INPUT_REQUEST_DATA_INTERUPT) begin 
        #0.005 // this delay will make time for the multiplexing 
        BROADCAST_ADDR_BUS = SELECTED_PE_ADDR;
        // BROADCAST_DATA_BUS = SELECTED_PE_DATA;
        
        // Requesting from CPU 1
        CPU_1_REQUEST_DATA_INTERUPT = 1'b1;
        #0.004
        CPU_1_REQUEST_DATA_INTERUPT = 1'b0;
        #0.1 // wait for the PE to respond
        
        // if data not available in CPU1
        if (CPU_1_INPUT_DATA_NOT_AVAILABLE == 1'b1)
            begin
                // Requesting from CPU 1
                CPU_2_REQUEST_DATA_INTERUPT = 1'b1;
                #0.004
                CPU_2_REQUEST_DATA_INTERUPT = 1'b0;
                #0.1 // wait for the PE to respond

                // checking the data status from PE2
                if (CPU_2_INPUT_DATA_NOT_AVAILABLE == 1'b1)
                    begin
                        
                        CPU_1_OUTPUT_DATA_NOT_FOUND = 1'b1;
                        #0.004
                        CPU_1_OUTPUT_DATA_NOT_FOUND = 1'b0;
                        #0.004;
                    end
                else
                    begin
                        PE_IDX = 1;
                        #0.1 // wait for the multiplex
                        BROADCAST_DATA_BUS = SELECTED_PE_DATA;
                        // sending the interupt to PE mentioning data found
                        CPU_1_OUTPUT_DATA_FOUND = 1'b1;
                        #0.004
                        CPU_1_OUTPUT_DATA_FOUND = 1'b0;
                        #0.004;
                    end
            end
        else
            begin
                PE_IDX = 1;
                #0.1 // wait for the multiplex
                BROADCAST_DATA_BUS = SELECTED_PE_DATA;
                // sending the interupt to PE mentioning data found
                CPU_1_OUTPUT_DATA_FOUND = 1'b1;
                #0.004
                CPU_1_OUTPUT_DATA_FOUND = 1'b1;
                #0.004
            end

        // wait (vif.xn_valid == 1'b1);
    end
    

endmodule