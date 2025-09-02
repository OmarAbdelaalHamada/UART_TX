`timescale 100ps/1ps
module UART_TX_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg PAR_EN;
    reg data_valid;
    reg [7:0] P_DATA;
    reg PAR_TYP;
    wire TX_out_tb;
    wire busy;
    
    //Parameters
    parameter CLK_PERIOD = 50; // Clock period in time units

    // Instantiate the UART_TX module
    UART_TX DUT (
        .clk(clk),
        .rst_n(rst_n),
        .PAR_EN(PAR_EN),
        .data_valid(data_valid),
        .P_DATA(P_DATA),
        .PAR_TYP(PAR_TYP),
        .TX_out(TX_out_tb),
        .busy(busy)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk; 

    // Initial block for testbench setup
    initial begin

        // System Functions
        $dumpfile("UART_TX_DUMP.vcd") ;       
        $dumpvars;

        // Initialize signals
        initial_setup();

        // Apply reset
        apply_reset();

        // Test case 1: Send data with even parity
        send_data(8'hA5, 0);
        check_busy();

        // Wait for serialization to complete
        check_TX_out_parity(P_DATA, PAR_EN);

        // Test case 2: Send data with odd parity
        send_data(8'h5A, 1);
        check_busy();

        // Wait for serialization to complete
        check_TX_out_parity(P_DATA, PAR_EN);

        // Test case 3: Send data with no parity
        PAR_EN = 0; // Disable parity
        send_data(8'hB7, 0);
        check_busy();

        // Wait for serialization to complete
        check_TX_out_parity(P_DATA, PAR_EN);

        // Test case 3: No data valid signal
        data_valid = 0;
        check_busy();

        // Finish simulation after some time
        $finish;
    end

    // Initialization task 
    task initial_setup;
        begin
            clk = 0;
            rst_n = 1; // Deassert reset
            PAR_EN = 1; // Enable parity
            data_valid = 0; // No data valid initially
            P_DATA = 8'h00; // Initialize data to zero
            PAR_TYP = 0; // Default to even parity
        end 
    endtask

    // Task to apply reset
    task apply_reset;
        begin
            rst_n = 0;
            #CLK_PERIOD; // Hold reset for one clock cycle
            rst_n = 1;
        end
    endtask

    // Task to send data
    task send_data(input [7:0] data, input parity_type);    
        begin
            P_DATA = data;
            PAR_TYP = parity_type;
            data_valid = 1; // Indicate that data is valid
            #CLK_PERIOD; // Wait for one clock cycle
            data_valid = 0; // Clear data valid signal
        end
    endtask

    // Task to check busy signal
    task check_busy;
        begin
            if (busy) begin
                $display("UART is busy");
            end else begin
                $display("UART is ready");
            end
        end
    endtask

    // Task to check TX_out serialization and parity
    task check_TX_out_parity;
        integer i;
        input [7:0] P_DATA;
        input PAR_EN;
        reg [10:0] expected_data;
        reg [10:0] test_data; // Test data for serialization
        begin
            // Wait for start bit (assume idle is high, start is low)
            //wait (TX_out_tb == 0);
            // Sample all 11 bits (start, 8 data, parity, stop)
            for (i = 0; i < 11; i = i + 1) begin
                test_data[i] = TX_out_tb;
                #CLK_PERIOD;
            end
            // Build expected data: {stop, parity, data, start}
            expected_data = {1'b1, (PAR_EN ? DUT.parity_calc_inst.parity_bit : 1'bx), P_DATA, 1'b0};
            if (PAR_EN) begin
                if (test_data !== expected_data) begin
                    $display("TX_out mismatch: expected %b, got %b", expected_data, test_data);
                end else begin
                    $display("TX_out matches expected data with parity.");
                end
            end 
            else begin
                // If parity is disabled, ignore parity bit in comparison
                if ({test_data[9:0]} !== {1'b1, P_DATA, 1'b0}) begin
                    $display("TX_out mismatch (no parity): expected %b, got %b", {1'b1, P_DATA, 1'b0}, {test_data[9:0]});
                end else begin
                    $display("TX_out matches expected data (no parity).");
                end
            end
        end
    endtask

endmodule
