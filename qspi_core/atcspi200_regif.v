// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary

`include "atcspi200_config.vh"
`include "atcspi200_const.vh"

module atcspi200_regif (
`ifdef ATCSPI200_REG_AHB
	  regrstn,
	  regclk,
	  hsel_reg,
	  hwrite,
	  haddr,
	  htrans,
	  hreadyin,
	  hreadyout_reg,
	  hwdata,
	  hrdata_reg,
	  hresp_reg,
`endif
`ifdef ATCSPI200_REG_APB
	  psel,
	  penable,
	  pwrite,
	  paddr,
	  pwdata,
	  prdata,
`endif
	  reg_rdata,
	  reg_rd_a,
	  reg_wr_a,
	  reg_raddr,
	  reg_waddr,
	  reg_wdata
);

`ifdef ATCSPI200_REG_AHB
	input                regrstn;
	input                regclk;
	input                hsel_reg;
	input                hwrite;
	input  [6:2]	     haddr;
	input  [1:0]         htrans;
	input                hreadyin;
	output               hreadyout_reg;
	input  [31:0]        hwdata;
	output [31:0]        hrdata_reg;
	output [1:0]         hresp_reg;
`endif
`ifdef ATCSPI200_REG_APB
	input                psel;
	input                penable;
	input                pwrite;
	input  [31:0]        paddr;
	input  [31:0]        pwdata;
	output [31:0]        prdata;
`endif

input  [31:0]     reg_rdata;

output                       reg_rd_a;
output                       reg_wr_a;
output [6:2]                 reg_raddr;
output [6:2]                 reg_waddr;
output [31:0]     reg_wdata;




`ifdef ATCSPI200_REG_AHB
	wire                           reg_wr_a_pre;
	reg                            reg_wr_a_r;
	reg  [6:2]                     reg_addr_r;
	wire                           wr_rd_same;
	reg                           wr_rd_same_d1;
	reg                            hreadyout_r;

	always@(negedge regrstn or posedge regclk)
	begin
		if (~regrstn) begin
			reg_wr_a_r	<= 1'b0;
			wr_rd_same_d1	<= 1'b0;
		end
		else begin
			reg_wr_a_r	<= reg_wr_a_pre;
			wr_rd_same_d1	<= wr_rd_same;
		end
	end

	always @(negedge regrstn or posedge regclk)
	begin
		if (~regrstn)
			reg_addr_r	<= 5'h00;
		else if (reg_wr_a_pre | wr_rd_same)
			reg_addr_r	<= haddr[6:2];
	end

	assign reg_rd_a		= (hsel_reg & ((htrans == 2'b10) | (htrans == 2'b11)) & hreadyin & ~hwrite) | wr_rd_same_d1;
	assign reg_wr_a_pre	=  hsel_reg & ((htrans == 2'b10) | (htrans == 2'b11)) & hreadyin &  hwrite;
	assign reg_wr_a		= reg_wr_a_r;
	assign reg_wdata	= hwdata;

	assign reg_raddr	= wr_rd_same_d1 ? reg_addr_r : haddr[6:2];
	assign reg_waddr	= reg_addr_r;
	assign hrdata_reg	= reg_rdata;

	assign wr_rd_same	= reg_wr_a_r & reg_rd_a & ((reg_raddr == reg_waddr) | ((reg_raddr == 5'hd) & (reg_waddr == 5'h9)));
	assign hreadyout_reg	= ~wr_rd_same_d1;
	assign hresp_reg	= 2'h0;
`endif



`ifdef ATCSPI200_REG_APB
	assign reg_rd_a		= psel & !penable & !pwrite;
	assign reg_wr_a		= psel &  penable &  pwrite;
	assign reg_wdata	= pwdata;

	assign reg_raddr	= paddr[6:2];
	assign reg_waddr	= paddr[6:2];
	assign prdata		= reg_rdata;
`endif

endmodule
