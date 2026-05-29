// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary

`include "atcspi200_config.vh"
`include "atcspi200_const.vh"

module atcspi200_arbiter (
	  sysrstn,
	  sysclk,
	  reg2sys_clken,
	  spi_reset_sysclk,
`ifdef ATCSPI200_SLAVE_SUPPORT
	  spi_master,
`endif
`ifdef ATCSPI200_AHB_MEM_SUPPORT
	  ahb_spi_req,
	  ahb_rxf_rd,
	  ahb_addr_latched,
	  ahb_other_req,
	  ahb_spi_addr,
	  ahb_rxf_empty,
	  ahb_spi_busy,
`endif
`ifdef ATCSPI200_EILM_MEM_SUPPORT
	  eilm_spi_req,
	  eilm_rxf_rd,
	  eilm_addr_latched,
	  eilm_other_req,
	  eilm_spi_addr,
	  eilm_rxf_empty,
	  eilm_spi_busy,
`endif
`ifdef ATCSPI200_MEM_SUPPORT
	  mem_write_trans_ctrl,
	  mem_read_trans_ctrl,
	  mem_write_opcode,
	  mem_read_opcode,
	  mem_cmd_chg,
	  mem_addr_len,
	  mem_cmd_chg_window,
`endif
	  reg_trans_ctrl,
	  reg_opcode,
	  reg_spi_addr,
	  reg_req_sysclk,
	  reg_txf_wr_data,
	  reg_txf_wr_sysclk,
	  reg_rxf_rd_sysclk,
	  reg_rxf_clr_sysclk,
	  reg_txf_clr_sysclk,
	  reg_data_merge,
	  reg_addr_len,
	  reg_busy,
	  reg_rxf_empty,
	  reg_txf_full,
	  reg_rxf_entries,
	  reg_txf_entries,
	  arb_busy_sysclk,
	  arb_req_sysclk,
	  arb_opcode,
	  arb_addr,
	  arb_trans_end_sysclk,
	  reg_trans_end_sysclk,
`ifdef ATCSPI200_MEM_SUPPORT
	  arb_mem_req,
	  arb_addr_latched_sysclk,
`endif
	  arb_addr_len,
	  arb_data_merge,
	  arb_trans_ctrl,
	  arb_txf_wr_data,
	  arb_txf_wr,
	  arb_rxf_rd,
	  arb_rxf_clr,
	  arb_txf_clr,
	  rxf_clr_level,
	  rxf_empty,
	  txf_full,
	  rxf_entries,
	  txf_entries
);

input			sysrstn;
input			sysclk;
input			reg2sys_clken;

input			spi_reset_sysclk;
`ifdef ATCSPI200_SLAVE_SUPPORT
	input		spi_master;
`endif
`ifdef ATCSPI200_AHB_MEM_SUPPORT
	input		ahb_spi_req;
	input		ahb_rxf_rd;
	output		ahb_addr_latched;
	output		ahb_other_req;
	input	[31:0]	ahb_spi_addr;
	output		ahb_rxf_empty;
	output		ahb_spi_busy;
`endif
`ifdef ATCSPI200_EILM_MEM_SUPPORT
	input		eilm_spi_req;
	input		eilm_rxf_rd;
	output		eilm_addr_latched;
	output		eilm_other_req;
	input	[31:0]	eilm_spi_addr;
	output		eilm_rxf_empty;
	output		eilm_spi_busy;
`endif
`ifdef ATCSPI200_MEM_SUPPORT
	input	[30:0]	mem_write_trans_ctrl;
	input	[30:0]	mem_read_trans_ctrl;
	input	[7:0]	mem_write_opcode;
	input	[7:0]	mem_read_opcode;
	input		mem_cmd_chg;
	input	[1:0]	mem_addr_len;
	output		mem_cmd_chg_window;
`endif
input	[30:0]		reg_trans_ctrl;
input	[7:0] 		reg_opcode;
input	[31:0]		reg_spi_addr;
input			reg_req_sysclk;
input	[31:0]		reg_txf_wr_data;
input			reg_txf_wr_sysclk;
input			reg_rxf_rd_sysclk;
input			reg_rxf_clr_sysclk;
input			reg_txf_clr_sysclk;
input			reg_data_merge;
input	[1:0]		reg_addr_len;
output			reg_busy;
output			reg_rxf_empty;
output			reg_txf_full;
output	[`ATCSPI200_RXFPTR_BITS-1:0]	reg_rxf_entries;
output	[`ATCSPI200_TXFPTR_BITS-1:0]	reg_txf_entries;

input			arb_busy_sysclk;
output			arb_req_sysclk;
output	[7:0]		arb_opcode;
output	[31:0]		arb_addr;
input			arb_trans_end_sysclk;
output			reg_trans_end_sysclk;
`ifdef	ATCSPI200_MEM_SUPPORT
output			arb_mem_req;
input			arb_addr_latched_sysclk;
`endif
output	[1:0]		arb_addr_len;
output			arb_data_merge;
output	[30:0]		arb_trans_ctrl;

output	[31:0]		arb_txf_wr_data;
output			arb_txf_wr;
output			arb_rxf_rd;
output			arb_rxf_clr;
output			arb_txf_clr;
input			rxf_clr_level;

input			rxf_empty;
input			txf_full;
input	[`ATCSPI200_RXFPTR_BITS-1:0]	rxf_entries;
input	[`ATCSPI200_TXFPTR_BITS-1:0]	txf_entries;

`ifdef ATCSPI200_SLAVE_SUPPORT
`else
	wire	spi_master = 1'b1;
`endif
wire	[7:0]	arb_opcode;

reg	[2:0]	arb_cs_r, arb_ns;
reg		arb_req_sysclk;

wire		arb_sel_ahb;
wire		arb_sel_ahb_data;
wire		arb_sel_eilm;
wire		arb_sel_eilm_data;
wire		arb_sel_reg;

`ifdef ATCSPI200_AHB_MEM_SUPPORT
`else
	wire	ahb_spi_req = 1'b0;
`endif
`ifdef ATCSPI200_EILM_MEM_SUPPORT
`else
	wire	eilm_spi_req = 1'b0;
`endif



`ifdef ATCSPI200_MEM_SUPPORT
	wire	mem_write;
`else
	wire	mem_cmd_chg = 1'b0;
	wire	arb_mem_req;
`endif

parameter AR_REG_END	= 3'h0;
parameter AR_REG_BUSY	= 3'h1;
parameter AR_AHB_END	= 3'h2;
parameter AR_AHB_BUSY	= 3'h3;
parameter AR_EILM_END	= 3'h4;
parameter AR_EILM_BUSY	= 3'h5;
parameter AR_WAIT_RXFEM	= 3'h6;

always@(*)
begin
	arb_ns = arb_cs_r;
	case(arb_cs_r)
		AR_AHB_BUSY: begin
			if (~ahb_spi_req)
				arb_ns = AR_AHB_END;
		end
		AR_AHB_END: begin
			if (~arb_busy_sysclk)
				arb_ns = AR_WAIT_RXFEM;
		end
		AR_EILM_BUSY: begin
			if (~eilm_spi_req)
				arb_ns = AR_EILM_END;
		end
		AR_EILM_END: begin
			if (~arb_busy_sysclk)
				arb_ns = AR_WAIT_RXFEM;
		end
		AR_WAIT_RXFEM: begin
			if (~rxf_clr_level) begin
				if (ahb_spi_req & ~mem_cmd_chg)
					arb_ns = AR_AHB_BUSY;
				else if (reg_req_sysclk & reg2sys_clken)
					arb_ns = AR_REG_BUSY;
				else if (eilm_spi_req & ~mem_cmd_chg)
					arb_ns = AR_EILM_BUSY;
			end
		end
		AR_REG_BUSY: begin
			if (arb_trans_end_sysclk)
				arb_ns = AR_REG_END;
		end
		default : begin
			if (~arb_busy_sysclk & reg2sys_clken) begin
				if (ahb_spi_req & ~mem_cmd_chg & reg2sys_clken)
					arb_ns = AR_WAIT_RXFEM;
				else if (reg_req_sysclk)
					arb_ns = AR_REG_BUSY;
				else if (eilm_spi_req & ~mem_cmd_chg & reg2sys_clken)
					arb_ns = AR_WAIT_RXFEM;
			end
		end
	endcase
end

always @(negedge sysrstn or posedge sysclk)
begin
	if (~sysrstn)
		arb_cs_r <= AR_REG_END;
	else if (spi_reset_sysclk | ~spi_master)
		arb_cs_r <= AR_REG_END;
	else
		arb_cs_r <= arb_ns;
end

`ifdef ATCSPI200_AHB_MEM_SUPPORT
	assign arb_sel_ahb	= spi_master & ((arb_cs_r == AR_AHB_BUSY) | (arb_cs_r == AR_AHB_END));
	assign arb_sel_ahb_data	= spi_master &  (arb_cs_r == AR_AHB_BUSY);
`else
	assign arb_sel_ahb	= 1'b0;
	assign arb_sel_ahb_data = 1'b0;
`endif

`ifdef ATCSPI200_EILM_MEM_SUPPORT
	assign arb_sel_eilm	= spi_master & ((arb_cs_r == AR_EILM_BUSY) | (arb_cs_r == AR_EILM_END));
	assign arb_sel_eilm_data= spi_master &  (arb_cs_r == AR_EILM_BUSY);
`else
	assign arb_sel_eilm	= 1'b0;
	assign arb_sel_eilm_data= 1'b0;
`endif

assign arb_sel_reg  = spi_master ? ((arb_cs_r == AR_REG_BUSY) | (arb_cs_r == AR_REG_END)) : 1'b1;

always @(negedge sysrstn or posedge sysclk)
begin
	if (~sysrstn)
		arb_req_sysclk <= 1'b0;
	else if (arb_ns == AR_AHB_BUSY)
		arb_req_sysclk <= ahb_spi_req;
	else if (arb_ns == AR_EILM_BUSY)
		arb_req_sysclk <= eilm_spi_req;
	else if (arb_ns == AR_REG_BUSY)
		arb_req_sysclk <= reg_req_sysclk;
	else
		arb_req_sysclk <= 1'b0;
end


`ifdef ATCSPI200_AHB_MEM_SUPPORT
	`ifdef ATCSPI200_EILM_MEM_SUPPORT
		assign arb_addr		= arb_sel_ahb ? ahb_spi_addr : arb_sel_eilm ? eilm_spi_addr : reg_spi_addr;
		assign arb_rxf_rd	= arb_sel_ahb ? ahb_rxf_rd : arb_sel_eilm ? eilm_rxf_rd : reg_rxf_rd_sysclk & reg2sys_clken;
		assign mem_write	= 1'b0;
		assign mem_cmd_chg_window	= ~((arb_ns == AR_AHB_BUSY) | (arb_ns == AR_EILM_BUSY)) & ~arb_busy_sysclk;
		assign eilm_other_req	= ahb_spi_req | reg_req_sysclk;
		assign ahb_other_req	= eilm_spi_req | reg_req_sysclk;
	`else
		assign arb_addr		= arb_sel_ahb ? ahb_spi_addr : reg_spi_addr;
		assign arb_rxf_rd	= arb_sel_ahb ? ahb_rxf_rd : reg_rxf_rd_sysclk & reg2sys_clken;
		assign mem_write	= 1'b0;
		assign mem_cmd_chg_window  = ~(arb_ns == AR_AHB_BUSY) & ~arb_busy_sysclk;
		assign ahb_other_req	= reg_req_sysclk;
	`endif
`else
	`ifdef ATCSPI200_EILM_MEM_SUPPORT
		assign arb_addr		= arb_sel_eilm ? eilm_spi_addr : reg_spi_addr;
		assign arb_rxf_rd	= arb_sel_eilm ? eilm_rxf_rd : reg_rxf_rd_sysclk & reg2sys_clken;
		assign mem_write	= 1'b0;
		assign mem_cmd_chg_window	= ~(arb_ns == AR_EILM_BUSY) & ~arb_busy_sysclk;
		assign eilm_other_req	= reg_req_sysclk;
	`else
		assign arb_addr		= reg_spi_addr;
		assign arb_rxf_rd	= reg_rxf_rd_sysclk & reg2sys_clken;
	`endif
`endif

`ifdef ATCSPI200_MEM_SUPPORT
	assign arb_trans_ctrl	= (arb_sel_eilm | arb_sel_ahb) ? (mem_write ? mem_write_trans_ctrl : mem_read_trans_ctrl) : reg_trans_ctrl;
	assign arb_opcode	= (arb_sel_eilm | arb_sel_ahb) ? (mem_write ? mem_write_opcode : mem_read_opcode) : reg_opcode;
	assign arb_mem_req	= arb_sel_eilm | arb_sel_ahb;
	assign arb_addr_len	= arb_sel_reg ? reg_addr_len : mem_addr_len;
`else
	assign arb_trans_ctrl	= reg_trans_ctrl;
	assign arb_opcode	= reg_opcode;
	assign arb_mem_req	= 1'b0;
	assign arb_addr_len	= reg_addr_len;
`endif

assign arb_data_merge	= arb_sel_reg ? reg_data_merge : 1'b1;

assign reg_rxf_empty	= arb_sel_reg ? rxf_empty : 1'b1;
assign reg_rxf_entries	= arb_sel_reg ? rxf_entries : `ATCSPI200_RXFPTR_BITS'b0;
assign arb_rxf_clr	= (arb_mem_req & arb_trans_end_sysclk) | (arb_sel_reg & reg_rxf_clr_sysclk & reg2sys_clken);

assign reg_txf_full	= txf_full;
assign reg_txf_entries	= txf_entries;
assign arb_txf_wr	= reg_txf_wr_sysclk & reg2sys_clken;
assign arb_txf_wr_data	= reg_txf_wr_data;
assign arb_txf_clr	= reg_txf_clr_sysclk & reg2sys_clken;

assign reg_busy		= arb_sel_reg & arb_busy_sysclk;
assign reg_trans_end_sysclk = arb_sel_reg & arb_trans_end_sysclk;

`ifdef ATCSPI200_AHB_MEM_SUPPORT
	assign ahb_rxf_empty = arb_sel_ahb ? rxf_empty : 1'b1;
	assign ahb_addr_latched = arb_sel_ahb_data & arb_addr_latched_sysclk;
	assign ahb_spi_busy = arb_sel_ahb & arb_busy_sysclk;
`endif

`ifdef ATCSPI200_EILM_MEM_SUPPORT
	assign eilm_rxf_empty = arb_sel_eilm ? rxf_empty : 1'b1;
	assign eilm_addr_latched = arb_sel_eilm_data & arb_addr_latched_sysclk;
	assign eilm_spi_busy = arb_sel_eilm & arb_busy_sysclk;
`endif

endmodule
