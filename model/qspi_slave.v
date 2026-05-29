
module qspi_slave (
	input	wire			test_mode		,
	input	wire			scan_enable		,
	input	wire			resetn			,

	input  	wire 			csn				,
	input  	wire 			sck				,
	input	wire			sck_inv			,

	input	wire			i_mosi			,				
	output	reg				o_mosi			,			//0
	output	reg				o_mosi_oe		,			//0

	input	wire			i_miso			,			//
	output	reg				o_miso			,			//O
	output	reg				o_miso_oe		,			//O

	input	wire			i_wp			,				
	output	reg				o_wp			,			//0
	output	reg				o_wp_oe			,			//0

	input	wire			i_hold			,				
	output	reg				o_hold			,			//0
	output	reg				o_hold_oe		,			//0

	output wire				o_we			,
	output wire				o_re			,
	output wire [3:0]		o_wbe			,
	output wire [7:0]		o_command		,
	output reg [15:0]		o_address		,
	output wire [31:0]		o_wdata			,
	input wire [31:0]		i_rdata			,
	output wire				config_mask		,

	input	wire [1:0]		i_rcmd_pat		,
	input	wire [1:0]		i_dualquad		,
	input	wire			i_lsb	,
	input	wire			i_enable	,
	input	wire			i_addr_width	 //0:8bit,1:16bit	
);

//-----------------------------------------------------------------------------
// Parameter & Wire & Register Definition
//-----------------------------------------------------------------------------
parameter [2:0] STATE_IDLE      = 3'h0,
				STATE_CMD		= 3'h1,
                STATE_ADDR_H 	= 3'h2,
                STATE_ADDR_L 	= 3'h3,
                STATE_DATA	 	= 3'h4;

reg				reg_we			;
reg				reg_re			;
reg [3:0]		reg_wbe			;
reg [7:0]		reg_command		;
reg [31:0]		reg_wdata		;
reg				reg_config_mask	;

reg 	[7:0] 	reg_input_shift;		//8bit shift register
reg		[7:0]	reg_output_shift;		//8bit shift register

reg 	[2:0] 	reg_bit_cnt			;
reg 	[1:0] 	reg_byte_cnt		;
reg       		reg_load			;		
reg				reg_start			;
//FSM
reg		[2:0]	reg_state			;
//

wire			w_sel_idle			;
wire			w_sel_spi			;
wire			w_state_cmd			;
wire			w_sel_start			;
wire			w_reset				;
wire			w_reset_p			;

reg			reg_first_word;
reg [15:0]	reg_address;

//-----------------------------------------------------------------------------
// Operation Process
//-----------------------------------------------------------------------------
assign		w_sel_spi	= i_enable ;

//assign 		clk 	= i_cpol ^ i_cpha ^ sck;
assign		w_state_cmd			= reg_state == STATE_CMD ;
assign		w_sel_idle			= csn || ~w_sel_spi ;
assign		w_sel_start	        = ~reg_start && ~csn  ;

//assign	w_reset				= test_mode ? resetn : ~csn & resetn		;
assign		w_reset_p			= ~csn & resetn		;
CLK_MUX I_TMUX_RSTB (.A(w_reset_p), .B(resetn), .S(test_mode), .Y(w_reset));

wire wr_mode	= (reg_command[5:4]==i_rcmd_pat) ? 1'b0 : 1'b1;
wire rd_mode	= (reg_command[5:4]==i_rcmd_pat) ? 1'b1 : 1'b0;
//-----------------------------------------------------------------------------
// generate input shift registers
//-----------------------------------------------------------------------------
always @(negedge resetn or posedge sck)
	if(~resetn) begin
		reg_input_shift	<= #1 'd0;
	end else begin
		if(i_dualquad==2'b01) begin
			reg_input_shift	<= #1 i_lsb ?	{i_mosi,i_miso,reg_input_shift[7:2]}:
											{reg_input_shift[5:0],i_miso,i_mosi};
		end else if(i_dualquad==2'b10) begin
			reg_input_shift	<= #1 i_lsb ?	{i_mosi,i_miso,i_wp,i_hold,reg_input_shift[7:4]}:
											{reg_input_shift[3:0],i_hold,i_wp,i_miso,i_mosi};
		end else begin
			reg_input_shift	<= #1 i_lsb ?	{i_mosi,reg_input_shift[7:1]}:
											{reg_input_shift[6:0],i_mosi};
		end
		//COMMAND : single only
		if((reg_state==STATE_CMD)&&(reg_bit_cnt!=0)) begin
				reg_input_shift	<= #1 i_lsb ?	{i_mosi,reg_input_shift[7:1]}:
												{reg_input_shift[6:0],i_mosi};
		end
	end

//-----------------------------------------------------------------------------
// generate output shift registers
//-----------------------------------------------------------------------------
reg		reg_oe;
always @(negedge w_reset or posedge sck_inv)  // reg_output_shift[4:0] unsync.
begin
	if(~w_reset) begin
  		reg_output_shift	<= #1  8'h0;
		reg_oe <= #1 1'b0;
	end else begin
		reg_oe <= #1 1'b0;
		if(rd_mode) begin
			if(reg_state==STATE_CMD) begin
				reg_oe <= #1 1'b0;
			end else begin
				if(reg_bit_cnt==3'h0) begin
					if((reg_state==STATE_ADDR_L)||(reg_state==STATE_DATA)) begin
						reg_oe <= #1 1'b1;
						if(reg_byte_cnt==0)		reg_output_shift <= #1  i_rdata[07:00];
						else if(reg_byte_cnt==1)	reg_output_shift <= #1  i_rdata[15:08];
						else if(reg_byte_cnt==2)	reg_output_shift <= #1  i_rdata[23:16];
						else if(reg_byte_cnt==3)	reg_output_shift <= #1  i_rdata[31:24];
					end
				end else begin
					if(reg_state==STATE_DATA) begin
						reg_oe <= #1 1'b1;
						if(i_dualquad==2'b01) begin
							reg_output_shift <= #1  i_lsb ? {2'b0,reg_output_shift[7:2]} : {reg_output_shift[5:0],2'b0};
						end else if(i_dualquad==2'b10) begin
							reg_output_shift <= #1  i_lsb ? {4'b0,reg_output_shift[7:4]} : {reg_output_shift[4:0],4'b0};
						end else begin
							reg_output_shift <= #1  i_lsb ? {1'b0,reg_output_shift[7:1]} : {reg_output_shift[6:0],1'b0};
						end
					end
				end
			end
		end else begin
			reg_oe <= #1 1'b0;
		end
	end
end
//-----------------------------------------------------------------------------
//generate bit-counter
//-----------------------------------------------------------------------------
always @(negedge w_reset or posedge sck)
begin
  if(~w_reset) begin
    reg_bit_cnt <= #1  3'b0;
  end else begin
		if(reg_state == STATE_CMD) begin
    		reg_bit_cnt <= #1  reg_bit_cnt + 3'h1;
		end else begin
			if(i_dualquad==2'b01) begin
				if(reg_bit_cnt==3'd3) begin
					reg_bit_cnt <= #1 'd0;
				end else begin
    				reg_bit_cnt <= #1  reg_bit_cnt + 3'h1;
				end
			end else if(i_dualquad==2'b10) begin
				if(reg_bit_cnt==3'd1) begin
					reg_bit_cnt <= #1 'd0;
				end else begin
    				reg_bit_cnt <= #1  reg_bit_cnt + 3'h1;
				end
			end else begin
    				reg_bit_cnt <= #1  reg_bit_cnt + 3'h1;
			end
		end
  end
end

//generate access done signal
always @(negedge resetn or posedge sck)
begin
	if(~resetn) begin
		reg_load <= #1  1'b0;
		reg_config_mask <= #1  1'b0;
	end else begin
		if(reg_state == STATE_CMD) begin
				reg_load <= #1 1'b0;
				if(reg_bit_cnt==7) begin
					//check COMMAND = 0x3C for write done
					if(	((i_lsb==1'b0)&&(reg_input_shift[4:1]==4'hF)) ||
						((i_lsb==1'b1)&&(reg_input_shift[6:3]==4'hF))
					) begin
						reg_load <= #1 1'b0;
						reg_config_mask <= #1 1'b0;
					end else begin
						reg_load <= #1 1'b1;
					end
				end
		end else begin
			if(reg_state == STATE_ADDR_L) begin
				if(({reg_address[15:08],reg_input_shift[7:2]}==14'h0)&&reg_bit_cnt==0) begin
					reg_config_mask <= #1 1'b1;
				end
			end
			if(i_dualquad==2'b01) begin
				reg_load <= #1  (reg_bit_cnt==3) ? 1'b1 : 1'b0;
			end else if(i_dualquad==2'b10) begin
				reg_load <= #1  (reg_bit_cnt==1) ? 1'b1 : 1'b0;
			end else begin
				reg_load <= #1  (reg_bit_cnt==7) ? 1'b1 : 1'b0;
			end
		end
	end
end

//--------------------------------------------------------------------------
// FSM
//-----------------------------------------------------------------------------
always @ (negedge w_reset or posedge sck )  // reg_start, reg_state unsync.
begin
    if (~w_reset) begin
        reg_state <= #1 STATE_IDLE;
		reg_start <= #1 1'b0;
	end	else if(w_sel_idle) begin
	  	reg_state <= #1 STATE_IDLE;
		reg_start <= #1 1'b0;
	end else if (w_sel_start) begin
        reg_state <= #1 STATE_CMD ;
		reg_start <= #1 1'b1;
	end else if (reg_load) begin
        case (reg_state)
        	STATE_CMD:  begin
        		reg_state <= #1 i_addr_width ? STATE_ADDR_H : STATE_ADDR_L;
			end
        	STATE_ADDR_H:  begin
        	    reg_state <= #1 STATE_ADDR_L ;
			end
        	STATE_ADDR_L:  begin
        	    reg_state <= #1 STATE_DATA;
			end
        	STATE_DATA: begin
        	    reg_state <= #1 STATE_DATA;
			end
			default   : begin
        	    reg_state <= #1 STATE_IDLE;
			end
        endcase
    end
end

//-----------------------------------------------------------------------------
// Output 
//-----------------------------------------------------------------------------
always @ (negedge resetn or posedge sck )
	if(!resetn) begin
		reg_we		<= #1 'd0;
		reg_wbe		<= #1 'd0;
    	reg_byte_cnt	<= #1 'd0;
	end else begin
		reg_we		<= #1 'd0;
		reg_wbe		<= #1 'd0;
		if((csn==1'b0) && (reg_bit_cnt==0)) begin
			if(reg_state==STATE_ADDR_L) begin
				reg_byte_cnt <= #1 reg_input_shift[1:0];
				if(rd_mode) begin
    				reg_byte_cnt	<= #1 reg_byte_cnt+1;
				end
			end else if((reg_state==STATE_IDLE&&reg_load)||	//previous transfer
						(reg_state==STATE_DATA)			//current transfer
			)begin
				if(wr_mode) begin
					reg_we		<= #1 'd1;
					if(reg_byte_cnt==0)			reg_wbe <= #1 4'b0001;
					else if(reg_byte_cnt==1)	reg_wbe <= #1 4'b0010;
					else if(reg_byte_cnt==2)	reg_wbe <= #1 4'b0100;
					else if(reg_byte_cnt==3)	reg_wbe <= #1 4'b1000;
				end else begin
					reg_we	<= #1 'd0;
					reg_wbe	<= #1 'd0;
				end
    			reg_byte_cnt	<= #1 reg_byte_cnt+1;
			end else begin
    			reg_byte_cnt	<= #1 'd0;
			end
		end
	end

always @(*) begin
	reg_re <= 1'b0;
	if(rd_mode&&(csn==1'b0)) begin
		if((reg_state==STATE_ADDR_L)||(reg_state==STATE_DATA)) begin
			reg_re <= reg_load;
		end
	end
end

always @ (negedge resetn or posedge sck )
	if(!resetn) begin
		reg_command	<= #1 'd0;
		reg_address	<= #1 'd0;
		reg_wdata	<= #1 'd0;
		reg_first_word	<= #1 1'b1;
	end else begin
		if((csn==1'b0) && (reg_bit_cnt==0)) begin
			if((reg_state==STATE_CMD)) begin
				reg_command		<= #1 reg_input_shift;
			end else if(reg_state==STATE_ADDR_H) begin
				reg_first_word <= #1 1'b1;
				if(i_lsb) begin
					reg_address[07:00]<= #1 reg_input_shift;
				end else begin
					reg_address[15:08]<= #1 reg_input_shift;
				end
			end else if(reg_state==STATE_ADDR_L) begin
				reg_first_word <= #1 1'b1;
				if(i_lsb&&i_addr_width) begin
					reg_address[15:08]<= #1 reg_input_shift;
				end else begin
					reg_address[07:00]<= #1 reg_input_shift;
				end
			end else if((reg_state==STATE_IDLE&&reg_load)||	//previous transfer
						(reg_state==STATE_DATA)			//current transfer
				) begin
				if(reg_byte_cnt==0)			reg_wdata[31:24] <= #1 reg_input_shift;
				else if(reg_byte_cnt==1)	reg_wdata[23:16] <= #1 reg_input_shift;
				else if(reg_byte_cnt==2)	reg_wdata[15:08] <= #1 reg_input_shift;
				else if(reg_byte_cnt==3)	reg_wdata[07:00] <= #1 reg_input_shift;

				if(reg_first_word) begin
					if(wr_mode&&(reg_byte_cnt==3)) begin
						reg_first_word <= #1 1'b0;
					end else if(rd_mode&&(reg_byte_cnt==2)) begin
						reg_first_word <= #1 1'b0;
					end
				end

				if(reg_first_word==1'b0) begin
					if(wr_mode&&(reg_byte_cnt==0)) begin
						reg_address	<= #1 reg_address+4;
					end else if(rd_mode&&(reg_byte_cnt==3)) begin
						reg_address	<= #1 reg_address+4;
					end
				end
			end
		end
	end

always @(*) begin
	o_address <= reg_address;
	if(i_lsb&&i_addr_width) begin
		o_address <= reg_address;
	end else if(reg_re&&(reg_state==STATE_ADDR_L)) begin
		o_address <= {reg_address[15:08],reg_input_shift};
	end
end

always @(*) begin
	o_mosi_oe	<= 1'b0;
	o_miso_oe	<= 1'b0;
	o_wp_oe		<= 1'b0;
	o_hold_oe	<= 1'b0;
	if(reg_oe) begin
		if(i_dualquad==2'b01) begin
			o_mosi_oe	<= 1'b1;
			o_miso_oe	<= 1'b1;
		end else if(i_dualquad==2'b10) begin
			o_mosi_oe	<= 1'b1;
			o_miso_oe	<= 1'b1;
			o_wp_oe		<= 1'b1;
			o_hold_oe	<= 1'b1;
		end else begin
			o_miso_oe	<= 1'b1;
		end
	end
end

always @(*) begin
	o_mosi 	<= 1'b0;
	o_miso 	<= 1'b0;
	o_wp	<= 1'b0;
	o_hold 	<= 1'b0;
	if(i_dualquad==2'b01) begin
		o_mosi	<= i_lsb ? reg_output_shift[1] : reg_output_shift[6];
		o_miso	<= i_lsb ? reg_output_shift[0] : reg_output_shift[7];
	end else if(i_dualquad==2'b10) begin
		o_mosi	<= i_lsb ? reg_output_shift[3] : reg_output_shift[4];
		o_miso	<= i_lsb ? reg_output_shift[2] : reg_output_shift[5];
		o_wp	<= i_lsb ? reg_output_shift[1] : reg_output_shift[6];;
		o_hold	<= i_lsb ? reg_output_shift[0] : reg_output_shift[7];;
	end else begin
		o_miso	<= i_lsb ? reg_output_shift[0] : reg_output_shift[7];
	end
end

assign o_we			= reg_we;
assign o_re			= reg_re;
assign o_wbe		= reg_wbe;
assign o_command	= reg_command;
assign o_wdata		= reg_wdata;
assign config_mask	= reg_config_mask;

endmodule

