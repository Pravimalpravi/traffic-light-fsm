module traffic_controller (
    input  logic clk,
    input  logic reset,

    output logic A_green,
    output logic A_yellow,
    output logic A_red,

    output logic B_green,
    output logic B_yellow,
    output logic B_red
);

    // State definition

    typedef enum logic [1:0] {
        S0 = 2'b00,   // A Green,  B Red
        S1 = 2'b01,   // A Yellow, B Red
        S2 = 2'b10,   // A Red,    B Green
        S3 = 2'b11    // A Red,    B Yellow
    } state_t;

    state_t state, next_state;
    // Counter needs to represent 0 through 4
    logic [2:0] counter;
    logic [2:0] next_counter;


    // State + counter registers

    always_ff @(posedge clk) begin

        if (!reset) begin
            state   <= S0;
            counter <= 3'd0;
        end
        else begin
            state   <= next_state;
            counter <= next_counter;
        end

    end


    // Next-state + next-counter logic

    always_comb begin

        next_state   = state;
        next_counter = counter;

        case (state)

            // S0: A GREEN, B RED
            // Duration = 5 cycles

            S0: begin

                if (counter == 3'd4) begin
                    next_state   = S1;
                    next_counter = 3'd0;
                end
                else begin
                    next_counter = counter + 3'd1;
                end

            end


            // S1: A YELLOW, B RED
            // Duration = 2 cycles

            S1: begin

                if (counter == 3'd1) begin
                    next_state   = S2;
                    next_counter = 3'd0;
                end
                else begin
                    next_counter = counter + 3'd1;
                end

            end


            // S2: A RED, B GREEN
            // Duration = 5 cycles

            S2: begin

                if (counter == 3'd4) begin
                    next_state   = S3;
                    next_counter = 3'd0;
                end
                else begin
                    next_counter = counter + 3'd1;
                end

            end


            // S3: A RED, B YELLOW
            // Duration = 2 cycles

            S3: begin

                if (counter == 3'd1) begin
                    next_state   = S0;
                    next_counter = 3'd0;
                end
                else begin
                    next_counter = counter + 3'd1;
                end

            end


            // Safety recovery

            default: begin
                next_state   = S0;
                next_counter = 3'd0;
            end

        endcase

    end


    // Moore output logic

    always_comb begin

        // Default all lights OFF
        A_green  = 1'b0;
        A_yellow = 1'b0;
        A_red    = 1'b0;

        B_green  = 1'b0;
        B_yellow = 1'b0;
        B_red    = 1'b0;

        case (state)

            S0: begin
                A_green = 1'b1;
                B_red   = 1'b1;
            end

            S1: begin
                A_yellow = 1'b1;
                B_red    = 1'b1;
            end

            S2: begin
                A_red   = 1'b1;
                B_green = 1'b1;
            end

            S3: begin
                A_red    = 1'b1;
                B_yellow = 1'b1;
            end

            default: begin
                A_red = 1'b1;
                B_red = 1'b1;
            end

        endcase

    end

endmodule
