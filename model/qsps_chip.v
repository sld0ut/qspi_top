////////////////////////////////////////////////////////
//
//  Module: qsps_chip 
//  Project: MCUP
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////
`timescale 1ns/10ps

module qsps_chip (
	inout wire			P_RESETN	,
	inout wire			P_QSPS_CSN	,
	inout wire			P_QSPS_SCK	,
	inout wire	[3:0]	P_QSPS_IO
);

wire [31:0]		hv_reg_msg_00, hv_reg_msg_01, hv_reg_msg_02, hv_reg_msg_03;
wire [31:0]		hv_reg_msg_04, hv_reg_msg_05, hv_reg_msg_06, hv_reg_msg_07;
wire [31:0]		hv_reg_msg_08, hv_reg_msg_09, hv_reg_msg_10, hv_reg_msg_11;
wire [31:0]		hv_reg_msg_12, hv_reg_msg_13, hv_reg_msg_14, hv_reg_msg_15;
wire [31:0]		hv_reg_msg_16;
wire [31:0]		hv_reg_msg_17;
wire [31:0]		hv_reg_msg_18;
wire [31:0]		hv_reg_msg_19;
wire [31:0]		hv_reg_msg_20;
wire [31:0]		hv_reg_msg_21;
wire [31:0]		hv_reg_msg_22;
wire [31:0]		hv_reg_msg_23;
wire [31:0]		hv_reg_msg_24;
wire [31:0]		hv_reg_msg_25;
wire [31:0]		hv_reg_msg_26;
wire [31:0]		hv_reg_msg_27;
wire [31:0]		hv_reg_msg_28;
wire [31:0]		hv_reg_msg_29;
wire [31:0]		hv_reg_msg_30;
wire [31:0]		hv_reg_msg_31;
wire [31:0]		hv_reg_msg_32;
wire [31:0]		hv_reg_msg_33;
wire [16-1:0]	w_SEN_GPIO_I		= 'd0;
wire			w_CAP_CAL_CONT_UP	= 'd0;
wire			w_MUX_PHASE_OUT		= 'd0;
wire			w_HV_BCONT_GO_UP15	= 'd0;
	//
wire			w_SSN			;
wire			w_SCK			;
wire			w_MOSI_I		;
wire			w_MOSI_O		;
wire			w_MOSI_OE		;
wire			w_MISO_I		;
wire			w_MISO_O		;
wire			w_MISO_OE		;
wire			w_WP_I			;
wire			w_WP_O			;
wire			w_WP_OE			;
wire			w_HOLD_I		;
wire			w_HOLD_O		;
wire			w_HOLD_OE		;

wire			w_RESETN		;
wire			w_SE			= 'd0;		
wire			w_TEST_CLK		= 'd0;		
wire			w_TEST_RESET	= 'd0;		
wire			w_TE			= 'd0;


qsps_top u_qsps_top (
/*output reg [31:0]	*/	.hv_reg_msg_00(hv_reg_msg_00), .hv_reg_msg_01(hv_reg_msg_01), 
/*output reg [31:0]	*/	.hv_reg_msg_04(hv_reg_msg_04), .hv_reg_msg_05(hv_reg_msg_05), 
/*output reg [31:0]	*/	.hv_reg_msg_08(hv_reg_msg_08), .hv_reg_msg_09(hv_reg_msg_09), 
/*output reg [31:0]	*/	.hv_reg_msg_12(hv_reg_msg_12), .hv_reg_msg_13(hv_reg_msg_13), 
/*output reg [31:0]	*/	.hv_reg_msg_02(hv_reg_msg_02), .hv_reg_msg_03(hv_reg_msg_03),
/*output reg [31:0]	*/	.hv_reg_msg_06(hv_reg_msg_06), .hv_reg_msg_07(hv_reg_msg_07),
/*output reg [31:0]	*/	.hv_reg_msg_10(hv_reg_msg_10), .hv_reg_msg_11(hv_reg_msg_11),
/*output reg [31:0]	*/	.hv_reg_msg_14(hv_reg_msg_14), .hv_reg_msg_15(hv_reg_msg_15),
/*output reg [31:0]	*/	.hv_reg_msg_16		(hv_reg_msg_16		),
/*output reg [31:0]	*/	.hv_reg_msg_17		(hv_reg_msg_17		),
/*output reg [31:0]	*/	.hv_reg_msg_18		(hv_reg_msg_18		),
/*output reg [31:0]	*/	.hv_reg_msg_19		(hv_reg_msg_19		),
/*output reg [31:0]	*/	.hv_reg_msg_20		(hv_reg_msg_20		),
/*output reg [31:0]	*/	.hv_reg_msg_21		(hv_reg_msg_21		),
/*output reg [31:0]	*/	.hv_reg_msg_22		(hv_reg_msg_22		),
/*output reg [31:0]	*/	.hv_reg_msg_23		(hv_reg_msg_23		),
/*output reg [31:0]	*/	.hv_reg_msg_24		(hv_reg_msg_24		),
/*output reg [31:0]	*/	.hv_reg_msg_25		(hv_reg_msg_25		),
/*output reg [31:0]	*/	.hv_reg_msg_26		(hv_reg_msg_26		),
/*output reg [31:0]	*/	.hv_reg_msg_27		(hv_reg_msg_27		),
/*output reg [31:0]	*/	.hv_reg_msg_28		(hv_reg_msg_28		),
/*output reg [31:0]	*/	.hv_reg_msg_29		(hv_reg_msg_29		),
/*output reg [31:0]	*/	.hv_reg_msg_30		(hv_reg_msg_30		),
/*output reg [31:0]	*/	.hv_reg_msg_31		(hv_reg_msg_31		),
/*output reg [31:0]	*/	.hv_reg_msg_32		(hv_reg_msg_32		),
/*output reg [31:0]	*/	.hv_reg_msg_33		(hv_reg_msg_33		),
/*input wire [16-1:0]*/	.SEN_GPIO_I			(w_SEN_GPIO_I		),
/*input wire		*/	.CAP_CAL_CONT_UP	(w_CAP_CAL_CONT_UP	),
/*input wire		*/	.MUX_PHASE_OUT		(w_MUX_PHASE_OUT	),
/*input wire		*/	.HV_BCONT_GO_UP15	(w_HV_BCONT_GO_UP15	),
//                                                              
/*input wire		*/	.SSN				(w_SSN				),
/*input wire		*/	.SCK				(w_SCK				),
/*input wire		*/	.MOSI_I				(w_MOSI_I			),
/*output wire		*/	.MOSI_O				(w_MOSI_O			),
/*output wire		*/	.MOSI_OE			(w_MOSI_OE			),
/*input wire		*/	.MISO_I				(w_MISO_I			),
/*output wire		*/	.MISO_O				(w_MISO_O			),
/*output wire		*/	.MISO_OE			(w_MISO_OE			),
/*input wire		*/	.WP_I				(w_WP_I				),
/*output wire		*/	.WP_O				(w_WP_O				),
/*output wire		*/	.WP_OE				(w_WP_OE			),
/*input wire		*/	.HOLD_I				(w_HOLD_I			),
/*output wire		*/	.HOLD_O				(w_HOLD_O			),
/*output wire		*/	.HOLD_OE			(w_HOLD_OE			),
//
/*input wire		*/	.RESETN				(w_RESETN			),
/*input wire		*/	.SE					(w_SE				),		
/*input wire		*/	.TEST_CLK			(w_TEST_CLK			),		
/*input wire		*/	.TEST_RESET			(w_TEST_RESET		),		
/*input wire		*/	.TE					(w_TE				)
);

PAD_B_PU I_PAD_RESETN (
/*input wire	*/	.PE		(1'b1		),
/*input wire	*/	.DS		(1'b1		),
/*input wire	*/	.OEN	(1'b1		),
/*input wire	*/	.I		(1'b1		),
/*output wire	*/	.O		(w_RESETN	),
/*inout wire	*/	.P		(P_RESETN	)
);

PAD_B_PU I_PAD_QSPS_CSN (
/*input wire	*/	.PE		(1'b1		),
/*input wire	*/	.DS		(1'b1		),
/*input wire	*/	.OEN	(1'b1		),
/*input wire	*/	.I		(1'b1		),
/*output wire	*/	.O		(w_SSN		),
/*inout wire	*/	.P		(P_QSPS_CSN	)
);

PAD_B_PU I_PAD_QSPS_SCK (
/*input wire	*/	.PE		(1'b1		),
/*input wire	*/	.DS		(1'b1		),
/*input wire	*/	.OEN	(1'b1		),
/*input wire	*/	.I		(1'b1		),
/*output wire	*/	.O		(w_SCK		),
/*inout wire	*/	.P		(P_QSPS_SCK	)
);

wire [3:0]	w_QSPS_IO_OEN;
wire [3:0]	w_QSPS_IO_OUT;
wire [3:0]	w_QSPS_IO_IN;

assign w_QSPS_IO_OEN[0]	= ~w_MOSI_OE;
assign w_QSPS_IO_OEN[1]	= ~w_MISO_OE;
assign w_QSPS_IO_OEN[2]	= ~w_WP_OE;
assign w_QSPS_IO_OEN[3]	= ~w_HOLD_OE;

assign w_QSPS_IO_OUT[0]	= w_MOSI_O;
assign w_QSPS_IO_OUT[1]	= w_MISO_O;
assign w_QSPS_IO_OUT[2]	= w_WP_O;
assign w_QSPS_IO_OUT[3]	= w_HOLD_O;

assign w_MOSI_I	= w_QSPS_IO_IN[0];
assign w_MISO_I	= w_QSPS_IO_IN[1];
assign w_WP_I	= w_QSPS_IO_IN[2];
assign w_HOLD_I	= w_QSPS_IO_IN[3];

genvar	sp;
generate
	for(sp = 0; sp < 4; sp = sp + 1) begin : QSPI_PAD
		PAD_B_PU I_PAD_QSPS_IO (
		/*input wire	*/	.PE		(1'b1				),
		/*input wire	*/	.DS		(1'b1				),
		/*input wire	*/	.OEN	(w_QSPS_IO_OEN[sp]	),
		/*input wire	*/	.I		(w_QSPS_IO_OUT[sp]	),
		/*output wire	*/	.O		(w_QSPS_IO_IN[sp]	),
		/*inout wire	*/	.P		(P_QSPS_IO[sp]		)
		);
	end
endgenerate

endmodule
