module single_pulse_clock_cross_tb;

    logic clk_a                 ;
    logic rst_a_n               ;
    logic a                     ;

    logic clk_b                 ;
    logic rst_b_n               ;
    logic b                     ;

    logic idle                  ;
    logic busy                  ;

    // Instantiate the DUT
    single_pulse_clock_cross single_pulse_clock_cross_inst (
        .clk_a                  (clk_a          ),
        .rst_a_n                (rst_a_n        ),
        .a                      (a              ),
        .clk_b                  (clk_b          ),
        .rst_b_n                (rst_b_n        ),
        .b                      (b              ),
        .idle                   (idle           ),
        .busy                   (busy           )
    );

    initial begin
        clk_a = 0;
        forever #5 clk_a = !clk_a;
    end
    
    initial begin
        clk_b = 0;
        forever #17.6 clk_b = !clk_b;
    end

    int b_pulse_count = 0;

    always_ff @(posedge clk_b or negedge rst_b_n) begin
        if (!rst_b_n) begin
            b_pulse_count <= 0;
        end else if (b) begin
            b_pulse_count <= b_pulse_count + 1;
        end
    end

    int loop = 100;

    // Reset and stimulus generation
    initial begin
        rst_a_n = 0;
        rst_b_n = 0;
        a = 0;
        
        #40;
        rst_a_n = 1;
        rst_b_n = 1;

        #40;
        @(posedge clk_a); // Align to the clock edge before starting stimulus

        repeat (loop) begin
            // Wait until not busy
            while (busy) begin
                a <= 0;
                @(posedge clk_a);
            end

            // Random idle cycles before next pulse
            repeat ($urandom_range(0,2)) begin
                a <= 0;
                @(posedge clk_a);
            end

            // Wait until not busy again (in case it became busy during idle)
            while (busy) begin
                a <= 0;
                @(posedge clk_a);
            end

            // Generate 1-cycle synchronous pulse
            a <= 1'b1;
            @(posedge clk_a);

            // Deassert pulse
            a <= 1'b0;
        end

        #1000;
        $display("Total 'a' pulses sent: $d", loop);
        $display("Total 'b' pulses received: %0d", b_pulse_count);
        $finish;
    end

endmodule