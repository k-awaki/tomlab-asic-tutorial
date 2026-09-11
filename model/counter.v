module counter #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (reset) begin
            count <= {WIDTH{1'b0}};
        end else begin
            count <= count + 1'b1;
        end
    end

endmodule
