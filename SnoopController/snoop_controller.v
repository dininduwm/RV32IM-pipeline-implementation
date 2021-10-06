`timescale 1ns/100ps

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
    output reg CPU_1_INPUT_REQUEST_DATA_INTERUPT;
    output reg CPU_1_OUTPUT_DATA_NOT_FOUND;
    output reg CPU_1_OUTPUT_DATA_FOUND;

    input CPU_1_INPUT_DATA_NOT_AVAILABLE; 
    input [27:0] CPU_1_INPUT_ADDR_BUS; 
    input [127:0] CPU_1_INPUT_DATA_BUS; 
    input CPU_1_INPUT_NEW_DATA_INTERUPT; 
    input CPU_1_INPUT_DATA_AVAILABLE;

    // for PE2 cache
    output reg CPU_2_REQUEST_DATA_INTERUPT;
    output reg CPU_2_INPUT_REQUEST_DATA_INTERUPT;
    output reg CPU_2_OUTPUT_DATA_NOT_FOUND;
    output reg CPU_2_OUTPUT_DATA_FOUND;

    input CPU_2_INPUT_DATA_NOT_AVAILABLE; 
    input [27:0] CPU_2_INPUT_ADDR_BUS; 
    input [127:0] CPU_2_INPUT_DATA_BUS; 
    input CPU_2_INPUT_NEW_DATA_INTERUPT; 
    input CPU_2_INPUT_DATA_AVAILABLE;


endmodule