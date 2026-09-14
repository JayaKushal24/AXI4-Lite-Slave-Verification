package axi_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	parameter ADDR_WIDTH=32;
	parameter DATA_WIDTH=32;

	`include "axi_config.sv"
	`include "axi_seq_item.sv"
	`include "axi_sequencer.sv"
	`include "axi_driver.sv"
	`include "axi_monitor.sv"
	`include "axi_agent.sv"
	`include "axi_subscriber.sv"
	`include "axi_scoreboard.sv"
	`include "axi_environment.sv"
	`include "axi_sequence.sv"
	`include "axi_test.sv"
endpackage
