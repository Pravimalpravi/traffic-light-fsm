module tb;

    logic clk;
    logic reset;

    logic A_green;
    logic A_yellow;
    logic A_red;

    logic B_green;
    logic B_yellow;
    logic B_red;

    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    // DUT

    traffic_controller dut (
        .clk(clk),
        .reset(reset),

        .A_green(A_green),
        .A_yellow(A_yellow),
        .A_red(A_red),

        .B_green(B_green),
        .B_yellow(B_yellow),
        .B_red(B_red)
    );

  

    // Clock

    initial begin
      
		$dumpfile("dumpvars.vcd");
        $dumpvars;      
      
        clk = 1'b0;
    end

    always #5 clk = ~clk;


    // Check task

    task check_lights(
        input logic exp_A_green,
        input logic exp_A_yellow,
        input logic exp_A_red,
        input logic exp_B_green,
        input logic exp_B_yellow,
        input logic exp_B_red
    );

        begin

            total_tests = total_tests + 1;

            if (A_green  === exp_A_green  &&
                A_yellow === exp_A_yellow &&
                A_red    === exp_A_red    &&
                B_green  === exp_B_green  &&
                B_yellow === exp_B_yellow &&
                B_red    === exp_B_red) begin

                passed_tests = passed_tests + 1;

            end
            else begin

                failed_tests = failed_tests + 1;

                $display(
                    "FAIL at t=%0t | A=%b%b%b B=%b%b%b",
                    $time,
                    A_green, A_yellow, A_red,
                    B_green, B_yellow, B_red
                );

            end

        end

    endtask


    // Test sequence

    initial begin

        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        // Assert reset
        reset = 1'b0;

        // First rising edge initializes S0
        @(posedge clk);
        #1;

        check_lights(
            1'b1, 0, 0,   // A GREEN
            0, 0, 1       // B RED
        );


        // Release reset
        reset = 1'b1;


        // S0: A GREEN for 5 cycles

        repeat (4) begin
            @(posedge clk);
            #1;

            check_lights(
                1'b1, 0, 0,
                0, 0, 1
            );
        end


        // S1: A YELLOW for 2 cycles

        @(posedge clk);
        #1;

        check_lights(
            0, 1, 0,
            0, 0, 1
        );

        @(posedge clk);
        #1;

        check_lights(
            0, 1, 0,
            0, 0, 1
        );


        // S2: B GREEN for 5 cycles

        repeat (5) begin
            @(posedge clk);
            #1;

            check_lights(
                0, 0, 1,
                1, 0, 0
            );
        end


        // S3: B YELLOW for 2 cycles

        repeat (2) begin
            @(posedge clk);
            #1;

            check_lights(
                0, 0, 1,
                0, 1, 0
            );
        end


        // Back to S0

        @(posedge clk);
        #1;

        check_lights(
            1, 0, 0,
            0, 0, 1
        );


        // Final report

        $display("");
        $display("TRAFFIC CONTROLLER VERIFICATION");
        $display("TOTAL TESTS : %0d", total_tests);
        $display("PASSED      : %0d", passed_tests);
        $display("FAILED      : %0d", failed_tests);
        

        if (failed_tests == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("VERIFICATION FAILED!");

        $finish;

    end

endmodule
