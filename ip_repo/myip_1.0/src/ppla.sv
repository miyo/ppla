
module ppla
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

    logic [31:0] ctrl_dout_r;
    assign CTRL_DOUT = ctrl_dout_r;

    logic repeater_kick;
    logic repeater_busy;
    logic repeater_mode;
    logic [15:0] repeater_repetition;
    logic [15:0] repeater_post_margin;
    logic [31:0] spi_cnt_din;
    logic [7:0] spi_cnt_sclk_half_period;
    logic [7:0] spi_cnt_cs_delay;
    logic [7:0] spi_cnt_data_delay;
    logic [7:0] spi_cnt_miso_width;
    logic [7:0] spi_cnt_mosi_width;
    logic spi_cnt_cpol;
    logic spi_cnt_cpha;
    logic result_storage_addr_reset;

    always_ff @(posedge CLK) begin
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

    logic repeater_target_kick;
    logic repeater_target_busy;
    logic [31:0] spi_cnt_dout;
    logic spi_cnt_dout_valid;

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

endmodule // ppla

