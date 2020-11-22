
`timescale 1 ns / 1 ps

	module ppla_spi_repeater_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

	 input wire [31:0] CTRL_ADDR,
	 input wire [31:0] CTRL_DIN,
	 input wire [3:0] CTRL_WE,
	 input wire CTRL_EN,
	 output wire [31:0] CTRL_DOUT,

	 input wire [31:0] DATA_ADDR,
	 output wire [31:0] DATA_DOUT,
						  
	 output wire SPI_CS,
	 output wire SPI_SCLK,
	 output wire SPI_MOSI,
	 input wire SPI_MISO,
	 input wire EXT_TRIG
	);
// Instantiation of Axi Bus Interface S00_AXI
	ppla_spi_repeater_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ppla_spi_repeater_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);
	// Add user logic here

	// User logic ends
    ppla_spi_repeater_int ppla_spi_repeater_int_i(
						  .CLK(s00_axi_aclk),
						  .RESET(~s00_axi_aresetn),
						  .CTRL_ADDR({2'b00, CTRL_ADDR[31:2]}),
						  .CTRL_DIN(CTRL_DIN),
						  .CTRL_WE(CTRL_WE[0] & CTRL_EN),
						  .CTRL_DOUT(CTRL_DOUT),

						  .DATA_ADDR({2'b00, DATA_ADDR[31:2]}),
						  .DATA_DOUT(DATA_DOUT),
						  
						  .SPI_CS(SPI_CS),
						  .SPI_SCLK(SPI_SCLK),
						  .SPI_MOSI(SPI_MOSI),
						  .SPI_MISO(SPI_MISO),
						  .EXT_TRIG(EXT_TRIG));

	endmodule
