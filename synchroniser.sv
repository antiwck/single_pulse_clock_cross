module synchroniser # (
    parameter                   WIDTH       = 4
) (
   input    logic               clk         ,
   input    logic               rst_n       ,
   input    logic [WIDTH-1:0]   d_in        ,
   output   logic [WIDTH-1:0]   d_out
);
   
   logic [WIDTH-1:0] ff1                            ;

   always_ff @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           ff1          	<= '0           ;
           d_out            <= '0           ;
       end else begin
           ff1          	<= d_in         ;
            `ifdef VERIFICATION
            for (int i = 0; i < WIDTH; i++) begin
                // Only corrupt if the bit is actively transitioning (d_in differs from previously locked ff1)
                if ((d_in[i] != ff1[i]) && ($urandom_range(0, 1) == 1)) begin
                    d_out[i] <= $urandom_range(0, 1); // Randomly capture wrong state during transition
                end else begin
                    d_out[i] <= ff1[i]       ; // Stable signal passes normally
                end
            end
            `else
                for (int i = 0; i < WIDTH; i++) begin
                    d_out[i] <= ff1[i]       ;
                end 
            `endif
       end
   end

endmodule

