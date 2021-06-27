`timescale 1ns/100ps

module data_cache_memory(
	clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
	busywait,
    MAIN_MEM_READ, 
    MAIN_MEM_WRITE, 
    MAIN_MEM_ADDRESS,
    MAIN_MEM_WRITE_DATA, 
    MAIN_MEM_READ_DATA, 
    MAIN_MEM_BUSY_WAIT
);
    input				clock;
    input           	reset;
    input           	read;
    input           	write;
    input[31:0]      	address;
    input[31:0]     	writedata;
    output reg [31:0]	readdata;
    output reg      	busywait;

    // main memory input outputs
    output              MAIN_MEM_READ;
    output              MAIN_MEM_WRITE;
    output[27:0]        MAIN_MEM_ADDRESS;
    output[127:0]       MAIN_MEM_WRITE_DATA;
    input[127:0]        MAIN_MEM_READ_DATA;
    input               MAIN_MEM_BUSY_WAIT;

    //Declare cache memory array 256x8-bits 
    reg [127:0] data_array [8:0];
    //Declare tag array 256x8-bits 
    reg [2:0] tag_array [8:0];
    //Declare valid bit array 256x8-bits 
    reg [1:0] dirtyBit_array [8:0];
    //Declare valid bit array 256x8-bits 
    reg [1:0] validBit_array [8:0];

    parameter IDLE = 2'b00, MEM_READ = 2'b01, MEM_WRITE = 2'b10;
    reg [1:0] state, next_state;

    // variables to handle state changes
    reg CURRENT_DIRTY, CURRENT_VALID;
    reg [2:0] CURRENT_TAG;
    reg [127:0] CURRENT_DATA;
    wire TAG_MATCH;

    // tempory variable to hold the data from the cache
    reg [31:0] tempory_data;

    // variables to hold the values of the memory module
    reg MAIN_MEM_READ, MAIN_MEM_WRITE;
    reg [27:0] MAIN_MEM_ADDRESS;
    reg [127:0] MAIN_MEM_WRITE_DATA;
    wire [127:0] MAIN_MEM_READ_DATA;
    wire MAIN_MEM_BUSY_WAIT;

    reg readCache; // reg to remember the read to cache signal until the posedge
    reg writeCache; // reg to write the write cache signal until the posedge

    reg writeCache_mem; // write enable signal to write to the cache mem after a memory read 

    //initiating the memory module
    //data_memory myDataMem (clock, reset, MAIN_MEM_READ, MAIN_MEM_WRITE, MAIN_MEM_ADDRESS,
    //        MAIN_MEM_WRITE_DATA, MAIN_MEM_READ_DATA, MAIN_MEM_BUSY_WAIT);

    // decoding the address
    wire [2:0] tag, index;
    wire [1:0] offset;
    
    assign tag = address[31:5];
    assign index = address[4:2];
    assign offset = address[1:0];

    // loading data 
    always @ (*)
    begin
        // TODO : set the time delay
        #1 // loading the current values
        CURRENT_VALID = validBit_array[index];
        CURRENT_DIRTY = dirtyBit_array[index];
        CURRENT_DATA  = data_array[index];
        CURRENT_TAG   = tag_array[index];
    end

    // tag matching
    // TODO: Check for the timing
    assign #0.9 TAG_MATCH = ~(tag[2]^CURRENT_TAG[2]) && ~(tag[1]^CURRENT_TAG[1]) && ~(tag[0]^CURRENT_TAG[0]);

    // putting data if read access
    always @(*)
    begin
        if (readaccess) // detect the idle read status
        // TODO : set the time delay
        #1
        begin
            // fetching data
            case(offset)
                2'b00:
                    readdata = data_array[index][31:0];
                2'b01:
                    readdata = data_array[index][63:32];
                2'b10:
                    readdata = data_array[index][95:64];
                2'b11:
                    readdata = data_array[index][127:96];
            endcase
        end
    end

    //Detecting an incoming memory access
    reg readaccess, writeaccess;
    always @(read, write)
    begin
        busywait = (read || write)? 1 : 0;
        readaccess = (read && !write)? 1 : 0;
        writeaccess = (!read && write)? 1 : 0;
    end

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!CURRENT_VALID && (readaccess || writeaccess)) 
                    next_state = MEM_READ;
                else if (CURRENT_VALID && TAG_MATCH && (readaccess || writeaccess))
                    next_state = IDLE;
                else if (CURRENT_VALID && !CURRENT_DIRTY && !TAG_MATCH && (readaccess || writeaccess))
                    next_state = MEM_READ;
                else if (CURRENT_VALID && CURRENT_DIRTY && !TAG_MATCH && (readaccess || writeaccess))
                    next_state = MEM_WRITE;
            
            MEM_READ:
                if (MAIN_MEM_BUSY_WAIT)
                    next_state = MEM_READ; 
                else
                    next_state = IDLE;               


            MEM_WRITE:
                if (MAIN_MEM_BUSY_WAIT)
                    next_state = MEM_WRITE;
                else   
                    begin 
                        //next_state = IDLE;
                        if (CURRENT_VALID && !TAG_MATCH)
                            next_state = MEM_READ;
                        else
                            next_state = IDLE;
                    end
            
        endcase
    end
    
    // combinational output logic
    always @(*)
    begin
        if (readaccess || writeaccess)
        begin
            case(state)
                IDLE:
                begin
                    // set main memory read and write signal to low
                    MAIN_MEM_READ = 1'b0;
                    MAIN_MEM_WRITE = 1'b0;    

                    if (readaccess && TAG_MATCH && CURRENT_VALID)
                    begin
                        readCache = 1'b1; // set read cache memory to high
                        //readdata = tempory_data; // output the data
                    end
                    else readCache = 1'b0; // set the readCache signal to zero
                    

                    if (writeaccess && TAG_MATCH && CURRENT_VALID) // detect the idle write status
                    begin                                               
                        writeCache = 1'b1; // set write to cache memory to high
                    end
                    else writeCache = 1'b0; //set the write cache signal to zero
                    
                end
            
                MEM_READ: 
                begin
                    MAIN_MEM_READ = 1'b1;
                    MAIN_MEM_WRITE = 1'b0;
                    // set the address to teh main memory
                    MAIN_MEM_ADDRESS = {tag, index};

                    if (!MAIN_MEM_BUSY_WAIT)  writeCache_mem = 1'b1;
                    else writeCache_mem = 1'b0; 
                end

                MEM_WRITE: 
                begin
                    MAIN_MEM_READ = 1'b0;
                    MAIN_MEM_WRITE = 1'b1;
                    // set the address to the main memory
                    MAIN_MEM_ADDRESS = {tag_array[index], index};
                    // set data to be written
                    MAIN_MEM_WRITE_DATA = data_array[index];
                    if (!MAIN_MEM_BUSY_WAIT)
                    begin
                        validBit_array[index] = 1'b1; // set the valid bit after loading data
                        dirtyBit_array[index] = 1'b0; // set the valid bit after writing data
                    end
                end
                
            endcase
        end
    end

    integer i;

    // sequential logic for state transitioning 
    always @(posedge reset)
    begin
        if(reset)
        begin
            busywait = 1'b0;
            for (i=0;i<8; i=i+1) // resetting the registers
                begin
                    data_array[i] = 0;
                    validBit_array[i] = 0;
                    dirtyBit_array[i] = 0;
                end
        end
    end

    // state change logic
    always @ (posedge clock)
    begin
        if (!reset)
            state = next_state;
        else
            begin
                state = IDLE;
                next_state = IDLE;
            end
    end

    // writing cache after a memory read
    always @ (posedge clock)
    begin
        if (writeCache_mem)
        begin
            #1
            // put the read data to the cache
            data_array[index] = MAIN_MEM_READ_DATA;
            tag_array[index] = tag;
            validBit_array[index] = 1'b1; // set the valid bit after loading data
            dirtyBit_array[index] = 1'b0; // set the dirty bit after loading data
        end
    end

    // to deassert and write back to the posedge
    always @ (posedge clock)
    begin
        if (readCache || writeCache)
        begin       
            busywait = 1'b0; // set the busy wait signal to zero     
            readCache = 1'b0; // pull the read signal to low
        end

        if (writeCache) 
        begin
            #1
            case(offset) // writing to the register
                2'b00:
                    data_array[index][7:0] = writedata;
                2'b01:
                    data_array[index][15:8] = writedata;
                2'b10:
                    data_array[index][23:16] = writedata;
                2'b11:
                    data_array[index][31:24] = writedata;
            endcase

            dirtyBit_array[index] = 1'b1; // set the dirty bit because data is not consistant with the memory
            writeCache = 1'b0; // pull the write signal to low
        end
    end

    /* Cache Controller FSM End */

endmodule