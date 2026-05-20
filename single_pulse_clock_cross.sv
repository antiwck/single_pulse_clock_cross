module single_pulse_clock_cross #(
    parameter           COUNTER_WIDTH   = 3                         
) (
    input   logic       clk_a                                       ,
    input   logic       rst_a_n                                     ,
    input   logic       a                                           ,

    input   logic       clk_b                                       ,
    input   logic       rst_b_n                                     ,
    output  logic       b                                           ,

    output  logic       idle                                        ,
    output  logic       busy                                        
);

    logic [COUNTER_WIDTH:0]     pointer_a_bin           ;
    logic [COUNTER_WIDTH:0]     pointer_a_bin_next      ;
    logic [COUNTER_WIDTH:0]     pointer_a_gray          ;
    logic [COUNTER_WIDTH:0]     pointer_a_gray_next     ;
    logic [COUNTER_WIDTH:0]     pointer_a_gray_sync     ;

    logic [COUNTER_WIDTH:0]     pointer_b_bin           ;
    logic [COUNTER_WIDTH:0]     pointer_b_bin_next      ;
    logic [COUNTER_WIDTH:0]     pointer_b_gray          ;
    logic [COUNTER_WIDTH:0]     pointer_b_gray_next     ;
    logic [COUNTER_WIDTH:0]     pointer_b_gray_sync     ;

    assign pointer_a_bin_next   = pointer_a_bin + a                                 ;
    assign pointer_a_gray_next  = (pointer_a_bin_next >> 1) ^ pointer_a_bin_next    ;
    assign busy                 = (pointer_a_gray_next == {~pointer_b_gray_sync[COUNTER_WIDTH:COUNTER_WIDTH-1], pointer_b_gray_sync[COUNTER_WIDTH-2:0]});

    always_ff @(posedge clk_a or negedge rst_a_n) begin
        if (!rst_a_n) begin
            pointer_a_bin       <= '0                                               ;
            pointer_a_gray      <= '0                                               ;
        end else begin  
            pointer_a_bin       <= pointer_a_bin_next                               ;
            pointer_a_gray      <= pointer_a_gray_next                              ;
        end
    end

    assign pointer_b_bin_next   = (pointer_b_bin + (pointer_a_gray_sync != pointer_b_gray))   ;
    assign pointer_b_gray_next  = (pointer_b_bin_next >> 1) ^ pointer_b_bin_next        ;
    assign idle                 = (pointer_a_gray_next != {~pointer_b_gray_sync[COUNTER_WIDTH:COUNTER_WIDTH-1], pointer_b_gray_sync[COUNTER_WIDTH-2:0]});

    assign b                    = (pointer_a_gray_sync != pointer_b_gray)               ;

    always_ff @(posedge clk_b or negedge rst_b_n) begin
        if (!rst_b_n) begin
            pointer_b_bin       <= '0                                               ;
            pointer_b_gray      <= '0                                               ;
        end else begin                       
            pointer_b_bin       <= pointer_b_bin_next                               ;
            pointer_b_gray      <= pointer_b_gray_next                              ;
        end
    end

    synchroniser #(
        .WIDTH                  (COUNTER_WIDTH+1        )
    ) synchroniser_pointer_a_inst (
        .clk                    (clk_b                  ),
        .rst_n                  (rst_b_n                ),
        .d_in                   (pointer_a_gray         ),
        .d_out                  (pointer_a_gray_sync    )
    );

    synchroniser #(
        .WIDTH                  (COUNTER_WIDTH+1        )
    ) synchroniser_pointer_b_inst (
        .clk                    (clk_a                  ),
        .rst_n                  (rst_a_n                ),
        .d_in                   (pointer_b_gray         ),
        .d_out                  (pointer_b_gray_sync    )
    );

endmodule