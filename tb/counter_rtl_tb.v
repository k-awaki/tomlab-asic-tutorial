`timescale 1ns / 1ps

module counter_rtl_tb;

    parameter WIDTH = 8;
    
    reg              clk;
    reg              reset;
    wire [WIDTH-1:0] count;
    
    counter #(
        .WIDTH(WIDTH)
    ) inst_counter (
        .clk(clk),
        .reset(reset),
        .count(count)
    );
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        
        reset = 1'b1;
        
        #20;
        reset = 1'b0;
        
        #200;
        
        @(negedge clk);
        reset = 1'b1;
        
        @(negedge clk);
        reset = 1'b0;
        
        #50;
        $finish;
    end

endmodule
