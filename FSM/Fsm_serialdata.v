//Naive solution to this problem
module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
); 

    parameter start = 4'd0, stop =4'd9, idle = 4'd10;
   	parameter b1 = 4'd1, b2 = 4'd2, b3 = 4'd3;
    parameter b4 = 4'd4, b5 = 4'd5, b6 = 4'd6;
    parameter b7 = 4'd7, b8 = 4'd8, term = 4'd11;
    reg [8:0] out;
    reg [3:0] state, next_state;
    
    // Use FSM from Fsm_serial
    always @(*) begin
        case (state)
            idle: next_state = in? idle:start;
            start: next_state = b1;
            b1: next_state = b2;
            b2: next_state = b3;
            b3: next_state = b4;
            b4: next_state = b5;
            b5: next_state = b6;
            b6: next_state = b7;
            b7: next_state = b8;
            b8: next_state = in? stop:term;
            stop: next_state = in? idle:start;
            term: next_state = in? idle:term;
            default: next_state = idle;
        endcase
    end
    // New: Datapath to latch input bits.
    always @(posedge clk) begin
        if (reset)
            state = idle;
        else begin
            state <= next_state;
            out = {in, out[8:1]}; //output in reverse order
            out_byte = out[7:0];
        end
    end
    
    assign done = (state == stop);
    
endmodule
