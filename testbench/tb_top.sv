//`timescale 1ns/1ps
`include "../design/axi_dut.sv"
`include "axi4_interface.sv"
`include "axi_sva.sv"

module tb_top;

    import uvm_pkg::*;
    import axi_pkg::*;
    `include "uvm_macros.svh"

    logic ACLK;

        axi4_slave_interface #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH))axi_if (.ACLK(ACLK));

		axi4_lite_slave dut (
			.ACLK(ACLK),.ARESETn(axi_if.ARESETn),
			.AWADDR(axi_if.AWADDR),.AWPROT(axi_if.AWPROT),.AWVALID(axi_if.AWVALID),.AWREADY(axi_if.AWREADY),// Write Address Channel
			.WDATA(axi_if.WDATA),.WSTRB(axi_if.WSTRB),.WVALID(axi_if.WVALID),.WREADY(axi_if.WREADY),// Write Data Channel
			.BRESP(axi_if.BRESP),.BVALID(axi_if.BVALID),.BREADY(axi_if.BREADY),// Write Response Channel
			.ARADDR(axi_if.ARADDR),.ARPROT(axi_if.ARPROT),.ARVALID(axi_if.ARVALID),.ARREADY(axi_if.ARREADY),// Read Address Channel
			.RDATA(axi_if.RDATA),.RRESP(axi_if.RRESP),.RVALID(axi_if.RVALID),.RREADY(axi_if.RREADY)// Read Data Channel
		);

        //need to bind assertions here
		bind axi4_lite_slave axi4_lite_assertions#(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH))axi_assertions(
			.ACLK(ACLK),.ARESETn(ARESETn),
			.AWADDR(AWADDR),.AWPROT(AWPROT),.AWVALID(AWVALID),.AWREADY(AWREADY),
			.WDATA(WDATA),.WSTRB(WSTRB),.WVALID(WVALID),.WREADY(WREADY),
			.BRESP(BRESP),.BVALID(BVALID),.BREADY(BREADY),
			.ARADDR(ARADDR),.ARPROT(ARPROT),.ARVALID(ARVALID),.ARREADY(ARREADY),
			.RDATA(RDATA),.RRESP(RRESP),.RVALID(RVALID),.RREADY(RREADY)
		);



        initial begin
                ACLK = 0;
                forever #5 ACLK = ~ACLK;
    end

        initial begin
        axi_if.ARESETn = 0;
        repeat(5) @(posedge ACLK);
        axi_if.ARESETn = 1;
        `uvm_info("TB_TOP","INITIAL Reset Deasserted",UVM_LOW);
//        repeat(50) @(posedge ACLK);
  //              dut_reset();
    end

        task dut_reset();
                axi_if.ARESETn = 0;
                repeat(3) @(posedge ACLK);
        axi_if.ARESETn = 1;
        endtask

    initial begin

                uvm_top.set_timeout(100000ns);
            uvm_config_db#(virtual axi4_slave_interface.DRV_MOD)::set(null,"*","drv_vif",axi_if);
                uvm_config_db#(virtual axi4_slave_interface.MON_MOD)::set(null,"*","mon_vif",axi_if);

        run_test();
    end
	initial begin
		    $fsdbDumpfile("wave.fsdb");
		    $fsdbDumpvars(0, tb_top);
	end
endmodule

