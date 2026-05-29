// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary

`include "atcspi200_config.vh"
`include "atcspi200_const.vh"

module atcspi200_regif_ctrl (
`ifdef ATCSPI200_SLAVE_SUPPORT
	  spi_master,
`endif
	  reg_txf_data_num,
	  reg_data_merge,
	  reg_txf_wr_regclk,
	  reg_trans_end_regclk,
	  regrstn,
	  regclk,
	  spi_reset_regclk,
	  reg_spi_tramode,
	  reg_txf_full,
	  reg_rxf_empty,
	  reg_tx_dma_en,
	  reg_rx_dma_en,
	  spi_tx_dma_req,
	  spi_rx_dma_req,
	  spi_tx_dma_ack,
	  spi_rx_dma_ack
);

`ifdef ATCSPI200_SLAVE_SUPPORT
input		spi_master;
`endif

//input	[8:0]	reg_txf_data_num;
input	[15:0]	reg_txf_data_num;
input		reg_data_merge;
input		reg_txf_wr_regclk;
input		reg_trans_end_regclk;

input		regrstn;
input		regclk;
input		spi_reset_regclk;
input	[3:0]	reg_spi_tramode;

input		reg_txf_full;
input		reg_rxf_empty;

input		reg_tx_dma_en;
input		reg_rx_dma_en;
output		spi_tx_dma_req;
output		spi_rx_dma_req;
input		spi_tx_dma_ack;
input		spi_rx_dma_ack;

`ifdef ATCSPI200_SLAVE_SUPPORT
`else
	wire	spi_master = 1'b1;
`endif
wire		tx_mode;
//reg	[9:0]	transfered_num;
reg	[15:0]	transfered_num; //bruce
wire		tx_dma_need_data;

reg		spi_tx_dma_req_r;
reg		spi_rx_dma_req_r;


assign tx_mode = (reg_spi_tramode == 4'h0) | (reg_spi_tramode == 4'h1) | (reg_spi_tramode == 4'h3) | (reg_spi_tramode == 4'h4) | (reg_spi_tramode == 4'h5) | (reg_spi_tramode == 4'h6) | (reg_spi_tramode == 4'h8);


/*
always @(negedge regrstn or posedge regclk)
begin
	if (~regrstn)
		transfered_num <= 10'b0;
	else if (spi_reset_regclk | reg_trans_end_regclk)
		transfered_num <= 10'b0;
	else if (reg_txf_wr_regclk)
		transfered_num <= transfered_num + (reg_data_merge ? 10'h4 : 10'h1);
end

assign tx_dma_need_data = ~reg_txf_full & (spi_master ? ((transfered_num <= {1'b0, reg_txf_data_num}) & tx_mode) : 1'b1);
*/

//bruce
always @(negedge regrstn or posedge regclk)
begin
	if (~regrstn)
		transfered_num <= 16'b0;
	else if (spi_reset_regclk | reg_trans_end_regclk)
		transfered_num <= 16'b0;
	else if (reg_txf_wr_regclk)
		transfered_num <= transfered_num + (reg_data_merge ? 10'h4 : 10'h1);
end

assign tx_dma_need_data = ~reg_txf_full & (spi_master ? ((transfered_num <= reg_txf_data_num ) & tx_mode) : 1'b1);


always @(negedge regrstn or posedge regclk)
begin
	if (~regrstn)
		spi_tx_dma_req_r <= 1'b0;
	else if (spi_reset_regclk)
		spi_tx_dma_req_r <= 1'b0;
	else if (spi_tx_dma_ack)
		spi_tx_dma_req_r <= 1'b0;
	else if (reg_tx_dma_en & tx_dma_need_data & ~reg_txf_full)
		spi_tx_dma_req_r <= 1'b1;
end

always @(negedge regrstn or posedge regclk)
begin
	if (~regrstn)
		spi_rx_dma_req_r <= 1'b0;
	else if (spi_reset_regclk)
		spi_rx_dma_req_r <= 1'b0;
	else if (spi_rx_dma_req_r)
		spi_rx_dma_req_r <= reg_rx_dma_en & ~spi_rx_dma_ack;
	else
		spi_rx_dma_req_r <= reg_rx_dma_en & ~spi_rx_dma_ack & ~reg_rxf_empty;
end

assign spi_tx_dma_req = spi_tx_dma_req_r;
assign spi_rx_dma_req = spi_rx_dma_req_r;

endmodule
