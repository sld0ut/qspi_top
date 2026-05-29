////////////////////////////////////////////////////////
//
//  Module: spi_mst_model
//  Project: MCUP
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////
`timescale 1ns/10ps

module spi_mst_model (
	input wire	rstb,
	output wire	ss_o,
	output wire	sck_o,
	output wire	mosi_o,
	input wire 	miso_i
);  

wire		miso;
reg			ss;
reg			sck;
reg			mosi;
reg [15:0]	cnt;

reg         clk_main;
reg         start;
reg [7:0]	tdat; //transmit data
reg [1:0]	cdiv=0; //clock divider
wire		sclk;
wire		sdat_in; 	//Serial Data Input from Pin..
wire [6:0]	slave_addr; //Slave Chip Address from ROM..
wire [7:0]	reg_rd_data;//Read Data From Register Map..

wire slv_rx_mlb = 1'b1;
wire slv_tx_mlb = 1'b1;

`ifdef POST_SIM
assign ss_o 	= ss;
assign sck_o 	= sck;
assign mosi_o 	= mosi; // MOSI
assign miso 	= miso_i; // MISO
`else
assign #3 ss_o 	= ss;
assign #3 sck_o = sck;
assign #3 mosi_o= mosi; // MOSI
assign #3 miso 	= miso_i; // MISO
`endif

//parameter PERIOD_SPI_MAIN = (47.61/2.0);		//sclk=21MHz @SPI_CLK=48MHz
parameter PERIOD_SPI_MAIN = ((47.61*4)/2.0);	//sclk=10MHz @SPI_CLK=48MHz

`ifdef POST_SIM
parameter jitter = 1;
`else
parameter jitter = 5;
`endif

initial begin
	#12 clk_main = 0;
	#(PERIOD_SPI_MAIN/2.0) clk_main = 1;
	forever
	fork
		#(PERIOD_SPI_MAIN/2.0+$random%(jitter-1)) clk_main = ~clk_main;
	join
end

wire clk = clk_main;

integer d;

task SPI_START;
	integer st_i;
	begin
		for(st_i=0;st_i<32;st_i=st_i+1) @(posedge clk);
			ss<=0;
		for(st_i=0;st_i<2;st_i=st_i+1) @(posedge clk);
			sck<=0;mosi<=0;
		for(st_i=0;st_i<3;st_i=st_i+1)@(posedge clk);
	end
endtask

task SPI_STOP;
	integer so_i;
	begin
		for(so_i=0;so_i<3;so_i=so_i+1) @(posedge clk);
			sck<=0;mosi<=0;
		for(so_i=0;so_i<2;so_i=so_i+1) @(posedge clk);
			ss<=1;
		for(so_i=0;so_i<32;so_i=so_i+1) @(posedge clk);
		#10000;
	end
endtask

task SPI_STOP_NODELAY;
	integer so_i;
	begin
		for(so_i=0;so_i<3;so_i=so_i+1) @(posedge clk);
			sck<=0;mosi<=0;
		for(so_i=0;so_i<2;so_i=so_i+1) @(posedge clk);
			ss<=1;
		for(so_i=0;so_i<32;so_i=so_i+1) @(posedge clk);
	end
endtask

//integer j;
reg [7:0] tdata;
task SPI_BREAD;
	output [7:0] dataout;
	integer r_i;
	integer r_j;
	begin
		if (slv_tx_mlb) begin // msb first
			for(r_i=0;r_i<8;r_i=r_i+1) begin
				sck<=0;
				case(cdiv)
					2'd0: for(r_j=0;r_j<1;r_j=r_j+1) @(posedge clk);
					2'd1: for(r_j=0;r_j<3;r_j=r_j+1) @(posedge clk);
					2'd2: for(r_j=0;r_j<5;r_j=r_j+1) @(posedge clk);
					2'd3: for(r_j=0;r_j<7;r_j=r_j+1) @(posedge clk);
				endcase

				sck<=1;
				dataout[7-r_i]=miso;
				case(cdiv)
					2'd0: for(r_j=0;r_j<1;r_j=r_j+1) @(posedge clk);
					2'd1: for(r_j=0;r_j<3;r_j=r_j+1) @(posedge clk);
					2'd2: for(r_j=0;r_j<5;r_j=r_j+1) @(posedge clk);
					2'd3: for(r_j=0;r_j<7;r_j=r_j+1) @(posedge clk);
				endcase
			end
		end else begin // lsb first
			for(r_i=0;r_i<8;r_i=r_i+1) begin
				sck<=0;
				case(cdiv)
					2'd0: for(r_j=0;r_j<1;r_j=r_j+1) @(posedge clk);
					2'd1: for(r_j=0;r_j<3;r_j=r_j+1) @(posedge clk);
					2'd2: for(r_j=0;r_j<5;r_j=r_j+1) @(posedge clk);
					2'd3: for(r_j=0;r_j<7;r_j=r_j+1) @(posedge clk);
				endcase

				sck<=1;
				dataout[r_i]=miso;
				case(cdiv)
					2'd0: for(r_j=0;r_j<1;r_j=r_j+1) @(posedge clk);
					2'd1: for(r_j=0;r_j<3;r_j=r_j+1) @(posedge clk);
					2'd2: for(r_j=0;r_j<5;r_j=r_j+1) @(posedge clk);
					2'd3: for(r_j=0;r_j<7;r_j=r_j+1) @(posedge clk);
				endcase
			end
		end
				sck<=0;
	//      $display($stime, " ns : SPI read end (%02x)",dataout);
	end
endtask

task SPI_BWRITE;
	input [7:0] datain;
	reg spi_wait;
	integer w_i;
	integer w_j;
	begin
		$display($stime, " ns : SPI write start (%02x)",datain);
		if (slv_rx_mlb) begin // msb first
			for(w_i=0;w_i<8;w_i=w_i+1) begin
				sck<=0;
				mosi<=datain[7-w_i];
				case(cdiv)
					2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
					2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
					2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
					2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
				endcase

				sck<=1;
				case(cdiv)
					2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
					2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
					2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
					2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
				endcase
			end
		end else begin // lsb first
			for(w_i=0;w_i<8;w_i=w_i+1) begin
				sck<=0;
				mosi<=datain[w_i];
				case(cdiv)
					2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
					2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
					2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
					2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
				endcase

				sck<=1;
				case(cdiv)
					2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
					2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
					2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
					2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
				endcase
			end
		end
		sck<=0;
	end
endtask

task SPI_CLOCK;
	integer w_i;
	integer w_j;
	begin
	//$display($stime, " ns : SPI write start (%02x)",datain);
		for(w_i=0;w_i<8;w_i=w_i+1) begin
			sck<=0;
			case(cdiv)
				2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
				2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
				2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
				2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
			endcase

			sck<=1;
			case(cdiv)
				2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
				2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
				2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
				2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
			endcase
		end 
		sck<=0;
	end
endtask

task SPI_RESET;
	integer w_i;
	integer w_j;
	begin
		ss<=1;
		for(w_i=0;w_i<8;w_i=w_i+1) begin
			mosi<=0;
			case(cdiv)
				2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
				2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
				2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
				2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
			endcase

			mosi<=1;
			case(cdiv)
				2'd0: for(w_j=0;w_j<1;w_j=w_j+1) @(posedge clk);
				2'd1: for(w_j=0;w_j<3;w_j=w_j+1) @(posedge clk);
				2'd2: for(w_j=0;w_j<5;w_j=w_j+1) @(posedge clk);
				2'd3: for(w_j=0;w_j<7;w_j=w_j+1) @(posedge clk);
			endcase
		end 
		mosi<=0;
	end
endtask

reg [7:0]	spi_byte;

initial begin
	ss=1;
	sck=0;
	mosi=0;
	cnt=0;

	#8000000;

	SPI_START;
	SPI_BWRITE(8'h51);
	SPI_BWRITE(8'h00);
	SPI_BWRITE(8'h12);
	SPI_BWRITE(8'h34);
	SPI_BWRITE(8'h56);
	SPI_BWRITE(8'h78);
	SPI_STOP_NODELAY;
	//read status command
	SPI_START;
	SPI_BWRITE(8'h05);
	SPI_BWRITE(8'h00);
	for(d=0;d<4;d=d+1) begin
		SPI_BREAD(spi_byte); $display($stime, " ns : %02h", spi_byte);
	end
	SPI_STOP;

	//
	SPI_START;
	SPI_BWRITE(8'h51);
	SPI_BWRITE(8'h00);
	SPI_BWRITE(8'h9a);
	SPI_BWRITE(8'hbc);
	SPI_BWRITE(8'hde);
	SPI_BWRITE(8'hf1);
	SPI_STOP;
	//
	SPI_START;
	SPI_BWRITE(8'h0B);
	SPI_BWRITE(8'h00);
	for(d=0;d<120;d=d+1) begin
		SPI_BREAD(spi_byte); $display($stime, " ns : (%03d) %02h", d, spi_byte);
	end
	SPI_STOP;


`ifdef FW_TEST
	#5000
	$finish;
`endif
end

endmodule
