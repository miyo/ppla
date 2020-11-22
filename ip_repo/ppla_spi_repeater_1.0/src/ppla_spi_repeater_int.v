
module ppla_spi_repeater_int
  (
   input wire CLK,
   input wire RESET,

   input  wire [31:0] CTRL_ADDR,
   input  wire [31:0] CTRL_DIN,
   input  wire CTRL_WE,
   output wire [31:0] CTRL_DOUT,

   input  wire [31:0] DATA_ADDR,
   output wire [31:0] DATA_DOUT,

   output wire SPI_CS,
   output wire SPI_SCLK,
   output wire SPI_MOSI,
   input  wire SPI_MISO,
   input  wire EXT_TRIG
   );

    (* MARK_DEBUG="TRUE" *) reg [31:0] ctrl_addr_r;
    (* MARK_DEBUG="TRUE" *) reg [31:0] ctrl_din_r;
    (* MARK_DEBUG="TRUE" *) reg ctrl_we_r;
    (* MARK_DEBUG="TRUE" *) reg [31:0] ctrl_dout_r;

    (* MARK_DEBUG="TRUE" *) reg [31:0] data_addr_r;
    (* MARK_DEBUG="TRUE" *) reg [31:0] data_dout_r;

    assign CTRL_DOUT = ctrl_dout_r;

    always @(posedge CLK) begin
	ctrl_addr_r <= CTRL_ADDR;
	ctrl_din_r <= CTRL_DIN;
	ctrl_we_r <= CTRL_WE;
	data_addr_r <= DATA_ADDR;
	data_dout_r <= DATA_DOUT;
    end

    reg repeater_kick;
    wire repeater_busy;
    reg repeater_mode;
    reg [15:0] repeater_repetition;
    reg [15:0] repeater_post_margin;
    reg [31:0] spi_cnt_din;
    reg [7:0] spi_cnt_sclk_half_period;
    reg [7:0] spi_cnt_cs_delay;
    reg [7:0] spi_cnt_data_delay;
    reg [7:0] spi_cnt_miso_width;
    reg [7:0] spi_cnt_mosi_width;
    reg spi_cnt_cpol;
    reg spi_cnt_cpha;
    reg result_storage_addr_reset;

    always @(posedge CLK) begin
	case(CTRL_ADDR)
	    0: ctrl_dout_r <= {repeater_busy, 29'd0, repeater_mode, repeater_kick};
	    1: ctrl_dout_r <= {repeater_repetition, repeater_post_margin};
	    2: ctrl_dout_r <= spi_cnt_din;
	    3: ctrl_dout_r <= {24'd0, spi_cnt_sclk_half_period};
	    4: ctrl_dout_r <= {24'd0, spi_cnt_cs_delay};
	    5: ctrl_dout_r <= {24'd0, spi_cnt_data_delay};
	    6: ctrl_dout_r <= {24'd0, spi_cnt_miso_width};
	    7: ctrl_dout_r <= {24'd0, spi_cnt_mosi_width};
	    8: ctrl_dout_r <= {30'd0, spi_cnt_cpha, spi_cnt_cpol};
	    default: ctrl_dout_r <= 0;
	endcase // case (CTRL_ADDR)

	if(CTRL_WE == 1) begin
	  case(CTRL_ADDR)
	      0: begin
		  repeater_mode <= CTRL_DIN[2];
		  result_storage_addr_reset <= CTRL_DIN[0];
		  repeater_kick <= CTRL_DIN[0];
	      end
	      1: begin
		  repeater_repetition <= CTRL_DIN[31:16];
		  repeater_post_margin <= CTRL_DIN[15:0];
	      end
	      2: spi_cnt_din <= CTRL_DIN;
	      3: spi_cnt_sclk_half_period <= CTRL_DIN[7:0];
	      4: spi_cnt_cs_delay <= CTRL_DIN[7:0];
	      5: spi_cnt_data_delay <= CTRL_DIN[7:0];
	      6: spi_cnt_miso_width <= CTRL_DIN[7:0];
	      7: spi_cnt_mosi_width <= CTRL_DIN[7:0];
	      8: begin
		  spi_cnt_cpha <= CTRL_DIN[1];
		  spi_cnt_cpol <= CTRL_DIN[0];
	      end
	  endcase // case (CTRL_ADDR)
	end else begin
	  if(result_storage_addr_reset == 1) begin
	      result_storage_addr_reset <= 0;
	  end
	    if(repeater_kick == 1) begin
		repeater_kick <= 0;
	    end
	end

    end

    wire repeater_target_kick;
    wire repeater_target_busy;
    wire [31:0] spi_cnt_dout;
    wire spi_cnt_dout_valid;

    repeater repeater_i(.CLK(CLK),
			.RESET(RESET),
			.KICK(repeater_kick),
			.BUSY(repeater_busy),
			.MODE(repeater_mode),
			.EXT_TRIG(EXT_TRIG),
			.TARGET_KICK(repeater_target_kick),
			.TARGET_BUSY(repeater_target_busy),
			.REPETITION(repeater_repetition),
			.POST_MARGIN(repeater_post_margin));

    result_storage result_storage_i(.CLK(CLK),
				    .RESET(RESET),
				    .ADDR_RESET(result_storage_addr_reset),
				    .DIN(spi_cnt_dout),
				    .DIN_WE(spi_cnt_dout_valid),
				    .READ_ADDR(DATA_ADDR),
				    .READ_DOUT(DATA_DOUT));

    spi_controller spi_controller_i(.CLK(CLK),
				    .RESET(RESET),
				    .KICK(repeater_target_kick),
				    .BUSY(repeater_target_busy),
				    .DIN(spi_cnt_din),
				    .DOUT(spi_cnt_dout),
				    .DOUT_VALID(spi_cnt_dout_valid),
				    .SCLK_HALF_PERIOD(spi_cnt_sclk_half_period),
				    .CS_DELAY(spi_cnt_cs_delay),
				    .DATA_DELAY(spi_cnt_data_delay),
				    .MISO_WIDTH(spi_cnt_miso_width),
				    .MOSI_WIDTH(spi_cnt_mosi_width),
				    .CPOL(spi_cnt_cpol),
				    .CPHA(spi_cnt_cpha),
				    .CS(SPI_CS),
				    .SCLK(SPI_SCLK),
				    .MOSI(SPI_MOSI),
				    .MISO(SPI_MISO));

    (* MARK_DEBUG="TRUE" *) reg SPI_CS_r;
    (* MARK_DEBUG="TRUE" *) reg SPI_SCLK_r;
    (* MARK_DEBUG="TRUE" *) reg SPI_MOSI_r;
    (* MARK_DEBUG="TRUE" *) reg SPI_MISO_r;

    always @(posedge CLK) begin
	SPI_CS_r <= SPI_CS;
	SPI_SCLK_r <= SPI_SCLK;
	SPI_MOSI_r <= SPI_MOSI;
	SPI_MISO_r <= SPI_MISO;
    end

endmodule // ppla

