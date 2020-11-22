`default_nettype none
`timescale 1ns/1ps

module spi_controller_tb();

    logic CLK;
    logic RESET;

    logic KICK;
    logic BUSY;
    logic [63:0] DIN;
    logic [63:0] DOUT;

    logic [7:0] SCLK_HALF_PERIOD;
    logic [7:0] CS_DELAY;
    logic [7:0] DATA_DELAY;
    logic [7:0] MISO_WIDTH;
    logic [7:0] MOSI_WIDTH;

    logic CPOL; // '0': clock is positive, '1': clock is negative
    logic CPHA; // '0': sampling at 1st edge, '1': sampling at 2nd edge

    // SPI
    logic CS;
    logic SCLK;
    logic MOSI;
    logic MISO;

    initial begin
	CLK = 0;
    end

    always begin
	#5 CLK = ~CLK;
    end

    logic [31:0] counter = 0;

    always_ff @(posedge CLK) begin
	case(counter)
	    0: begin
		RESET <= 0;
		KICK <= 0;
		DIN <= 0;
		counter <= counter + 1;
		MISO <= 1;
		CPOL <= 0;
		CPHA <= 0;
	    end
	    10: begin
		RESET <= 1;
		counter <= counter + 1;
	    end
	    20: begin
		RESET <= 0;
		counter <= counter + 1;
	    end

	    100: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 5;
		CPOL <= 0;
		CPHA <= 0;
		CS_DELAY <= 1;
		DATA_DELAY <= 1;
		MISO_WIDTH <= 16;
		MOSI_WIDTH <= 16;
		DIN[63:48] <= 16'h94a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    101: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end

	    150: begin
		CPOL <= 1;
		counter <= counter + 1;
	    end

	    200: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 5;
		CPOL <= 1;
		CPHA <= 0;
		CS_DELAY <= 1;
		DATA_DELAY <= 1;
		MISO_WIDTH <= 16;
		MOSI_WIDTH <= 16;
		DIN[63:48] <= 16'h94a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    201: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end

	    250: begin
		CPOL <= 0;
		counter <= counter + 1;
	    end

	    300: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 5;
		CPOL <= 0;
		CPHA <= 1;
		CS_DELAY <= 1;
		DATA_DELAY <= 1;
		MISO_WIDTH <= 16;
		MOSI_WIDTH <= 16;
		DIN[63:48] <= 16'h94a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    301: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end

	    350: begin
		CPOL <= 1;
		counter <= counter + 1;
	    end

	    400: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 5;
		CPOL <= 1;
		CPHA <= 1;
		CS_DELAY <= 1;
		DATA_DELAY <= 1;
		MISO_WIDTH <= 16;
		MOSI_WIDTH <= 16;
		DIN[63:48] <= 16'h94a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    401: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end

	    450: begin
		CPOL <= 0;
		counter <= counter + 1;
	    end

	    500: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 2;
		CPOL <= 0;
		CPHA <= 0;
		CS_DELAY <= 0;
		DATA_DELAY <= 0;
		MISO_WIDTH <= 32;
		MOSI_WIDTH <= 32;
		DIN[63:48] <= 16'h94a594a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    501: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end

	    600: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 2;
		CPOL <= 0;
		CPHA <= 0;
		CS_DELAY <= 0;
		DATA_DELAY <= 10;
		MISO_WIDTH <= 32;
		MOSI_WIDTH <= 32;
		DIN[63:48] <= 16'h94a594a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    601: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end
	    
	    700: begin
		KICK <= 1;
		SCLK_HALF_PERIOD <= 2;
		CPOL <= 0;
		CPHA <= 0;
		CS_DELAY <= 10;
		DATA_DELAY <= 0;
		MISO_WIDTH <= 32;
		MOSI_WIDTH <= 32;
		DIN[63:48] <= 16'h94a594a5;
		DIN[47:0] <= 0;
		counter <= counter + 1;
	    end
	    701: begin
		KICK <= 0;
		if(KICK == 0 && BUSY == 0) begin
		    counter <= counter + 1;
		end
	    end

	    default: begin
		counter <= counter + 1;
	    end
	    
	endcase
    end


    spi_controller dut (.CLK(CLK),
			.RESET(RESET),

			.KICK(KICK),
			.BUSY(BUSY),
			.DIN(DIN),
			.DOUT(DOUT),

			.SCLK_HALF_PERIOD(SCLK_HALF_PERIOD),
			.CS_DELAY(CS_DELAY),
			.DATA_DELAY(DATA_DELAY),
			.MISO_WIDTH(MISO_WIDTH),
			.MOSI_WIDTH(MOSI_WIDTH),

			.CPOL(CPOL), // '0': clock is positive, '1': clock is negative
			.CPHA(CPHA), // '0': sampling at 1st edge, '1': sampling at 2nd edge

			// SPI
			.CS(CS),
			.SCLK(SCLK),
			.MOSI(MOSI),
			.MISO(MISO)
			);

endmodule // spi_controller_tb

`default_nettype wire
