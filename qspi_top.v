////////////////////////////////////////////////////////
//
//  Module: qspi_top
//  Project: MCUP
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////
`timescale 1ns/10ps

module qspi_top (
	//PAD
	input wire				QSPI_SS_IN_N	,
	output wire				QSPI_SS_OUT_N	,
	output wire				QSPI_SS_OUT_N_OE,
	input wire				QSPI_SCK_IN		,
	output wire				QSPI_SCK_OUT	,
	output wire				QSPI_SCK_OUT_EN	,
	input wire [3:0]		QSPI_IO_IN		,
	output wire [3:0]		QSPI_IO_OUT_EN	,
	output wire [3:0]		QSPI_IO_OUT		,
	//
	input   wire			SPI_DEF_SLAVE	,
	input   wire			SPI_DEF_MODE	,
	input   wire			SPI_FBCLK_SEL	,
	input   wire			SPI_FBSSN_SEL	,
	input   wire [3:0]		SPI_DMA_ACK_DLY	,
	input   wire			SCLK	 		,
	input	wire			RX_DMA_ACK		,
	input	wire			TX_DMA_ACK		,
	output	wire			RX_DMA_REQ		,
	output	wire			TX_DMA_REQ		,
	output	wire			INTR			,
	//
	input	wire			TEST_CLK		,
	input	wire			TEST_RESET		,
	input	wire			TE				,
	input	wire			SE				,
	input	wire			CKE_IP			,
	input	wire			RESET_IP		,
	input	wire			HCLK_CG_EN		,
	//
	input   wire			HCLK     		,
	input   wire			HRESETN 		,
	input   wire          	SHSEL     		,
	input   wire    [31:0]	SHADDR    		,
	input   wire          	SHWRITE   		,
	input   wire    [ 1:0]	SHTRANS   		,
	input   wire    [ 2:0]	SHSIZE    		,
	input   wire    [ 2:0]	SHBURST   		,
	input   wire    [31:0]	SHWDATA   		,
	input   wire          	SHREADY   		,
	output  wire          	SHREADYOUT		,
	output  wire    [ 1:0]	SHRESP    		,
	output  wire    [31:0]	SHRDATA   		
);
//-------------------------------------------------------------------------
// Reset & Clock Control
//-------------------------------------------------------------------------
wire	w_hresetn;
wire	w_sresetn;
wire	HCLKG;
wire	SCLKG;
reg		en_clk_spi;

assign  w_hresetn = HRESETN 	& (TE|RESET_IP);
assign  w_sresetn = HRESETN 	& (TE|RESET_IP);

always @(negedge w_hresetn or posedge SCLK)
	if (~w_hresetn)
		en_clk_spi <= 0;
	else
		en_clk_spi <= CKE_IP;

CLK_GATE I_CG_HCLK (.EN(CKE_IP),	.TE(SE), .ICLK(HCLK), .OCLK(HCLKG));
CLK_GATE I_CG_SCLK (.EN(en_clk_spi),.TE(SE), .ICLK(SCLK), .OCLK(SCLKG));

wire	hclk_cg;
hclk_cg u_HCLK_CG (
/*input wire	*/	.SE				(SE			),
/*input wire	*/	.HCLK			(HCLKG		),
/*input wire	*/	.HRESET_N		(w_hresetn	),
/*input wire	*/	.HSEL			(SHSEL		),
/*input wire	*/	.HCLK_CG_EN		(HCLK_CG_EN	),
/*output wire	*/	.HCLK_CG		(hclk_cg	)
);

wire		w_QSPI_SCK_OUT;
CLK_CTS	u_QSPI_SCK_OUT (.A(w_QSPI_SCK_OUT), .Y(QSPI_SCK_OUT));

wire [2:0]	w_QSPI_SCK_IN;
CLK_MUX I_TMUX_QSPI_SCK_FB_0 (.A(QSPI_SCK_IN), 		.B(QSPI_SCK_OUT),	.S(SPI_FBCLK_SEL),	.Y(w_QSPI_SCK_IN[0]));
CLK_MUX I_TMUX_QSPI_SCK_FB_1 (.A(w_QSPI_SCK_IN[0]), .B(TEST_CLK), 		.S(TE), 			.Y(w_QSPI_SCK_IN[1]));
CLK_CTS I_TMUX_QSPI_SCK_FB   (.A(w_QSPI_SCK_IN[1]), 										.Y(w_QSPI_SCK_IN[2]));

wire	w_QSPI_SS_IN_N;
CLK_MUX I_TMUX_QSPI_SSN_FB (.A(QSPI_SS_IN_N), .B(QSPI_SS_OUT_N), .S(SPI_FBSSN_SEL),	.Y(w_QSPI_SS_IN_N));

reg [15:0]	TX_DMA_ACK_DLY;
reg [15:0]	RX_DMA_ACK_DLY;
always @(posedge HCLKG or negedge w_hresetn)
	if(!w_hresetn) begin
		TX_DMA_ACK_DLY <= 'd0;
		RX_DMA_ACK_DLY <= 'd0;
	end else begin
		TX_DMA_ACK_DLY <= {TX_DMA_ACK_DLY[6:0],TX_DMA_ACK};
		RX_DMA_ACK_DLY <= {RX_DMA_ACK_DLY[6:0],RX_DMA_ACK};
	end

wire w_TX_DMA_ACK = (SPI_DMA_ACK_DLY==4'h1) ? TX_DMA_ACK_DLY[00] :
					(SPI_DMA_ACK_DLY==4'h2) ? TX_DMA_ACK_DLY[01] :
					(SPI_DMA_ACK_DLY==4'h3) ? TX_DMA_ACK_DLY[02] :
					(SPI_DMA_ACK_DLY==4'h4) ? TX_DMA_ACK_DLY[03] :
					(SPI_DMA_ACK_DLY==4'h5) ? TX_DMA_ACK_DLY[04] :
					(SPI_DMA_ACK_DLY==4'h6) ? TX_DMA_ACK_DLY[05] :
					(SPI_DMA_ACK_DLY==4'h7) ? TX_DMA_ACK_DLY[06] :
					(SPI_DMA_ACK_DLY==4'h8) ? TX_DMA_ACK_DLY[07] :
					(SPI_DMA_ACK_DLY==4'h9) ? TX_DMA_ACK_DLY[08] :
					(SPI_DMA_ACK_DLY==4'ha) ? TX_DMA_ACK_DLY[09] :
					(SPI_DMA_ACK_DLY==4'hb) ? TX_DMA_ACK_DLY[10] :
					(SPI_DMA_ACK_DLY==4'hc) ? TX_DMA_ACK_DLY[11] :
					(SPI_DMA_ACK_DLY==4'hd) ? TX_DMA_ACK_DLY[12] :
					(SPI_DMA_ACK_DLY==4'he) ? TX_DMA_ACK_DLY[13] :
					(SPI_DMA_ACK_DLY==4'hf) ? TX_DMA_ACK_DLY[14] :	TX_DMA_ACK; 

wire w_RX_DMA_ACK = (SPI_DMA_ACK_DLY==4'h1) ? RX_DMA_ACK_DLY[00] :
					(SPI_DMA_ACK_DLY==4'h2) ? RX_DMA_ACK_DLY[01] :
					(SPI_DMA_ACK_DLY==4'h3) ? RX_DMA_ACK_DLY[02] :
					(SPI_DMA_ACK_DLY==4'h4) ? RX_DMA_ACK_DLY[03] :
					(SPI_DMA_ACK_DLY==4'h5) ? RX_DMA_ACK_DLY[04] :
					(SPI_DMA_ACK_DLY==4'h6) ? RX_DMA_ACK_DLY[05] :
					(SPI_DMA_ACK_DLY==4'h7) ? RX_DMA_ACK_DLY[06] :
					(SPI_DMA_ACK_DLY==4'h8) ? RX_DMA_ACK_DLY[07] :
					(SPI_DMA_ACK_DLY==4'h9) ? RX_DMA_ACK_DLY[08] :
					(SPI_DMA_ACK_DLY==4'ha) ? RX_DMA_ACK_DLY[09] :
					(SPI_DMA_ACK_DLY==4'hb) ? RX_DMA_ACK_DLY[10] :
					(SPI_DMA_ACK_DLY==4'hc) ? RX_DMA_ACK_DLY[11] :
					(SPI_DMA_ACK_DLY==4'hd) ? RX_DMA_ACK_DLY[12] :
					(SPI_DMA_ACK_DLY==4'he) ? RX_DMA_ACK_DLY[13] :
					(SPI_DMA_ACK_DLY==4'hf) ? RX_DMA_ACK_DLY[14] :	RX_DMA_ACK; 

//-------------------------------------------------------------------------
// Main Core
//-------------------------------------------------------------------------
`ifdef	RTL
	`define ATCSPI200_REG_AHB
	`define ATCSPI200_DIRECT_IO_SUPPORT
	`define ATCSPI200_QUADSPI_SUPPORT
	`define ATCSPI200_TXFIFO_DEPTH_16W
	`define ATCSPI200_RXFIFO_DEPTH_16W
	`define ATCSPI200_ADDR_WIDTH_24
	`define ATCSPI200_SLAVE_SUPPORT
`endif

atcspi200 I_QSPI_CORE (
/*input								*/.hclk					(hclk_cg			),
/*input								*/.hresetn				(w_hresetn			),
/*input [`ATCSPI200_HADDR_WIDTH-1:0]*/.haddr_reg			(SHADDR[23:0]		),
/*input								*/.hreadyin_reg			(SHREADY			),
/*input								*/.hsel_reg				(SHSEL				),
/*input [1:0]						*/.htrans_reg			(SHTRANS			),
/*input	[31:0]						*/.hwdata_reg			(SHWDATA			),
/*input								*/.hwrite_reg			(SHWRITE			),
/*output [31:0]						*/.hrdata_reg			(SHRDATA			),
/*output							*/.hreadyout_reg		(SHREADYOUT			),
/*output [1:0]						*/.hresp_reg			(SHRESP				),

/*input								*/.scan_enable			(SE					),
/*input								*/.scan_test			(TE					),
/*input								*/.spi_cs_n_in			(w_QSPI_SS_IN_N		),
/*input								*/.spi_clk_in			(w_QSPI_SCK_IN[2]	),
/*input								*/.spi_clock			(SCLKG				),
/*input								*/.spi_default_as_slave	(SPI_DEF_SLAVE		),
/*input								*/.spi_default_mode3	(SPI_DEF_MODE		),
/*input								*/.spi_miso_in			(QSPI_IO_IN[1]		),
/*input								*/.spi_mosi_in			(QSPI_IO_IN[0]		),
/*input								*/.spi_rstn				(w_sresetn			),
/*input								*/.spi_rx_dma_ack		(w_RX_DMA_ACK		),
/*input								*/.spi_tx_dma_ack		(w_TX_DMA_ACK		),
/*output							*/.spi_boot_intr		(INTR				),
/*output							*/.spi_clk_oe			(QSPI_SCK_OUT_EN	),
/*output							*/.spi_clk_out			(w_QSPI_SCK_OUT		),
/*output							*/.spi_cs_n_oe			(QSPI_SS_OUT_N_OE	),
/*output							*/.spi_cs_n_out			(QSPI_SS_OUT_N		),
/*output							*/.spi_miso_oe			(QSPI_IO_OUT_EN[1]	),
/*output							*/.spi_miso_out			(QSPI_IO_OUT[1]		),
/*output							*/.spi_mosi_oe			(QSPI_IO_OUT_EN[0]	),
/*output							*/.spi_mosi_out			(QSPI_IO_OUT[0]		),
/*output							*/.spi_rx_dma_req		(RX_DMA_REQ			),
/*output							*/.spi_tx_dma_req		(TX_DMA_REQ			),
//
/*input 							*/.spi_hold_n_in		(QSPI_IO_IN[3]		),
/*input 							*/.spi_wp_n_in			(QSPI_IO_IN[2]		),
/*output							*/.spi_hold_n_oe		(QSPI_IO_OUT_EN[3]	),
/*output							*/.spi_hold_n_out		(QSPI_IO_OUT[3]		),
/*output							*/.spi_wp_n_oe			(QSPI_IO_OUT_EN[2]	),
/*output							*/.spi_wp_n_out			(QSPI_IO_OUT[2]		)
);

/*
MUX25U1001E I_SFLASH_MEM (
	.SCLK	(),
	.CS		(),
	.SI		(si		),	//SIO0
	.SO		(so		),	//SIO1
	.WP		(wp		),	//SIO2
	.SIO3	(hold	),	//SIO3
);
*/

//`undef ATCSPI200_REG_AHB
//`undef ATCSPI200_QUADSPI_SUPPORT
//`undef ATCSPI200_TXFIFO_DEPTH_8W
//`undef ATCSPI200_RXFIFO_DEPTH_8W
//`undef ATCSPI200_ADDR_WIDTH_24

endmodule
