// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary


`include "atcspi200_config.vh"
`include "atcspi200_const.vh"

module atcspi200_eilmif_ctrl (
	  eilm_resetn,
	  eilm_clk,
	  ahb2eilm_clken,
	  eilm_req,
	  eilm_web,
	  eilm_addr,
	  eilm_wait,
	  eilm_wdata,
	  eilm_rdata,
	  eilm_spi_busy,
	  eilm_spi_req,
	  eilm_rxf_rd_data,
	  eilm_rxf_rd,
	  eilm_addr_latched,
	  eilm_other_req,
	  eilm_spi_addr,
	  eilm_cmd_chg,
	  eilm_rxf_empty
);

input		eilm_resetn;
input		eilm_clk;
input		ahb2eilm_clken;
input		eilm_req;
input	[3:0]	eilm_web;
input	[21:2]	eilm_addr;
output	 	eilm_wait;
input	[31:0]	eilm_wdata;
output	[31:0]	eilm_rdata;

input		eilm_spi_busy;
output		eilm_spi_req;
input	[31:0]	eilm_rxf_rd_data;
output		eilm_rxf_rd;
input		eilm_addr_latched;
input		eilm_other_req;

output	[31:0]	eilm_spi_addr;
input		eilm_cmd_chg;
input		eilm_rxf_empty;


wire		eilm_txf_wr;

wire            eilm_req;
wire            eilm_cmd;
wire            eilm_rd_cmd;
wire            eilm_wr_cmd;
wire            eilm_addr_hit_spi;

wire            spi_w_trigger;
wire            spi_r_trigger;

reg [1:0]       eilm_cs_r, eilm_ns;
reg [2:0]       spi_cs_r, spi_ns;

wire            eilm_txf_wr_phase;
wire            eilm_rxf_rd_phase;

wire            eilm_rdone;
wire            eilm_wdone;

wire            spi_addr_set;
wire            spi_addr_add;
wire            spi_data_set;

reg  [21:2]     spi_cmd_addr_r;

wire            eilm_wait;
reg  [31:0]	eilm_rdata;

parameter	SPI_IDLE  = 3'h0,
		SPI_RDATA = 3'h1,
		SPI_RREAD = 3'h3,
		SPI_RHOLD = 3'h2,
		SPI_WDATA = 3'h4;

parameter	EILM_IDLE  = 2'h0,
		EILM_READ  = 2'h1,
		EILM_WRITE = 2'h2;


assign eilm_txf_wr_phase = eilm_txf_wr & ahb2eilm_clken;
assign eilm_rxf_rd_phase = eilm_rxf_rd & ahb2eilm_clken;

assign eilm_cmd		= eilm_req & (eilm_cs_r == EILM_IDLE);
assign eilm_rd_cmd	= eilm_cmd & (&eilm_web);
assign eilm_wr_cmd	= 1'b0;

assign eilm_addr_hit_spi = (eilm_addr[21:2] == spi_cmd_addr_r[21:2]) & (&eilm_web);

always @(*)
begin
	case(eilm_cs_r)
		EILM_READ: begin
			if (eilm_rdone)
				eilm_ns = EILM_IDLE;
			else
				eilm_ns = EILM_READ;
		end
		EILM_WRITE: begin
			if (eilm_wdone)
				eilm_ns = EILM_IDLE;
			else
				eilm_ns = EILM_WRITE;
		end
		default : begin
			if (eilm_rd_cmd)
				eilm_ns = EILM_READ;
			else if (eilm_wr_cmd)
				eilm_ns = EILM_WRITE;
			else
				eilm_ns = EILM_IDLE;
		end
	endcase
end

always @(negedge eilm_resetn or posedge eilm_clk)
begin
	if (~eilm_resetn)
		eilm_cs_r <= EILM_IDLE;
	else
		eilm_cs_r <= eilm_ns;
end

always @(negedge eilm_resetn or posedge eilm_clk)
begin
	if (~eilm_resetn)
		eilm_rdata <= 32'h0;
	else if (eilm_rxf_rd_phase)
		eilm_rdata <= eilm_rxf_rd_data;
end

assign eilm_wait  = (eilm_cs_r == EILM_READ) & ~((spi_cs_r == SPI_RDATA) & eilm_rxf_rd_phase) |
		(eilm_cs_r == EILM_WRITE) & ~((spi_cs_r == SPI_WDATA) & eilm_txf_wr_phase);

assign spi_w_trigger  = eilm_cs_r == EILM_WRITE;
assign spi_r_trigger  = eilm_cs_r == EILM_READ;

assign eilm_rxf_rd = ~eilm_rxf_empty & (spi_cs_r == SPI_RDATA);
assign eilm_txf_wr = 1'b0;

assign eilm_rdone = (spi_cs_r == SPI_RDATA) & eilm_rxf_rd_phase;
assign eilm_wdone = (spi_cs_r == SPI_WDATA) & eilm_txf_wr_phase;


always @(*)
begin
	spi_ns = spi_cs_r;
	case(spi_cs_r)
		SPI_WDATA: begin
			if (eilm_txf_wr_phase)
				spi_ns = SPI_IDLE;
		end
		SPI_RDATA: begin
			if (eilm_rxf_rd_phase) begin
				if (eilm_other_req | eilm_cmd_chg)
					spi_ns = SPI_IDLE;
				else
					spi_ns = SPI_RREAD;
			end
		end
		SPI_RREAD: begin
			if (spi_r_trigger & ahb2eilm_clken)
				spi_ns = SPI_RDATA;
			else if (spi_r_trigger & ~ahb2eilm_clken)
				spi_ns = SPI_RREAD;
			else if (eilm_rd_cmd & eilm_addr_hit_spi & ahb2eilm_clken)
				spi_ns = SPI_RDATA;
			else if (eilm_rd_cmd & eilm_addr_hit_spi & ~ahb2eilm_clken)
				spi_ns = SPI_RREAD;
			else if (eilm_rd_cmd & ~eilm_addr_hit_spi)
				spi_ns = SPI_IDLE;
			else if (eilm_other_req | eilm_cmd_chg | eilm_wr_cmd)
				spi_ns = SPI_IDLE;
			else if (ahb2eilm_clken)
				spi_ns = SPI_RHOLD;
		end
		SPI_RHOLD: begin
			if (eilm_rd_cmd & eilm_addr_hit_spi)
				spi_ns = SPI_RDATA;
			else if (eilm_rd_cmd & ~eilm_addr_hit_spi)
				spi_ns = SPI_IDLE;
			else if (eilm_other_req | eilm_cmd_chg | eilm_wr_cmd)
				spi_ns = SPI_IDLE;
		end
		default: begin
			if (~eilm_spi_busy) begin
				if (spi_w_trigger & ahb2eilm_clken)
					spi_ns = SPI_WDATA;
				else if (spi_r_trigger & ahb2eilm_clken)
					spi_ns = SPI_RDATA;
				else if (eilm_wr_cmd)
					spi_ns = SPI_WDATA;
				else if (eilm_rd_cmd)
					spi_ns = SPI_RDATA;
			end
		end
	endcase
end


always @(negedge eilm_resetn or posedge eilm_clk)
begin
	if (~eilm_resetn)
		spi_cs_r <= SPI_IDLE;
	else
		spi_cs_r <= spi_ns;
end

assign eilm_spi_req     = spi_cs_r != SPI_IDLE;
assign eilm_spi_addr    = {10'b0, spi_cmd_addr_r[21:2], 2'h0};

assign spi_addr_add = ((spi_cs_r == SPI_RDATA) & eilm_addr_latched & ahb2eilm_clken) | (((spi_cs_r == SPI_RHOLD) | (spi_cs_r == SPI_RREAD)) & (spi_ns == SPI_RDATA));
assign spi_addr_set = ( (spi_cs_r == SPI_IDLE)  & (eilm_cs_r == EILM_IDLE) & (eilm_wr_cmd |  eilm_rd_cmd)) |
(((spi_cs_r == SPI_RHOLD) | (spi_cs_r == SPI_RREAD)) & (eilm_wr_cmd | (eilm_rd_cmd & (~eilm_addr_hit_spi))));
assign spi_data_set = eilm_wr_cmd;

always @(negedge eilm_resetn or posedge eilm_clk)
begin
	if (~eilm_resetn)
		spi_cmd_addr_r	<= 20'h0;
	else if (spi_addr_set)
		spi_cmd_addr_r	<= eilm_addr[21:2];
	else if (spi_addr_add)
		spi_cmd_addr_r	<= spi_cmd_addr_r + 20'h1;
end

endmodule
