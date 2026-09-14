module axi4_lite_assertions#(
    parameter ADDR_WIDTH=32,
    parameter DATA_WIDTH=32
)(
    input logic ACLK,
    input logic ARESETn,

    input logic [ADDR_WIDTH-1:0] AWADDR,
    input logic [2:0] AWPROT,
    input logic AWVALID,
    input logic AWREADY,

    input logic [DATA_WIDTH-1:0] WDATA,
    input logic [(DATA_WIDTH/8)-1:0] WSTRB,
    input logic WVALID,
    input logic WREADY,

    input logic [1:0] BRESP,
    input logic BVALID,
    input logic BREADY,

    input logic [ADDR_WIDTH-1:0] ARADDR,
    input logic [2:0] ARPROT,
    input logic ARVALID,
    input logic ARREADY,

    input logic [DATA_WIDTH-1:0] RDATA,
    input logic [1:0] RRESP,
    input logic RVALID,
    input logic RREADY
);

    property p_awaddr_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        AWVALID&&!AWREADY |=> $stable(AWADDR);
    endproperty

    assert property(p_awaddr_stable)
        else $error("AWADDR changed while waiting for AWREADY");


    property p_awprot_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        AWVALID&&!AWREADY |=> $stable(AWPROT);
    endproperty

    assert property(p_awprot_stable)
        else $error("AWPROT changed while waiting for AWREADY");


    property p_wdata_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        WVALID&&!WREADY |=> $stable(WDATA);
    endproperty

    assert property(p_wdata_stable)
        else $error("WDATA changed while waiting for WREADY");


    property p_wstrb_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        WVALID&&!WREADY |=> $stable(WSTRB);
    endproperty

    assert property(p_wstrb_stable)
        else $error("WSTRB changed while waiting for WREADY");


    property p_araddr_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        ARVALID&&!ARREADY |=> $stable(ARADDR);
    endproperty

    assert property(p_araddr_stable)
        else $error("ARADDR changed while waiting for ARREADY");


    property p_arprot_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        ARVALID&&!ARREADY |=> $stable(ARPROT);
    endproperty

    assert property(p_arprot_stable)
        else $error("ARPROT changed while waiting for ARREADY");


    property p_bvalid_hold;
        @(posedge ACLK) disable iff(!ARESETn)
        BVALID&&!BREADY |=> BVALID;
    endproperty

    assert property(p_bvalid_hold)
        else $error("BVALID deasserted before BREADY");


    property p_bresp_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        BVALID&&!BREADY |=> $stable(BRESP);
    endproperty

    assert property(p_bresp_stable)
        else $error("BRESP changed while waiting for BREADY");


    property p_rvalid_hold;
        @(posedge ACLK) disable iff(!ARESETn)
        RVALID&&!RREADY |=> RVALID;
    endproperty

    assert property(p_rvalid_hold)
        else $error("RVALID deasserted before RREADY");


    property p_rdata_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        RVALID&&!RREADY |=> $stable(RDATA);
    endproperty

    assert property(p_rdata_stable)
        else $error("RDATA changed while waiting for RREADY");


    property p_rresp_stable;
        @(posedge ACLK) disable iff(!ARESETn)
        RVALID&&!RREADY |=> $stable(RRESP);
    endproperty

    assert property(p_rresp_stable)
        else $error("RRESP changed while waiting for RREADY");

endmodule
