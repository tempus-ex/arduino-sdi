/*
* Copyright 2018 ARDUINO SA (http://www.arduino.cc/)
* This file is part of Vidor IP.
* Copyright (c) 2018
* Authors: Dario Pennisi
*
* This software is released under:
* The GNU General Public License, which covers the main part of 
* Vidor IP
* The terms of this license can be found at:
* https://www.gnu.org/licenses/gpl-3.0.en.html
*
* You can be released from the requirements of the above licenses by purchasing
* a commercial license. Buying such a license is mandatory if you want to modify or
* otherwise use the software for commercial activities involving the Arduino
* software without disclosing the source code of your own applications. To purchase
* a commercial license, send an email to license@arduino.cc.
*
*/

module MKRVIDOR4000_top
(
  // system signals
  input         iCLK,
  input         iRESETn,
  input         iSAM_INT,
  output        oSAM_INT,
  
  // SDRAM
  output        oSDRAM_CLK,
  output [11:0] oSDRAM_ADDR,
  output [1:0]  oSDRAM_BA,
  output        oSDRAM_CASn,
  output        oSDRAM_CKE,
  output        oSDRAM_CSn,
  inout  [15:0] bSDRAM_DQ,
  output [1:0]  oSDRAM_DQM,
  output        oSDRAM_RASn,
  output        oSDRAM_WEn,

  // SAM D21 PINS
  inout         bMKR_AREF,
  inout  [6:0]  bMKR_A,
  inout  [14:0] bMKR_D,
  
  // Mini PCIe
  inout         bPEX_RST,
  inout         bPEX_PIN6,
  inout         bPEX_PIN8,
  inout         bPEX_PIN10,
  input         iPEX_PIN11,
  inout         bPEX_PIN12,
  input         iPEX_PIN13,
  inout         bPEX_PIN14,
  inout         bPEX_PIN16,
  inout         bPEX_PIN20,
  input         iPEX_PIN23,
  input         iPEX_PIN25,
  inout         bPEX_PIN28,
  inout         bPEX_PIN30,
  input         iPEX_PIN31,
  inout         bPEX_PIN32,
  input         iPEX_PIN33,
  inout         bPEX_PIN42,
  inout         bPEX_PIN44,
  inout         bPEX_PIN45,
  inout         bPEX_PIN46,
  inout         bPEX_PIN47,
  inout         bPEX_PIN48,
  inout         bPEX_PIN49,
  inout         bPEX_PIN51,

  // NINA interface
  inout         bWM_PIO1,
  inout         bWM_PIO2,
  inout         bWM_PIO3,
  inout         bWM_PIO4,
  inout         bWM_PIO5,
  inout         bWM_PIO7,
  inout         bWM_PIO8,
  inout         bWM_PIO18,
  inout         bWM_PIO20,
  inout         bWM_PIO21,
  inout         bWM_PIO27,
  inout         bWM_PIO28,
  inout         bWM_PIO29,
  inout         bWM_PIO31,
  input         iWM_PIO32,
  inout         bWM_PIO34,
  inout         bWM_PIO35,
  inout         bWM_PIO36,
  input         iWM_TX,
  inout         oWM_RX,
  inout         oWM_RESET,

  // HDMI output
  output [2:0]  oHDMI_TX,
  output        oHDMI_CLK,

  inout         bHDMI_SDA,
  inout         bHDMI_SCL,
  
  input         iHDMI_HPD,
  
  // MIPI input
  input  [1:0]  iMIPI_D,
  input         iMIPI_CLK,
  inout         bMIPI_SDA,
  inout         bMIPI_SCL,
  inout  [1:0]  bMIPI_GP,

  // Q-SPI Flash interface
  output        oFLASH_SCK,
  output        oFLASH_CS,
  inout         oFLASH_MOSI,
  inout         iFLASH_MISO,
  inout         oFLASH_HOLD,
  inout         oFLASH_WP

);

// signal declaration

wire wCLK1485;
wire wOSC_CLK;
wire wCLK8, wCLK24, wCLK120;
wire wMEM_CLK;

assign wCLK8 = iCLK;
assign wCLK1485 = iPEX_PIN31;
assign wLOCKED = iPEX_PIN33;

wire wLOCKED;

// internal oscillator
cyclone10lp_oscillator   osc
  ( 
  .clkout(wOSC_CLK),
  .oscena(1'b1));

// system PLL
SYSTEM_PLL PLL_inst(
  .areset(1'b0),
  .inclk0(wCLK8),
  .c0(wCLK24),
  .c1(wCLK120),
  .c2(wMEM_CLK),
   .c3(oSDRAM_CLK),
  .c4(wFLASH_CLK),
   
  .locked());

// logic

reg [9:0] data;

assign bPEX_PIN45 = 1; // reset disable
assign bPEX_PIN47 = 0; // anc blanking
assign bPEX_PIN49 = 1; // smpte mode
assign bPEX_PIN51 = 1; // io processing
assign bPEX_PIN44 = wCLK1485;
assign bPEX_PIN48 = 0; // not ddr
assign bPEX_PIN16 = data[0];
assign bPEX_PIN6  = data[1];
assign bPEX_PIN46 = data[2];
assign bPEX_PIN8  = data[3];
assign bPEX_PIN20 = data[4];
assign bPEX_PIN10 = data[5];
assign bPEX_PIN28 = data[6];
assign bPEX_PIN12 = data[7];
assign bPEX_PIN14 = data[8];
assign bPEX_PIN42 = data[9];

// We're going to output a 1080p30 signal.
// That's 30 frames per second, with 1125 lines per frame and 4400 10-bit words per line.
// 30 * 1125 * 4400 / 10 = 1.485 MHz

reg [15:0] frame_counter; // counts indefinitely
reg [11:0] line_counter; // counts from 0 to 1124
reg [15:0] line_word_counter; // counts from 0 to 4399

// Flash the LED so we know we're running. ~1Hz if the serializer is LOCKED, slower otherwise.
assign bMKR_D[6] = wLOCKED ? frame_counter[5] : frame_counter[7];

// The serializer reads data on the positive PCLK edge, so we'll do our updates on the negative edge.
always @(negedge wCLK1485) begin
	case (line_word_counter)
		12'd0, 12'd1, 12'd552, 12'd553:
			// SAV/EAV word 0
			data<=10'h3ff;
		12'd2, 12'd3, 12'd4, 12'd5, 12'd554, 12'd555, 12'd556, 12'd557:
			// SAV/EAV word 1/2
			data<=10'h0;
		12'd6, 12'd7:
			// EAV word 3
			data<=line_counter < 12'd1080 ? 10'b1001110100 : 10'b1011011000;
		12'd558, 12'd559:
			// SAV word 3
			data<=line_counter < 12'd1080 ? 10'b1000000000 : 10'b1010101100;
		default:
			// Blanking interval or active picture. If this is the blanking interval, the value here is ignored by the serializer since we set ANC_BLANK to low.
			// The luma will be constant, but we'll toggle the chroma with the LED.
			data<=line_word_counter[0] ? 10'h200 : (frame_counter[5] ? 10'h80 : 10'h37f);
	endcase

	// Tick up counters.
	if (line_word_counter==16'd4399) begin
		line_word_counter<=16'h0;
		if (line_counter==12'd1124) begin
			line_counter<=12'h0;
			frame_counter<=frame_counter+16'h1;
		end else begin
			line_counter<=line_counter+12'h1;
		end;
	end else begin
		line_word_counter<=line_word_counter+16'h1;
	end
end

endmodule
