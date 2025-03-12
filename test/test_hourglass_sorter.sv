`timescale 1ns / 1ps

module test_hourglass_sorter;
    parameter NUMBER_OF_ELEMENTS = 21;
    parameter KEY_WIDTH = 8;
    parameter VALUE_WIDTH = 10;
    
    logic clk, rst;
    logic load;
    logic [NUMBER_OF_ELEMENTS*KEY_WIDTH-1:0] in_keys;
    logic [NUMBER_OF_ELEMENTS*VALUE_WIDTH-1:0] in_values;
    logic [KEY_WIDTH-1:0] axis_out_key;
    logic [VALUE_WIDTH-1:0] axis_out_value;
    logic axis_out_valid;
    logic axis_out_ready;

    // DUT instance
    hourglass_sorting_module  
    # (
        .NUMBER_OF_ELEMENTS(NUMBER_OF_ELEMENTS),
        .KEY_WIDTH(KEY_WIDTH),
        .VALUE_WIDTH(VALUE_WIDTH)
    ) dut
    (
        .clk(clk), .rst(rst), .load(load),
        .in_keys(in_keys), .in_values(in_values),
        .axis_out_key(axis_out_key), .axis_out_value(axis_out_value),
        .axis_out_valid(axis_out_valid), .axis_out_ready(axis_out_ready)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to generate random input vectors
    task generate_random_inputs();
        int i;
        int keys[NUMBER_OF_ELEMENTS];
        int values[NUMBER_OF_ELEMENTS];
        
        for (i = 0; i < NUMBER_OF_ELEMENTS; i++) begin
            keys[i] = $urandom % (4);
            values[i] = i % (1 << VALUE_WIDTH);
        end
        
        // Pack into vectors
        in_keys = '0;
        in_values = '0;
        for (i = 0; i < NUMBER_OF_ELEMENTS; i++) begin
            in_keys |= keys[i] << (i * KEY_WIDTH);
            in_values |= values[i] << (i * VALUE_WIDTH);
        end
    endtask

    // Task to check sorted output
    task check_sorted_output();
        int last_key;
        int current_key;
        int last_value;
        int current_value;
        int i;

        // Wait for valid data
        i = 0;
        while (i < NUMBER_OF_ELEMENTS) begin
            wait(axis_out_valid);
            axis_out_ready = 1;
            current_key = axis_out_key;
            current_value = axis_out_value;
            
            if (i > 0 && current_key < last_key) begin
                $display("ERROR: Output not sorted at index %d", i);
                $finish;
            end else if (i > 0 && current_key == last_key && current_value < last_value) begin
                $display("ERROR: Output sorted, but original order not respected at index %d", i);
                $finish;
            end

            last_key = current_key;
            last_value = current_value;
            i++;
            @(posedge clk);
        end
        axis_out_ready = 0;
        $display("Test passed: Output sorted correctly");
    endtask

    // Test sequence
    initial begin
        int seed;
        seed = 29; // Use current simulation time as seed
        $srandom(seed); // Seed the RNG
        
        clk = 0; rst = 1; load = 0; axis_out_ready = 0;
        #20 rst = 0;
        #100;

        repeat (1000) begin // Run multiple tests
            generate_random_inputs();
            @(negedge clk);
            load = 1;
            @(negedge clk);
            load = 0;
            
            check_sorted_output();
            #50;
        end

        $display("All tests passed!");
        $finish;
    end
endmodule
