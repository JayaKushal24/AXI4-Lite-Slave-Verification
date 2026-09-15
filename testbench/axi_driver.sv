//need to go through this logic once again


class axi_driver extends uvm_driver#(axi_seq_item);
	`uvm_component_utils(axi_driver)
	
	virtual axi4_slave_interface.DRV_MOD vif;
	
	function new(string name ="axi_driver", uvm_component parent=null);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi4_slave_interface.DRV_MOD)::get(this,"","drv_vif",vif))
			`uvm_fatal(get_type_name(),"Interface not found")
	endfunction

	task run_phase(uvm_phase phase);
/* 		forever begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
		end */
		forever begin
			seq_item_port.get_next_item(req);
			//`uvm_info("SEQ",$sformatf("sequence_id = %0d", req.get_sequence_id()),UVM_LOW)
			`uvm_info("DRV",$sformatf("REQ: seq_id=%0d tr_id=%0d",req.get_sequence_id(),req.get_transaction_id()),UVM_MEDIUM)
			rsp=axi_seq_item::type_id::create("rsp");
			rsp.set_id_info(req);
			drive(req,rsp);
			`uvm_info("DRV",$sformatf("RSP sequence_id = %0d", rsp.get_sequence_id()),UVM_MEDIUM)
			seq_item_port.item_done(rsp);
		end
	endtask
	task drive(axi_seq_item req,axi_seq_item rsp);
		@(vif.drv_cb);
		vif.drv_cb.AWADDR<=req.AWADDR;
		vif.drv_cb.AWPROT<=req.AWPROT;
		vif.drv_cb.AWVALID<=req.AWVALID;
		vif.drv_cb.WDATA<=req.WDATA;
		vif.drv_cb.WSTRB<=req.WSTRB;
		vif.drv_cb.WVALID<=req.WVALID;
		vif.drv_cb.BREADY<=req.BREADY;
		vif.drv_cb.ARADDR<=req.ARADDR;
		vif.drv_cb.ARPROT<=req.ARPROT;
		vif.drv_cb.ARVALID<=req.ARVALID;
		vif.drv_cb.RREADY<=req.RREADY;
		
		rsp.ARESETn=vif.drv_cb.ARESETn;
		rsp.AWREADY=vif.drv_cb.AWREADY;
		rsp.WREADY=vif.drv_cb.WREADY;
		rsp.BRESP=vif.drv_cb.BRESP;
		rsp.BVALID=vif.drv_cb.BVALID;
		rsp.ARREADY=vif.drv_cb.ARREADY;
		rsp.RDATA=vif.drv_cb.RDATA;
		rsp.RRESP=vif.drv_cb.RRESP;
		rsp.RVALID=vif.drv_cb.RVALID;
		rsp.AWVALID=vif.drv_cb.AWVALID;
		rsp.WVALID=vif.drv_cb.WVALID;
		rsp.BREADY=vif.drv_cb.BREADY;
		rsp.ARVALID=vif.drv_cb.ARVALID;
		rsp.RREADY=vif.drv_cb.RREADY;
		`uvm_info("DRIVER",$sformatf("TIME=%0t | AWADDR=%08h AWPROT=%0h AWVALID=%0b | WDATA=%08h WSTRB=%0h WVALID=%0b | BREADY=%0b | ARADDR=%08h ARPROT=%0h ARVALID=%0b | RREADY=%0b",
            					$time,req.AWADDR, req.AWPROT, req.AWVALID,req.WDATA, req.WSTRB, req.WVALID,req.BREADY,req.ARADDR, req.ARPROT, req.ARVALID,req.RREADY),UVM_LOW)

	endtask
	
	/* task drive(axi_seq_item req);
		if(req.read_write) begin
			vif.drv_cb.AWADDR<=req.addr;
			vif.drv_cb.AWPROT<=req.awprot;
			vif.drv_cb.AWVALID<=1;
			vif.drv_cb.WDATA<=req.wdata;
			vif.drv_cb.WSTRB<=req.wstrb;
			vif.drv_cb.WVALID<=1;
			fork 
				begin
					do
					@(vif.drv_cb);
					while(!vif.drv_cb.AWREADY);
					vif.drv_cb.AWVALID<=0;
				end
				begin
					do
					@(vif.drv_cb);
					while(!vif.drv_cb.WREADY);
					vif.drv_cb.WVALID<=0;
				end
			join
			repeat(n)@(vif.drv_cb);
			vif.drv_cb.BREADY<=1;

			do
			@(vif.drv_cb);
			while(!vif.drv_cb.BVALID);
			vif.drv_cb.BREADY<=0;
		end
		else begin
			vif.drv_cb.ARADDR<=req.addr;
			vif.drv_cb.ARPROT<=req.arprot;
			vif.drv_cb.ARVALID<=1;

			do
			@(vif.drv_cb);
			while(!vif.drv_cb.ARREADY);
			vif.drv_cb.ARVALID<=0;
			vif.drv_cb.RREADY<=1;
			
			do
			@(vif.drv_cb);
			while(!vif.drv_cb.RVALID);
			req.rdata=vif.drv_cb.RDATA;
			req.rresp=vif.drv_cb.RRESP;
			vif.drv_cb.RREADY<=0;
		end
	endtask */

endclass

