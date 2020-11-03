`default_nettype none
`timescale 1ns/1ps

module spi_controller
  (
   input wire CLK,
   input wire RESET,

   input  wire KICK,
   output wire BUSY,
   input  wire [63:0] DIN,
   output wire [63:0] DOUT,

   input wire [7:0] SCLK_HALF_PERIOD,
   input wire [7:0] CS_DELAY,
   input wire [7:0] DATA_DELAY,
   input wire [7:0] MISO_WIDTH,
   input wire [7:0] MOSI_WIDTH,

   input wire CPOL, // '0': clock is positive, '1': clock is negative
   input wire CPHA, // '0': sampling at 1st edge, '1': sampling at 2nd edge

   // SPI
   output wire CS,
   output wire SCLK,
   output wire MOSI,
   input  wire MISO
   );

    logic cs_r;
    logic sclk_r;
    logic mosi_r;
    logic busy_r;
    logic [63:0] dout_r;
    logic cpol_r;
    logic cpha_r;

    assign CS = cs_r;
    assign SCLK = (cpol_r == 0) ? sclk_r : ~sclk_r;
    assign MOSI = mosi_r;
    assign BUSY = busy_r;
    assign DOUT = dout_r;

    typedef enum {IDLE, PRE_CS, PRE_DATA, SEND_MOSI, RECV_MISO, POST_DATA, POST_CS} state_type;

    state_type state;
    logic [7:0] state_counter;
    
    logic kick_r;
    logic [62:0] din_r;
    logic [7:0] sclk_half_period_r;
    logic [7:0] cs_delay_r;
    logic [7:0] data_delay_r;
    logic [7:0] miso_width_r;
    logic [7:0] mosi_width_r;
    logic [8:0] sclk_counter;
    
    always_ff @(posedge CLK) begin
	if (RESET == 1) begin
	    state  <= IDLE;
	    kick_r <= 1;
	    busy_r <= 0;
	    cs_r   <= 1;
	    mosi_r <= 0;
	    sclk_r <= 0;
	    state_counter <= 0;
	    sclk_counter <= 0;
	    dout_r <= 0;
	    cpol_r <= 0;
	    cpha_r <= 0;
	end else begin
	    kick_r <= KICK;
	    case(state)
		IDLE: begin
		    if(kick_r == 1'b0 && KICK == 1'b1) begin
			busy_r <= 1;
			dout_r <= 0;
			if(CS_DELAY == 0) begin
			    cs_r <= 0;
			    if(DATA_DELAY == 0) begin
				state <= SEND_MOSI;
			    end else begin
				state <= PRE_DATA;
			    end
			end else begin
			    cs_r <= 1;
			    state <= PRE_CS;
			end
		    end else begin
			busy_r <= 0;
			cs_r <= 1;
		    end
		    state_counter <= 0;
		    din_r <= DIN[62:0];
		    sclk_half_period_r <= SCLK_HALF_PERIOD > 0 ? SCLK_HALF_PERIOD : 1;
		    cs_delay_r <= CS_DELAY;
		    data_delay_r <= DATA_DELAY;
		    mosi_width_r <= MOSI_WIDTH;
		    miso_width_r <= MISO_WIDTH;
		    cpol_r <= CPOL;
		    cpha_r <= CPHA;
		    sclk_r <= 0;
		    mosi_r <= DIN[63];
		    sclk_counter <= 0;
		end

		PRE_CS: begin
		    if (state_counter + 8'd1 == cs_delay_r) begin
			state_counter <= 0;
			cs_r <= 0;
			if(data_delay_r == 0) begin
			    state <= SEND_MOSI;
			end else begin
			    state <= PRE_DATA;
			end
		    end else begin
			state_counter <= state_counter + 1;
		    end
		end

		PRE_DATA: begin
		    if (state_counter + 1 == data_delay_r) begin
			state_counter <= 0;
			state <= SEND_MOSI;
		    end else begin
			state_counter <= state_counter + 1;
		    end
		end

		SEND_MOSI: begin
		    if(sclk_half_period_r == state_counter + 1) begin
			sclk_r <= ~sclk_r;
			state_counter <= 0;
			if(cpha_r == 0 && sclk_counter[0] == 1) begin
			    din_r <= {din_r[61:0], 1'b0};
			    mosi_r <= din_r[62];
			end else if (cpha_r == 1 && sclk_counter[0] == 0 && sclk_counter > 1) begin
			    din_r <= {din_r[61:0], 1'b0};
			    mosi_r <= din_r[62];
			end
			if(sclk_counter + 1 == {mosi_width_r, 1'b0}) begin
			    state <= RECV_MISO;
			    sclk_counter <= 0;
			end else begin
			    sclk_counter <= sclk_counter + 1;
			end
		    end else begin
			state_counter <= state_counter + 1;
		    end
		end

		RECV_MISO: begin
		    if(sclk_half_period_r == state_counter + 1) begin
			sclk_r <= ~sclk_r;
			state_counter <= 0;

			if(cpha_r == 0 && sclk_counter[0] == 0) begin
			    dout_r <= {dout_r[62:0], MISO};
			end else if (cpha_r == 1 && sclk_counter[0] == 1) begin
			    dout_r <= {dout_r[62:0], MISO};
			end

			if(sclk_counter + 1 == {miso_width_r, 1'b0}) begin
			    sclk_counter <= 0;
			    if(data_delay_r == 0) begin
				if(cs_delay_r == 0) begin
				    state <= IDLE;
				    cs_r <= 1;
				end else begin
				    state <= POST_CS;
				end
			    end else begin
				state <= POST_DATA;
			    end
			end else begin
			    sclk_counter <= sclk_counter + 1;
			end
		    end else begin
			state_counter <= state_counter + 1;
		    end
		end

		POST_DATA: begin
		    if (state_counter + 1 == data_delay_r) begin
			state_counter <= 0;
			cs_r <= 1;
			if(cs_delay_r == 0) begin
			    state <= IDLE;
			end else begin
			    state <= POST_CS;
			end
		    end else begin
			state_counter <= state_counter + 1;
		    end
		end

		POST_CS: begin
		    if (state_counter + 1 == cs_delay_r) begin
			state_counter <= 0;
			state <= IDLE;
		    end else begin
			state_counter <= state_counter + 1;
		    end
		end
		
		default: begin
		    state <= IDLE;
		end
	    endcase
	end
    end

endmodule // spi_controller

`default_nettype wire
