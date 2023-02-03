//Jiawei Liu unemployeed
//02/02/2023


module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
); //
	
    reg [2:0] state, next_state;
    reg odd_check, final_odd_check;
    reg [3:0] count, count_c;
    parameter idle = 3'd0, start = 3'd1;
    parameter data = 3'd2, parity = 3'd3;
    parameter stop = 3'd4, waiting = 3'd5; 
    // Modify FSM and datapath from Fsm_serialdata
    always @(*) begin 
        //count down
        count_c = count - 1'b1;
        case(state)
            idle: next_state = in? idle:start;
            start: begin 
                next_state = data;
                count_c = 4'd7;
            end
            data: begin
                if (count == 4'd0) 
                    next_state = parity;
                else 
                    next_state = data;
            end
            parity: next_state = in? stop:waiting;
            waiting: next_state = in? stop:waiting;
            stop: next_state = in? idle:start;
        endcase
    end
    
    always @(posedge clk) begin
        if (reset)
            state <= idle;
        else begin
            state <= next_state;
            count <= count_c;            
        end
    end
    
    always @(posedge clk) begin
        if (next_state == data)
            out_byte[7-count_c] = in; 
        if (state == parity)
            final_odd_check = odd_check;
        if (state == waiting)     //discard the byte without stop bit by doing something fishy to the odd bit
            final_odd_check = 1'b0;
    end
    
    // New: Add parity checking.
    parity par(.clk(clk), .in(in), .reset((next_state == start)), .odd(odd_check));
    assign done = ((state == stop) && (final_odd_check == 1'b1));
endmodule
