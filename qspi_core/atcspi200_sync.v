// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary


module atcspi200_sync
(
	  sysclk,
	  sysrstn,
	  spi_clock,
	  spi_rstn,
	  regclk,
	  regrstn,
	  reg2sys_clken,
	  arb_req_sysclk,
	  arb_req_sclk,
	  arb_busy_sclk,
	  arb_busy_sysclk,
	  arb_trans_end_sclk,
	  arb_trans_end_sysclk,
`ifdef ATCSPI200_MEM_SUPPORT
	  arb_addr_latched_sclk,
	  arb_addr_latched_sysclk,
`endif
	  spi_reset_regclk,
	  spi_reset_sclk,
	  spi_reset_sysclk,
`ifdef ATCSPI200_SLAVE_SUPPORT
	  slave_cmd_wr_sclk,
	  slave_rcnt_inc_sclk,
	  slave_wcnt_inc_sclk,
	  rxf_overrun_sclk,
	  txf_underrun_sclk,
	  slave_cmd_wr_regclk,
	  slave_rcnt_inc_regclk,
	  slave_wcnt_inc_regclk,
	  rxf_overrun_regclk,
	  txf_underrun_regclk,
`endif
	  reg_trans_end_sysclk,
	  reg_trans_end_regclk,
	  reg_req_regclk,
	  reg_txf_wr_regclk,
	  reg_txf_clr_regclk,
	  reg_rxf_rd_regclk,
	  reg_rxf_clr_regclk,
	  reg_req_sysclk,
	  reg_txf_wr_sysclk,
	  reg_txf_clr_sysclk,
	  reg_rxf_rd_sysclk,
	  reg_rxf_clr_sysclk
);

input		sysclk;
input		sysrstn;
input		spi_clock;
input		spi_rstn;
input		regclk;
input		regrstn;
input		reg2sys_clken;

input		arb_req_sysclk;
output		arb_req_sclk;

input		arb_busy_sclk;
output		arb_busy_sysclk;

input		arb_trans_end_sclk;
output		arb_trans_end_sysclk;

`ifdef ATCSPI200_MEM_SUPPORT
	input		arb_addr_latched_sclk;
	output		arb_addr_latched_sysclk;
`endif

input		spi_reset_regclk;
output		spi_reset_sclk;
output		spi_reset_sysclk;

`ifdef ATCSPI200_SLAVE_SUPPORT
	input		slave_cmd_wr_sclk;
	input		slave_rcnt_inc_sclk;
	input		slave_wcnt_inc_sclk;
	input		rxf_overrun_sclk;
	input		txf_underrun_sclk;

	output		slave_cmd_wr_regclk;
	output		slave_rcnt_inc_regclk;
	output		slave_wcnt_inc_regclk;
	output		rxf_overrun_regclk;
	output		txf_underrun_regclk;
`endif

input		reg_trans_end_sysclk;
output		reg_trans_end_regclk;


input		reg_req_regclk;
input		reg_txf_wr_regclk;
input		reg_txf_clr_regclk;
input		reg_rxf_rd_regclk;
input		reg_rxf_clr_regclk;
output		reg_req_sysclk;
output		reg_txf_wr_sysclk;
output		reg_txf_clr_sysclk;
output		reg_rxf_rd_sysclk;
output		reg_rxf_clr_sysclk;


nds_sync_l2l arb_req_sync(
	.b_reset_n			(spi_rstn),
	.b_clk				(spi_clock),
	.a_signal			(arb_req_sysclk),
	.b_signal			(arb_req_sclk),
	.b_signal_rising_edge_pulse	(),
	.b_signal_falling_edge_pulse	(),
	.b_signal_edge_pulse		()
);

nds_sync_l2l arb_busy_sync(
	.b_reset_n			(sysrstn),
	.b_clk				(sysclk),
	.a_signal			(arb_busy_sclk),
	.b_signal			(arb_busy_sysclk),
	.b_signal_rising_edge_pulse	(),
	.b_signal_falling_edge_pulse	(),
	.b_signal_edge_pulse		()
);

nds_sync_p2p arb_trans_end_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(arb_trans_end_sclk),
	.b_reset_n	(sysrstn),
	.b_clk		(sysclk),
	.b_pulse	(arb_trans_end_sysclk),
	.b_level	(),
	.b_level_d1	()
);

`ifdef ATCSPI200_MEM_SUPPORT
nds_sync_p2p arb_addr_latched_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(arb_addr_latched_sclk),
	.b_reset_n	(sysrstn),
	.b_clk		(sysclk),
	.b_pulse	(arb_addr_latched_sysclk),
	.b_level	(),
	.b_level_d1	()
);
`endif

`ifdef ATCSPI200_SLAVE_SUPPORT
nds_sync_p2p slave_cmd_wr_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(slave_cmd_wr_sclk),
	.b_reset_n	(regrstn),
	.b_clk		(regclk),
	.b_pulse	(slave_cmd_wr_regclk),
	.b_level	(),
	.b_level_d1	()
);


nds_sync_p2p slave_rcnt_inc_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(slave_rcnt_inc_sclk),
	.b_reset_n	(regrstn),
	.b_clk		(regclk),
	.b_pulse	(slave_rcnt_inc_regclk),
	.b_level	(),
	.b_level_d1	()
);

nds_sync_p2p slave_wcnt_inc_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(slave_wcnt_inc_sclk),
	.b_reset_n	(regrstn),
	.b_clk		(regclk),
	.b_pulse	(slave_wcnt_inc_regclk),
	.b_level	(),
	.b_level_d1	()
);

nds_sync_p2p rxf_overrun_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(rxf_overrun_sclk),
	.b_reset_n	(regrstn),
	.b_clk		(regclk),
	.b_pulse	(rxf_overrun_regclk),
	.b_level	(),
	.b_level_d1	()
);

nds_sync_p2p txf_underrun_sync(
	.a_reset_n	(spi_rstn),
	.a_clk		(spi_clock),
	.a_pulse	(txf_underrun_sclk),
	.b_reset_n	(regrstn),
	.b_clk		(regclk),
	.b_pulse	(txf_underrun_regclk),
	.b_level	(),
	.b_level_d1	()
);
`endif

`ifdef ATCSPI200_REG_APB
	reg		reg_trans_end_ext;

	always @(negedge sysrstn or posedge sysclk)
	begin
		if (!sysrstn)
			reg_trans_end_ext <= 1'b0;
		else if (reg2sys_clken)
			reg_trans_end_ext <= 1'b0;
		else if (reg_trans_end_sysclk)
			reg_trans_end_ext <= 1'b1;
	end
	assign reg_trans_end_regclk = reg_trans_end_sysclk | reg_trans_end_ext;
`else
	assign reg_trans_end_regclk = reg_trans_end_sysclk;
`endif
assign reg_req_sysclk = reg_req_regclk & ~reg_trans_end_regclk;

assign reg_txf_wr_sysclk = reg_txf_wr_regclk & reg2sys_clken;
assign reg_txf_clr_sysclk = reg_txf_clr_regclk & reg2sys_clken;
assign reg_rxf_rd_sysclk = reg_rxf_rd_regclk & reg2sys_clken;
assign reg_rxf_clr_sysclk = reg_rxf_clr_regclk & reg2sys_clken;

reg	spi_reset_sysclk;
wire	spi_reset_ack;

always @(negedge sysrstn or posedge sysclk)
begin
	if (~sysrstn)
		spi_reset_sysclk <= 1'b0;
	else if (spi_reset_regclk & reg2sys_clken)
		spi_reset_sysclk <= 1'b1;
	else if (spi_reset_ack)
		spi_reset_sysclk <= 1'b0;
end

nds_sync_l2l spi_reset_sync(
	.b_reset_n			(spi_rstn),
	.b_clk				(spi_clock),
	.a_signal			(spi_reset_sysclk),
	.b_signal			(spi_reset_sclk),
	.b_signal_rising_edge_pulse	(),
	.b_signal_falling_edge_pulse	(),
	.b_signal_edge_pulse		()
);

nds_sync_l2l spi_reset_ack_sync(
	.b_reset_n			(regrstn),
	.b_clk				(regclk),
	.a_signal			(spi_reset_sclk),
	.b_signal			(spi_reset_ack),
	.b_signal_rising_edge_pulse	(),
	.b_signal_falling_edge_pulse	(),
	.b_signal_edge_pulse		()
);

endmodule
