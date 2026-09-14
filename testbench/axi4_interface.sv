interface  axi4_slave_interface#(parameter ADDR_WIDTH=32,parameter DATA_WIDTH=32)(input  ACLK);
	
	logic	ARESETn;
	logic	[ADDR_WIDTH-1:0]	AWADDR;
	logic	[2:0]	AWPROT;
    logic	AWVALID,AWREADY;
	
	logic	[DATA_WIDTH-1:0]	WDATA;
    logic	[(DATA_WIDTH/8)-1:0]WSTRB;
	logic	WVALID,WREADY;

    logic	[1:0]BRESP;
	logic	BVALID,BREADY;

    logic	[ADDR_WIDTH-1:0]ARADDR;
    logic	[2:0]ARPROT;
	logic	ARVALID,ARREADY;
	
	logic	[DATA_WIDTH-1:0]	RDATA;
	logic	[1:0]	RRESP;
	logic	RVALID,RREADY;


	clocking drv_cb@(posedge ACLK);
		default input #1step output #1;
		input ARESETn;
		output AWADDR,AWPROT;
		inout AWVALID;
		input AWREADY;
		output WDATA,WSTRB;
		inout WVALID;
		input WREADY;
		input BRESP,BVALID;
		inout BREADY;
		output ARADDR,ARPROT;
		inout ARVALID;
		input ARREADY;
		input RDATA,RRESP,RVALID;
		inout RREADY;
	endclocking
	
	clocking mon_cb@(posedge ACLK);
		default input #1step output #1;
		input ARESETn;
		input AWADDR,AWPROT,AWVALID,AWREADY;
		input WDATA,WSTRB,WVALID,WREADY;
		input BRESP,BVALID,BREADY;
		input ARADDR,ARPROT,ARVALID,ARREADY;
		input RDATA,RRESP,RVALID,RREADY;
	endclocking
	
	modport DRV_MOD(clocking drv_cb);
	modport MON_MOD(clocking mon_cb);
	
endinterface

