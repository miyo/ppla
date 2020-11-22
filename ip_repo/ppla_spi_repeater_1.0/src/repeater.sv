`timescale 1ns/1ps

module repeater
  (
   input wire CLK,
   input wire RESET,

   input wire KICK,
   output wire BUSY,
   input wire MODE, // '0': generate target_kick, '1': use external trigger for target_kick
   input wire EXT_TRIG,

   output wire TARGET_KICK,
   input wire TARGET_BUSY,
   input wire [15:0] REPETITION,
   input wire [15:0] POST_MARGIN
   );

    (* MARK_DEBUG="TRUE" *) logic target_kick_r;
    (* MARK_DEBUG="TRUE" *) logic busy_r;
    (* MARK_DEBUG="TRUE" *) logic kick_r;
    (* MARK_DEBUG="TRUE" *) logic ext_trig_r;
    (* MARK_DEBUG="TRUE" *) logic [15:0] repetition_r;
    (* MARK_DEBUG="TRUE" *) logic [15:0] post_margin_r;

    assign TARGET_KICK = target_kick_r;
    assign BUSY = busy_r;

    typedef enum {IDLE, EMIT_KICK, WAIT_TARGET, WAIT_NEXT} state_type;
    state_type state;

    (* MARK_DEBUG="TRUE" *) logic [15:0] repeat_counter;
    (* MARK_DEBUG="TRUE" *) logic [15:0] margin_counter;

    always_ff @(posedge CLK) begin
	if(RESET == 1) begin
	    state <= IDLE;
	    target_kick_r <= 0;
	    busy_r <= 0;
	    repetition_r <= 0;
	    post_margin_r <= 0;
	    repeat_counter <= 0;
	    margin_counter <= 0;
	    ext_trig_r <= 1;
	end else begin
	    kick_r <= KICK;
	    ext_trig_r <= EXT_TRIG;
	    case(state)
		IDLE: begin
		    if(kick_r == 0 && KICK == 1) begin
			state <= EMIT_KICK;
			busy_r <= 1;
		    end else begin
			busy_r <= 0;
		    end
		    target_kick_r <= 0;
		    repetition_r <= REPETITION > 0 ? REPETITION : 1;
		    post_margin_r <= POST_MARGIN;
		    repeat_counter <= 0;
		    margin_counter <= 0;
		end
		EMIT_KICK: begin
		    if(MODE == 0 && TARGET_BUSY == 0) begin
			target_kick_r <= 1;
			repeat_counter <= repeat_counter + 1;
			state <= WAIT_TARGET;
		    end else if(MODE == 1 && TARGET_BUSY == 0 && ext_trig_r == 0 && EXT_TRIG == 1) begin
			target_kick_r <= 1;
			repeat_counter <= repeat_counter + 1;
			state <= WAIT_TARGET;
		    end
		end
		WAIT_TARGET: begin
		    target_kick_r <= 0;
		    if(target_kick_r == 0 && TARGET_BUSY == 0) begin
			if(post_margin_r == 0) begin
			    if(repeat_counter == repetition_r) begin
				state <= IDLE;
			    end else begin
				state <= EMIT_KICK;
			    end
			end else begin
			    state <= WAIT_NEXT;
			end
		    end
		end
		WAIT_NEXT: begin
		    if(margin_counter + 1 == post_margin_r) begin
			margin_counter <= 0;
			if(repeat_counter == repetition_r) begin
			    state <= IDLE;
			end else begin
			    state <= EMIT_KICK;
			end
		    end else begin
			margin_counter <= margin_counter + 1;
		    end
		end
		default: begin
		    state <= IDLE;
		end
	    endcase
	end
    end

endmodule // repeater

    
