`timescale 1ns/1ps

module result_storage
  (
   input wire CLK,
   input wire RESET,

   input wire ADDR_RESET,
   input wire [31:0] DIN,
   input wire DIN_WE,

   input wire [31:0] READ_ADDR,
   output wire [31:0] READ_DOUT
   );

    logic [31:0] addr_r;

    always_ff @(posedge CLK) begin
	if(RESET == 1) begin
	    addr_r <= 0;
	end else if(ADDR_RESET == 1) begin
	    addr_r <= 0;
	end else if(DIN_WE == 1) begin
	    addr_r <= addr_r + 1;
	end
    end

    /* verilator lint_off PINCONNECTEMPTY */
    dualportram #(.DEPTH(13),.WIDTH(32),.WORDS(8192))
    dualportram_i(
		  .clk(CLK),
		  .reset(RESET),
		  .we(DIN_WE),
		  .oe(1),
		  .address(addr_r),
		  .din(DIN),
		  .dout(),
     
		  .we_b(0),
		  .oe_b(1),
		  .address_b(READ_ADDR),
		  .din_b(0),
		  .dout_b(READ_DOUT),
		  .length());

endmodule // result_storage

