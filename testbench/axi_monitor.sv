class axi_monitor extends uvm_monitor;
	`uvm_component_utils(axi_monitor)
	
	virtual axi4_slave_interface.MON_MOD vif;
	
	uvm_analysis_port#(axi_seq_item)	ap;
	axi_config cfg;

	function new(string name="axi_monitor",uvm_component parent=null);
		super.new(name,parent);
		ap=new("ap",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi4_slave_interface.MON_MOD)::get(this,"","mon_vif",vif))
			`uvm_fatal(get_type_name(),"Interface not found")
		if(!uvm_config_db#(axi_config)::get(this,"","cfg",cfg))
			`uvm_fatal(get_type_name(),"Active/Passive Configuration not found")
	endfunction

	task run_phase(uvm_phase phase);
		axi_seq_item req;
		//@(vif.mon_cb);
		if(cfg.is_active==UVM_PASSIVE)
			@(vif.mon_cb);

		forever begin
			@(vif.mon_cb);
			req = axi_seq_item::type_id::create("req");
			req.ARESETn = vif.mon_cb.ARESETn;

			req.AWVALID = vif.mon_cb.AWVALID;
			req.AWREADY = vif.mon_cb.AWREADY;
			req.AWADDR  = vif.mon_cb.AWADDR;
			req.AWPROT  = vif.mon_cb.AWPROT;

			req.WVALID = vif.mon_cb.WVALID;
			req.WREADY = vif.mon_cb.WREADY;
			req.WDATA  = vif.mon_cb.WDATA;
			req.WSTRB  = vif.mon_cb.WSTRB;

			req.BVALID = vif.mon_cb.BVALID;
			req.BREADY = vif.mon_cb.BREADY;
			req.BRESP  = vif.mon_cb.BRESP;

			req.ARVALID = vif.mon_cb.ARVALID;
			req.ARREADY = vif.mon_cb.ARREADY;
			req.ARADDR  = vif.mon_cb.ARADDR;
			req.ARPROT  = vif.mon_cb.ARPROT;

			req.RVALID = vif.mon_cb.RVALID;
			req.RREADY = vif.mon_cb.RREADY;
			req.RDATA  = vif.mon_cb.RDATA;
			req.RRESP  = vif.mon_cb.RRESP;
			ap.write(req);
			`uvm_info(get_full_name(),
			  $sformatf("@%0t: ARESETn=%0b | AWVALID=%0b AWREADY=%0b AWADDR=%0h AWPROT=%0h | WVALID=%0b WREADY=%0b WDATA=%0h WSTRB=%0h | BVALID=%0b BREADY=%0b BRESP=%0h | ARVALID=%0b ARREADY=%0b ARADDR=%0h ARPROT=%0h | RVALID=%0b RREADY=%0b RDATA=%0h RRESP=%0h",
			  $time,
			  req.ARESETn,
			  req.AWVALID, req.AWREADY, req.AWADDR, req.AWPROT,
			  req.WVALID, req.WREADY, req.WDATA, req.WSTRB,
			  req.BVALID, req.BREADY, req.BRESP,
			  req.ARVALID, req.ARREADY, req.ARADDR, req.ARPROT,
			  req.RVALID, req.RREADY, req.RDATA, req.RRESP),
			  UVM_MEDIUM)
		end
	endtask
endclass

