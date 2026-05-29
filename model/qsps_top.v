////////////////////////////////////////////////////////
//
//  Module: 
//  Project: ANA1703
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////

module qsps_top (
	output reg [31:0]	hv_reg_msg_00, hv_reg_msg_01, hv_reg_msg_02, hv_reg_msg_03,
	output reg [31:0]	hv_reg_msg_04, hv_reg_msg_05, hv_reg_msg_06, hv_reg_msg_07,
	output reg [31:0]	hv_reg_msg_08, hv_reg_msg_09, hv_reg_msg_10, hv_reg_msg_11,
	output reg [31:0]	hv_reg_msg_12, hv_reg_msg_13, hv_reg_msg_14, hv_reg_msg_15,
	output reg [31:0]	hv_reg_msg_16,
	output reg [31:0]	hv_reg_msg_17,
	output reg [31:0]	hv_reg_msg_18,
	output reg [31:0]	hv_reg_msg_19,
	output reg [31:0]	hv_reg_msg_20,
	output reg [31:0]	hv_reg_msg_21,
	output reg [31:0]	hv_reg_msg_22,
	output reg [31:0]	hv_reg_msg_23,
	output reg [31:0]	hv_reg_msg_24,
	output reg [31:0]	hv_reg_msg_25,
	output reg [31:0]	hv_reg_msg_26,
	output reg [31:0]	hv_reg_msg_27,
	output reg [31:0]	hv_reg_msg_28,
	output reg [31:0]	hv_reg_msg_29,
	output reg [31:0]	hv_reg_msg_30,
	output reg [31:0]	hv_reg_msg_31,
	output reg [31:0]	hv_reg_msg_32,
	output reg [31:0]	hv_reg_msg_33,
	input wire [16-1:0]	SEN_GPIO_I,
	input wire			CAP_CAL_CONT_UP,
	input wire			MUX_PHASE_OUT,
	input wire			HV_BCONT_GO_UP15,
	//
	input wire		SSN			,
	input wire		SCK			,
	input wire		MOSI_I		,
	output wire		MOSI_O		,
	output wire		MOSI_OE		,
	input wire		MISO_I		,
	output wire		MISO_O		,
	output wire		MISO_OE		,
	input wire		WP_I		,
	output wire		WP_O		,
	output wire		WP_OE		,
	input wire		HOLD_I		,
	output wire		HOLD_O		,
	output wire		HOLD_OE		,

	input wire		RESETN		,
	input wire		SE			,		
	input wire		TEST_CLK	,		
	input wire		TEST_RESET	,		
	input wire		TE		
);
//-------------------------------------------------------------------------
// Signals
//-------------------------------------------------------------------------
wire		w_enable = 	1'b1;	//= 1'b1;
wire		w_lsb			;	//= 1'b0;
wire		w_addr_width	;	//= 1'b0;
wire [1:0]	w_rcmd_pat		;	//= 2'b10
wire [1:0]	w_wendian		;	//= 2'd2;
wire [1:0]	w_rendian		;	//= 2'd0;
wire [1:0]	w_dualquad		;
wire		w_config_mask	;

wire			w_we		; 
wire			w_re		; 
wire [3:0]		w_wbe	 	;
wire [7:0]		w_command	;
wire [15:0]		w_address	;
wire [31:0]		w_wdata	 	;
reg [31:0]		reg_w_rdata	;

reg [31:0]		reg_wdata 	;
reg [31:0]		reg_rdata	 	;

parameter	C_ADDRESS_MSG_00	= 'h00;
parameter	C_ADDRESS_MSG_01	= 'h01;
parameter	C_ADDRESS_MSG_02	= 'h02;
parameter	C_ADDRESS_MSG_03	= 'h03;
parameter	C_ADDRESS_MSG_04	= 'h04;
parameter	C_ADDRESS_MSG_05	= 'h05;
parameter	C_ADDRESS_MSG_06	= 'h06;
parameter	C_ADDRESS_MSG_07	= 'h07;
parameter	C_ADDRESS_MSG_08	= 'h08;
parameter	C_ADDRESS_MSG_09	= 'h09;
parameter	C_ADDRESS_MSG_0A	= 'h0A;
parameter	C_ADDRESS_MSG_0B	= 'h0B;
parameter	C_ADDRESS_MSG_0C	= 'h0C;
parameter	C_ADDRESS_MSG_0D	= 'h0D;
parameter	C_ADDRESS_MSG_0E	= 'h0E;
parameter	C_ADDRESS_MSG_0F	= 'h0F;
parameter	C_ADDRESS_MSG_10	= 'h10;
parameter	C_ADDRESS_MSG_11	= 'h11;
parameter	C_ADDRESS_MSG_12	= 'h12;
parameter	C_ADDRESS_MSG_13	= 'h13;
parameter	C_ADDRESS_MSG_14	= 'h14;
parameter	C_ADDRESS_MSG_15	= 'h15;
parameter	C_ADDRESS_MSG_16	= 'h16;
parameter	C_ADDRESS_MSG_17	= 'h17;
parameter	C_ADDRESS_MSG_18	= 'h18;
parameter	C_ADDRESS_MSG_19	= 'h19;
parameter	C_ADDRESS_MSG_1A	= 'h1A;
parameter	C_ADDRESS_MSG_1B	= 'h1B;
parameter	C_ADDRESS_MSG_1C	= 'h1C;
parameter	C_ADDRESS_MSG_1D	= 'h1D;
parameter	C_ADDRESS_MSG_1E	= 'h1E;
parameter	C_ADDRESS_MSG_1F	= 'h1F;
parameter	C_ADDRESS_MSG_20	= 'h20;
parameter	C_ADDRESS_MSG_21	= 'h21;
parameter	C_ADDRESS_MSG_30	= 'h30;

//-------------------------------------------------------------------------
// Clock & Reset
//-------------------------------------------------------------------------
wire	SCK_TM;
CLK_MUX I_TMUX_SCK (.A(SCK), .B(TEST_CLK), .S(TE), .Y(SCK_TM));

wire [1:0]	w_SCK_INV;
CLK_INV I_SCK_INV (.A(SCK_TM), .Y(w_SCK_INV[0]));
CLK_MUX I_TMUX_SCK_INV (.A(w_SCK_INV[0]), .B(TEST_CLK), .S(TE), .Y(w_SCK_INV[1]));

wire	SSN_TM;
CLK_MUX I_TMUX_SSN (.A(SSN), .B(TEST_CLK), .S(TE), .Y(SSN_TM));

//-------------------------------------------------------------------------
// Endian Conversion
//-------------------------------------------------------------------------
always @(*) begin
	reg_wdata = 'd0;	
	case(w_wendian)
		2'd0 :	reg_wdata =  w_wdata;
		2'd1 : 	reg_wdata = {w_wdata[23:16],w_wdata[31:24],w_wdata[7:0],w_wdata[15:8]};
		2'd2 :	reg_wdata = {w_wdata[7:0],w_wdata[15:8],w_wdata[23:16],w_wdata[31:24]};
		2'd3 :	reg_wdata = {w_wdata[15:8],w_wdata[7:0],w_wdata[31:24],w_wdata[23:16]};
		default : reg_wdata = w_wdata;
	endcase
end

always @(*) begin
	reg_rdata = 'd0;	
	case(w_rendian)
		2'd0 :	reg_rdata =  reg_w_rdata;
		2'd1 : 	reg_rdata = {reg_w_rdata[23:16],reg_w_rdata[31:24],reg_w_rdata[7:0],reg_w_rdata[15:8]};
		2'd2 :	reg_rdata = {reg_w_rdata[7:0],reg_w_rdata[15:8],reg_w_rdata[23:16],reg_w_rdata[31:24]};
		2'd3 :	reg_rdata = {reg_w_rdata[15:8],reg_w_rdata[7:0],reg_w_rdata[31:24],reg_w_rdata[23:16]};
		default : reg_rdata = reg_w_rdata;
	endcase
end
//-------------------------------------------------------------------------
// Cores
//-------------------------------------------------------------------------
qspi_slave I_QSPI_SLV (
/*input	wire		*/.test_mode		(TE				),
/*input	wire		*/.scan_enable		(SE				),
/*input	wire		*/.resetn			(RESETN			),

/*input  	wire	*/.csn				(SSN			),
/*input  	wire	*/.sck				(SCK_TM			),
/*input	wire		*/.sck_inv			(w_SCK_INV[1]	),

/*input	wire		*/.i_mosi			(MOSI_I			),				
/*output	wire	*/.o_mosi			(MOSI_O			),			//0
/*output	wire	*/.o_mosi_oe		(MOSI_OE		),			//0

/*input	wire		*/.i_miso			(MISO_I			),			//
/*output	wire	*/.o_miso			(MISO_O			),			//O
/*output	wire	*/.o_miso_oe		(MISO_OE		),			//O

/*input	wire		*/.i_wp				(WP_I			),				
/*output	wire	*/.o_wp				(WP_O			),			//0
/*output	wire	*/.o_wp_oe			(WP_OE			),			//0

/*input	wire		*/.i_hold			(HOLD_I			),				
/*output	wire	*/.o_hold			(HOLD_O			),			//0
/*output	wire	*/.o_hold_oe		(HOLD_OE		),			//0

/*output reg		*/.o_we				(w_we			),
/*output reg		*/.o_re				(w_re			),
/*output reg [3:0]	*/.o_wbe			(w_wbe			),
/*output reg [7:0]	*/.o_command		(w_command		),
/*output reg [15:0]	*/.o_address		(w_address		),
/*output reg [31:0]	*/.o_wdata			(w_wdata		),
/*input	wire [31:0]	*/.i_rdata			(reg_rdata		),
/*output reg		*/.config_mask		(w_config_mask	),

/*input	wire [1:0]	*/.i_rcmd_pat		(w_rcmd_pat		),
/*input	wire [1:0]	*/.i_dualquad		(w_dualquad		),
/*input	wire		*/.i_lsb			(w_lsb			),
/*input	wire		*/.i_enable			(w_enable		),
/*input	wire		*/.i_addr_width		(w_addr_width	)//0:8bit,1:16bit	
);
//-------------------------------------------------------------------------
// Registers
//-------------------------------------------------------------------------
always @(posedge SCK_TM or negedge RESETN)
	if(!RESETN) begin
		hv_reg_msg_00	<= 'd0; hv_reg_msg_01	<= 'd0; hv_reg_msg_02	<= 'd0; hv_reg_msg_03	<= 'd0;
		hv_reg_msg_04	<= 'd0; hv_reg_msg_05	<= 'd0; hv_reg_msg_06	<= 'd0; hv_reg_msg_07	<= 'd0;
		hv_reg_msg_08	<= 'd0; hv_reg_msg_09	<= 'd0; hv_reg_msg_10	<= 'd0; hv_reg_msg_11	<= 'd0;
		hv_reg_msg_12	<= 'd0; hv_reg_msg_13	<= 'd0; hv_reg_msg_14	<= 'd0; hv_reg_msg_15	<= 'd0;
		hv_reg_msg_16	<= 'd0; hv_reg_msg_17	<= 'd0; hv_reg_msg_18	<= 'd0; hv_reg_msg_19	<= 'd0;
		hv_reg_msg_20	<= 'd0; hv_reg_msg_21	<= 'd0; hv_reg_msg_22	<= 'd0; hv_reg_msg_23	<= 'd0;
		hv_reg_msg_24	<= 'd0; hv_reg_msg_25	<= 'd0; hv_reg_msg_26	<= 'd0; hv_reg_msg_27	<= 'd0;
		hv_reg_msg_28	<= 'd0; hv_reg_msg_29	<= 'd0; hv_reg_msg_30	<= 'd0; hv_reg_msg_31	<= 'd0;
		hv_reg_msg_32	<= 'd0; hv_reg_msg_33	<= 'd0;
		//Configuration
		hv_reg_msg_00[1]		<= 1'b0;	//wire			w_lsb			= 1'b0;
		hv_reg_msg_00[2]		<= 1'b0;	//wire			w_addr_width	= 1'b0;
		hv_reg_msg_00[5:4]		<= 2'd2;	//wire [1:0]	w_rcmd_pat		= 2'b10;
		hv_reg_msg_00[9:8]		<= 2'd0;	//wire [1:0]	w_dualquad		= 2'd0;
		hv_reg_msg_00[17:16]	<= 2'd2;	//wire [1:0]	w_wendian		= 2'd2;
		hv_reg_msg_00[21:20]	<= 2'b10;	//DS : 2'b00-N/A, 2'b01-4mA, 2'b10-8mA, 2'b11-12mA
		hv_reg_msg_00[25:24]	<= 2'd0;	//wire [1:0]	w_rendian		= 2'd0;
		//SEN_GIO_OE
		hv_reg_msg_01[14]		<= 1'b1;	//input, CP_CLKB
		hv_reg_msg_01[15]		<= 1'b1;	//input, CAP_CAL_CLK
		//Analog Default Value : not zero
		hv_reg_msg_05[20:18] 	<=	3'b100;		//CP_DT_CONT<2:0>
		hv_reg_msg_06[05:00]	<= 6'b100000; 	//HV_BGR_BCONT<5:0>	
		hv_reg_msg_06[08]		<= 1'b1;		//HV_BGR_PSRH
		hv_reg_msg_06[13:10]	<= 4'b0111;		//HV_BGRCAL_REF<3:0>
		hv_reg_msg_06[20:18]	<= 3'b101;		//LDO_AFE_CONT<2:0>
		hv_reg_msg_06[28:24]	<= 3'b011;		//LDO_HVDIG_CONT<4:0>

		hv_reg_msg_07[00]		<= 1'b1;		//SFLR_PD_CH	
		hv_reg_msg_07[01]		<= 1'b1;		//SFLR_PD_REF	
		hv_reg_msg_07[23:02]	<= 22'h3F_FFFF;	//[21:0] SF_PD_CH	
		hv_reg_msg_07[29:24]	<= 6'b000001;	//[5:0] REF_ISET_SELF	
		hv_reg_msg_08[02:00]	<= 3'b001;   	//[2:0] REF_ISET_CA	
		hv_reg_msg_08[05:03]	<= 3'b001;   	//[2:0] REF_ISET_BPF	
		hv_reg_msg_11[31:29]	<= 3'b001;   	//[2:0] REF_ISET_DRV	
		hv_reg_msg_08[07:06]	<= 3'b001;   	//[2:0] REF_ISET_REF	

		hv_reg_msg_09[13]		<= 1'b1;		//SFLR_UNUSED_CH_GND	
		hv_reg_msg_09[16]		<= 1'b1;		//SFLR_PD_CDA		
		hv_reg_msg_09[21]		<= 1'b1;		//SFLR_CCAMODE	

		hv_reg_msg_32[08:06]	<= 3'b111;		//[2:0] SFLR_CONT_RFB_SMALL_CA	
		hv_reg_msg_09[25:22]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB1				
		hv_reg_msg_09[29:26]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB2				
		hv_reg_msg_10[03:00]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB3				
		hv_reg_msg_10[07:04]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB4				
		hv_reg_msg_10[11:08]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB5				
		hv_reg_msg_10[15:12]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB6				
		hv_reg_msg_10[19:16]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB7				
		hv_reg_msg_10[23:20]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB8				
		hv_reg_msg_10[27:24]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB9				
		hv_reg_msg_10[31:28]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB10				
		hv_reg_msg_11[03:00]	<= 4'b0111;    	//[3:0] SFLR_CA_RFB11				
		hv_reg_msg_11[08:04]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB1 				
		hv_reg_msg_11[13:09]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB2 				
		hv_reg_msg_11[18:14]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB3 				
		hv_reg_msg_11[23:19]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB4 				
		hv_reg_msg_11[28:24]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB5 				
		hv_reg_msg_12[04:00]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB6 				
		hv_reg_msg_12[09:05]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB7 				
		hv_reg_msg_12[14:10]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB8 				
		hv_reg_msg_12[19:15]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB9 				
		hv_reg_msg_12[24:20]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB10				
		hv_reg_msg_12[29:25]	<= 5'b01111;  	//[4:0] SFLR_CA_CFB11				

		hv_reg_msg_13[03:00]	<= 4'b1011;		//[3:0] SFLR_BPF_RFB1			
		hv_reg_msg_13[07:04]	<= 4'b1011;    	//[3:0] SFLR_BPF_RFB2			
		hv_reg_msg_13[11:08]	<= 4'b1011;    	//[3:0] SFLR_BPF_RFB3			
		hv_reg_msg_13[20:16]	<= 5'b01010;   	//[4:0] SFLR_BPF_CFB			
		hv_reg_msg_13[15:12]	<= 4'b0001;    	//[3:0] SFLR_DRV_RFB			
		hv_reg_msg_13[22:21]	<= 2'b11;      	//[1:0] SFLR_CONT_CFB_ADCDRV	

		hv_reg_msg_32[00]		<= 1'b1;		//SFLR_TXF1	
		hv_reg_msg_32[01]		<= 1'b1;		//SFLR_VCM_Buffer_CMPCAP	
		hv_reg_msg_32[02]		<= 1'b1;		//SFLR_VCM_Driver_CMPCAP	
		hv_reg_msg_32[05:04]	<= 2'b10;		//[1:0] SFLR_VCM_R_Con	

	end else begin
		if(w_we) begin
			case(w_address[15:2])
				C_ADDRESS_MSG_00 : begin
					if(w_wbe[0])	hv_reg_msg_00[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_00[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_00[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_00[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_01 : begin
					if(w_wbe[0])	hv_reg_msg_01[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_01[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_01[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_01[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_02 : begin
					if(w_wbe[0])	hv_reg_msg_02[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_02[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_02[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_02[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_03 : begin
					if(w_wbe[0])	hv_reg_msg_03[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_03[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_03[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_03[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_04 : begin
					if(w_wbe[0])	hv_reg_msg_04[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_04[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_04[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_04[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_05 : begin
					if(w_wbe[0])	hv_reg_msg_05[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_05[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_05[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_05[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_06 : begin
					if(w_wbe[0])	hv_reg_msg_06[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_06[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_06[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_06[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_07 : begin
					if(w_wbe[0])	hv_reg_msg_07[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_07[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_07[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_07[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_08 : begin
					if(w_wbe[0])	hv_reg_msg_08[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_08[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_08[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_08[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_09 : begin
					if(w_wbe[0])	hv_reg_msg_09[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_09[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_09[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_09[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_0A : begin
					if(w_wbe[0])	hv_reg_msg_10[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_10[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_10[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_10[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_0B : begin
					if(w_wbe[0])	hv_reg_msg_11[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_11[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_11[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_11[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_0C : begin
					if(w_wbe[0])	hv_reg_msg_12[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_12[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_12[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_12[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_0D : begin
					if(w_wbe[0])	hv_reg_msg_13[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_13[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_13[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_13[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_0E : begin
					if(w_wbe[0])	hv_reg_msg_14[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_14[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_14[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_14[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_0F : begin
					if(w_wbe[0])	hv_reg_msg_15[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_15[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_15[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_15[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_10 : begin
					if(w_wbe[0])	hv_reg_msg_16[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_16[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_16[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_16[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_11 : begin
					if(w_wbe[0])	hv_reg_msg_17[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_17[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_17[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_17[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_12 : begin
					if(w_wbe[0])	hv_reg_msg_18[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_18[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_18[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_18[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_13 : begin
					if(w_wbe[0])	hv_reg_msg_19[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_19[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_19[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_19[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_14 : begin
					if(w_wbe[0])	hv_reg_msg_20[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_20[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_20[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_20[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_15 : begin
					if(w_wbe[0])	hv_reg_msg_21[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_21[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_21[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_21[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_16 : begin
					if(w_wbe[0])	hv_reg_msg_22[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_22[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_22[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_22[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_17 : begin
					if(w_wbe[0])	hv_reg_msg_23[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_23[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_23[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_23[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_18 : begin
					if(w_wbe[0])	hv_reg_msg_24[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_24[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_24[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_24[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_19 : begin
					if(w_wbe[0])	hv_reg_msg_25[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_25[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_25[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_25[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_1A : begin
					if(w_wbe[0])	hv_reg_msg_26[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_26[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_26[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_26[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_1B : begin
					if(w_wbe[0])	hv_reg_msg_27[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_27[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_27[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_27[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_1C : begin
					if(w_wbe[0])	hv_reg_msg_28[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_28[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_28[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_28[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_1D : begin
					if(w_wbe[0])	hv_reg_msg_29[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_29[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_29[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_29[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_1E : begin
					if(w_wbe[0])	hv_reg_msg_30[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_30[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_30[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_30[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_1F : begin
					if(w_wbe[0])	hv_reg_msg_31[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_31[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_31[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_31[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_20 : begin
					if(w_wbe[0])	hv_reg_msg_32[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_32[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_32[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_32[31:24]	<= reg_wdata[31:24];
				end
				C_ADDRESS_MSG_21 : begin
					if(w_wbe[0])	hv_reg_msg_33[07:00]	<= reg_wdata[07:00];
					if(w_wbe[1])	hv_reg_msg_33[15:08]	<= reg_wdata[15:08];
					if(w_wbe[2])	hv_reg_msg_33[23:16]	<= reg_wdata[23:16];
					if(w_wbe[3])	hv_reg_msg_33[31:24]	<= reg_wdata[31:24];
				end
				default : begin
				end
			endcase
		end
	end

always @(*) begin
	reg_w_rdata <= 'd0;
	if(w_re) begin
		case(w_address[15:2])
			C_ADDRESS_MSG_00 :	reg_w_rdata <= hv_reg_msg_00;
			C_ADDRESS_MSG_01 :	reg_w_rdata <= hv_reg_msg_01;
			C_ADDRESS_MSG_02 :	reg_w_rdata <= hv_reg_msg_02;
			C_ADDRESS_MSG_03 :	reg_w_rdata <= hv_reg_msg_03;
			C_ADDRESS_MSG_04 :	reg_w_rdata <= hv_reg_msg_04;
			C_ADDRESS_MSG_05 :	reg_w_rdata <= hv_reg_msg_05;
			C_ADDRESS_MSG_06 :	reg_w_rdata <= hv_reg_msg_06;
			C_ADDRESS_MSG_07 :	reg_w_rdata <= hv_reg_msg_07;
			C_ADDRESS_MSG_08 :	reg_w_rdata <= hv_reg_msg_08;
			C_ADDRESS_MSG_09 :	reg_w_rdata <= hv_reg_msg_09;
			C_ADDRESS_MSG_0A :	reg_w_rdata <= hv_reg_msg_10;
			C_ADDRESS_MSG_0B :	reg_w_rdata <= hv_reg_msg_11;
			C_ADDRESS_MSG_0C :	reg_w_rdata <= hv_reg_msg_12;
			C_ADDRESS_MSG_0D :	reg_w_rdata <= hv_reg_msg_13;
			C_ADDRESS_MSG_0E :	reg_w_rdata <= hv_reg_msg_14;
			C_ADDRESS_MSG_0F :	reg_w_rdata <= hv_reg_msg_15;
			C_ADDRESS_MSG_10 :	reg_w_rdata <= hv_reg_msg_16;
			C_ADDRESS_MSG_11 :	reg_w_rdata <= hv_reg_msg_17;
			C_ADDRESS_MSG_12 :	reg_w_rdata <= hv_reg_msg_18;
			C_ADDRESS_MSG_13 :	reg_w_rdata <= hv_reg_msg_19;
			C_ADDRESS_MSG_14 :	reg_w_rdata <= hv_reg_msg_20;
			C_ADDRESS_MSG_15 :	reg_w_rdata <= hv_reg_msg_21;
			C_ADDRESS_MSG_16 :	reg_w_rdata <= hv_reg_msg_22;
			C_ADDRESS_MSG_17 :	reg_w_rdata <= hv_reg_msg_23;
			C_ADDRESS_MSG_18 :	reg_w_rdata <= hv_reg_msg_24;
			C_ADDRESS_MSG_19 :	reg_w_rdata <= hv_reg_msg_25;
			C_ADDRESS_MSG_1A :	reg_w_rdata <= hv_reg_msg_26;
			C_ADDRESS_MSG_1B :	reg_w_rdata <= hv_reg_msg_27;
			C_ADDRESS_MSG_1C :	reg_w_rdata <= hv_reg_msg_28;
			C_ADDRESS_MSG_1D :	reg_w_rdata <= hv_reg_msg_29;
			C_ADDRESS_MSG_1E :	reg_w_rdata <= hv_reg_msg_30;
			C_ADDRESS_MSG_1F :	reg_w_rdata <= hv_reg_msg_31;
			C_ADDRESS_MSG_20 :	reg_w_rdata <= hv_reg_msg_32;
			C_ADDRESS_MSG_21 :	reg_w_rdata <= hv_reg_msg_33;
			C_ADDRESS_MSG_30 : begin
				reg_w_rdata[15:00] 	<= SEN_GPIO_I;
				reg_w_rdata[16] 	<= CAP_CAL_CONT_UP;
				reg_w_rdata[17] 	<= MUX_PHASE_OUT;
				reg_w_rdata[24] 	<= HV_BCONT_GO_UP15;
			end
			default : begin
			end
		endcase
	end
end
//-------------------------------------------------------------------------
// Apply new configuration at next transfer
//-------------------------------------------------------------------------
reg			reg_lsb			;	//= 1'b0;
reg			reg_addr_width	;	//= 1'b0;
reg [1:0]	reg_rcmd_pat	;	//= 2'b10;
reg [1:0]	reg_wendian		;	//= 2'd2;
reg [1:0]	reg_rendian		;	//= 2'd0;
reg [1:0]	reg_dualquad	;
always @(posedge SSN_TM or negedge RESETN)
	if(!RESETN) begin
		reg_lsb			<= 1'b0;
		reg_addr_width	<= 1'b0;
		reg_rcmd_pat	<= 2'd2;
		reg_dualquad	<= 2'd0;
		reg_wendian		<= 2'd2;
		reg_rendian		<= 2'd0;
	end else if((w_config_mask==1'b0)&&(w_address[15:2]==14'h0)) begin
		reg_lsb			<= hv_reg_msg_00[1]	;
		reg_addr_width	<= hv_reg_msg_00[2]	;
		reg_rcmd_pat	<= hv_reg_msg_00[5:4]	;
		reg_dualquad	<= hv_reg_msg_00[9:8]	;
		reg_wendian		<= hv_reg_msg_00[17:16];
		//pad_ds		<= hv_reg_msg_00[21:20];
		//				<= hv_reg_msg_00[23:22];
		reg_rendian		<= hv_reg_msg_00[25:24];
		//dac_clk_sel	<= hv_reg_msg_00[28];
		//dac_clk_delay	<= hv_reg_msg_00[31:29];
	end
assign w_lsb			= reg_lsb		;
assign w_addr_width		= reg_addr_width;
assign w_rcmd_pat		= reg_rcmd_pat	;
assign w_dualquad		= reg_dualquad	;
assign w_wendian		= reg_wendian	;
assign w_rendian		= reg_rendian	;

endmodule
