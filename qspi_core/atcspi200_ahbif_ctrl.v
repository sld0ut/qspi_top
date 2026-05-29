// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary

`include "atcspi200_config.vh"
`include "atcspi200_const.vh"

module atcspi200_ahbif_ctrl (
	  hresetn,
	  hclk,
	  hsel,
	  hwrite,
	  haddr,
	  htrans,
	  hreadyin,
	  hreadyout,
	  hrdata,
	  hresp,
	  ahb_spi_busy,
	  ahb_spi_req,
	  ahb_rxf_empty,
	  ahb_rxf_rd_data,
	  ahb_rxf_rd,
	  ahb_addr_latched,
	  ahb_other_req,
	  ahb_spi_addr,
	  ahb_cmd_chg
);

`ifdef ATCSPI200_ADDR_WIDTH_24
	parameter	AHB_SPI_ADDR_MSB = 23;
`else
	parameter	AHB_SPI_ADDR_MSB = 31;
`endif


input		hresetn;
input		hclk;
input		hsel;
input		hwrite;
input	[`ATCSPI200_HADDR_WIDTH-1:0]   haddr;
input	[1:0]	htrans;
input		hreadyin;
output		hreadyout;
output	[31:0]	hrdata;
output	[1:0]	hresp;

input		ahb_spi_busy;
output		ahb_spi_req;
input		ahb_rxf_empty;
input	[31:0]	ahb_rxf_rd_data;
output		ahb_rxf_rd;
input		ahb_addr_latched;
input		ahb_other_req;

output	[31:0]	ahb_spi_addr;
input		ahb_cmd_chg;


wire            ahb_sel;
wire            ahb_cmd;
wire            ahb_rd_cmd;
wire            ahb_wr_cmd;
wire            ahb_wr_cmd_err_resp;
wire            haddr_hit_spi;
wire		ahb_txf_wr;
wire	[31:0]	haddr_32b;

wire            p_split_hit;




wire            spi_w_trigger;
wire            spi_r_trigger;

reg [2:0]       ahb_cs_r, ahb_ns;
reg [2:0]       spi_cs_r, spi_ns;

wire            spi_write_cycle;
wire            spi_addr_set;
wire            spi_addr_add;
wire            spi_data_set;

reg  [AHB_SPI_ADDR_MSB:2]     spi_addr_r;

wire            hreadyout;
wire [31:0]     hrdata;
wire [1:0]      hresp;
parameter	SPI_IDLE  	= 3'h0,
		SPI_RDATA 	= 3'h1,
		SPI_RHOLD 	= 3'h3,
		SPI_WADDR 	= 3'h4,
		SPI_WDATA 	= 3'h5;

assign ahb_sel = hsel & ((htrans == 2'b10) | (htrans == 2'b11));

assign ahb_cmd    = ahb_sel & hreadyin;
assign ahb_rd_cmd = ahb_cmd & ~hwrite;
assign ahb_wr_cmd = 1'b0;
assign ahb_wr_cmd_err_resp = ahb_cmd & hwrite;
`ifdef ATCSPI200_ADDR_WIDTH_24
	assign haddr_32b = {8'b0, haddr};
`else
	assign haddr_32b = haddr;
`endif


assign haddr_hit_spi = (haddr_32b[AHB_SPI_ADDR_MSB:2] == spi_addr_r[AHB_SPI_ADDR_MSB:2]) & ~hwrite;
	assign p_split_hit = 1'b0;

















	parameter	AHB_IDLE  = 3'h0,
			AHB_READ  = 3'h1,
			AHB_ERR1  = 3'h2,
			AHB_ERR2  = 3'h3,
			AHB_WRITE = 3'h4,
			AHB_WW    = 3'h6,
			AHB_WR    = 3'h5;

	always@(*)
	begin
		case(ahb_cs_r)
			AHB_READ: begin
				if (ahb_rxf_rd) begin
					if (ahb_rd_cmd)
						ahb_ns = AHB_READ;
					else if (ahb_wr_cmd_err_resp)
						ahb_ns = AHB_ERR1;
					else
						ahb_ns = AHB_IDLE;
				end
				else
					ahb_ns = AHB_READ;
			end
			AHB_ERR1: begin
				ahb_ns = AHB_ERR2;
			end
			AHB_WRITE: begin
				if (spi_cs_r == SPI_WDATA) begin
					if (ahb_txf_wr) begin
						if (ahb_rd_cmd)
							ahb_ns = AHB_READ;
						else if (ahb_wr_cmd)
							ahb_ns = AHB_WRITE;
						else
							ahb_ns = AHB_IDLE;
					end
					else begin
						if (ahb_rd_cmd)
							ahb_ns = AHB_WR;
						else if (ahb_wr_cmd)
							ahb_ns = AHB_WW;
						else
							ahb_ns = AHB_WRITE;
					end
				end
				else
					ahb_ns = AHB_WRITE;
			end
			AHB_ERR2: begin
				ahb_ns = AHB_IDLE;
			end
			AHB_WW: begin
				if (ahb_txf_wr)
					ahb_ns = AHB_WRITE;
				else
					ahb_ns = AHB_WW;
			end
			AHB_WR: begin
				if (ahb_txf_wr)
					ahb_ns = AHB_READ;
				else
					ahb_ns = AHB_WR;
			end
			default : begin
				if (ahb_rd_cmd)
					ahb_ns = AHB_READ;
				else if (ahb_wr_cmd_err_resp)
					ahb_ns = AHB_ERR1;
				else
					ahb_ns = AHB_IDLE;
			end
		endcase
	end

	assign spi_w_trigger  = 1'b0;
	assign spi_r_trigger  = (ahb_cs_r == AHB_READ);



always@(negedge hresetn or posedge hclk)
begin
	if (~hresetn)
		ahb_cs_r <= AHB_IDLE;
	else
		ahb_cs_r <= ahb_ns;
end


	assign hreadyout = (ahb_cs_r == AHB_IDLE) | (ahb_cs_r == AHB_ERR2) | ((ahb_cs_r == AHB_READ) & ahb_rxf_rd);
	assign hrdata = ahb_rxf_rd_data;
	assign hresp = ((ahb_cs_r == AHB_ERR1) | (ahb_cs_r == AHB_ERR2)) ? 2'b01 : 2'b00;




always@(*)
begin
	spi_ns = spi_cs_r;
	case(spi_cs_r)
		SPI_WADDR: begin
			if (ahb_addr_latched)
				spi_ns = SPI_WDATA;
		end
		SPI_WDATA: begin
			if (ahb_txf_wr)
				spi_ns = SPI_IDLE;
		end
		SPI_RDATA: begin
			if (ahb_rxf_rd) begin
				if (ahb_rd_cmd & ~p_split_hit & haddr_hit_spi)
					spi_ns = SPI_RDATA;
				else if (ahb_rd_cmd & ~p_split_hit & ~haddr_hit_spi)
					spi_ns = SPI_IDLE;
				else if (ahb_other_req | ahb_cmd_chg | ahb_wr_cmd)
					spi_ns = SPI_IDLE;
				else
					spi_ns = SPI_RHOLD;
			end
		end
		SPI_RHOLD: begin
			if (ahb_rd_cmd & ~p_split_hit & haddr_hit_spi)
				spi_ns = SPI_RDATA;
			else if (ahb_rd_cmd & ~p_split_hit & ~haddr_hit_spi)
				spi_ns = SPI_IDLE;
			else if (ahb_other_req | ahb_cmd_chg | ahb_wr_cmd)
				spi_ns = SPI_IDLE;
		end
		default: begin
			if (~ahb_spi_busy) begin
				if (spi_w_trigger)
					spi_ns = SPI_WADDR;
				else if (spi_r_trigger)
					spi_ns = SPI_RDATA;
				else if (ahb_wr_cmd)
					spi_ns = SPI_WADDR;
				else if (ahb_rd_cmd)
					spi_ns = SPI_RDATA;
			end
		end
	endcase
end

always@(negedge hresetn or posedge hclk)
begin
	if (~hresetn)
		spi_cs_r <= SPI_IDLE;
	else
		spi_cs_r <= spi_ns;
end


assign spi_write_cycle = (spi_cs_r == SPI_WADDR) | (spi_cs_r == SPI_WDATA);
assign spi_addr_set = ((spi_cs_r == SPI_IDLE)  & (ahb_cs_r == AHB_IDLE)  & (ahb_wr_cmd | (ahb_rd_cmd & ~p_split_hit))) |
	((spi_cs_r == SPI_WDATA) & (ahb_cs_r == AHB_WRITE) & (ahb_wr_cmd | (ahb_rd_cmd))) |
	((spi_cs_r == SPI_RDATA) & (ahb_cs_r == AHB_READ)  & (ahb_wr_cmd | (ahb_rd_cmd & ~haddr_hit_spi))) |

((spi_cs_r == SPI_RHOLD)                                & (ahb_wr_cmd | (ahb_rd_cmd & ~p_split_hit & ~haddr_hit_spi)));

assign spi_addr_add = ((spi_cs_r == SPI_RDATA) & ahb_addr_latched) |
			((spi_cs_r == SPI_RDATA) & ahb_rxf_rd & ahb_rd_cmd & ~p_split_hit & haddr_hit_spi) |
			((spi_cs_r == SPI_RHOLD)              & ahb_rd_cmd & ~p_split_hit & haddr_hit_spi);


	assign spi_data_set = (spi_cs_r == SPI_WADDR) & ahb_addr_latched;


always@(negedge hresetn or posedge hclk)
begin
	if (~hresetn)
		spi_addr_r <= {(AHB_SPI_ADDR_MSB-1){1'b0}};
	else if (spi_addr_set)
		spi_addr_r <= haddr_32b[AHB_SPI_ADDR_MSB:2];
	else if (spi_addr_add)
		spi_addr_r <= spi_addr_r + {{(AHB_SPI_ADDR_MSB-2){1'b0}}, 1'b1};
end

`ifdef ATCSPI200_ADDR_WIDTH_24
	assign ahb_spi_addr = {8'b0, spi_addr_r[AHB_SPI_ADDR_MSB:2], 2'b0};
`else
	assign ahb_spi_addr = {spi_addr_r[AHB_SPI_ADDR_MSB:2], 2'b0};
`endif


assign ahb_spi_req = spi_cs_r != SPI_IDLE;
assign ahb_txf_wr = 1'b0;
	assign ahb_rxf_rd = (ahb_cs_r == AHB_READ) & !ahb_rxf_empty & (spi_cs_r == SPI_RDATA);


endmodule
