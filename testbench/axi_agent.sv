class axi_agent extends uvm_agent;
	`uvm_component_utils(axi_agent)
	axi_sequencer seqr;
	axi_driver drv;
	axi_monitor mon;
	axi_config cfg;
	
	function new(string name ="axi_agent",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_config)::get(this,"","cfg",cfg))
			`uvm_fatal(get_type_name(),"configuration not found")
			
		mon=axi_monitor::type_id::create("mon",this);
		if(cfg.is_active==UVM_ACTIVE)begin
			seqr=axi_sequencer::type_id::create("seqr",this);
			drv=axi_driver::type_id::create("drv",this);
		end	
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(cfg.is_active==UVM_ACTIVE)begin
			drv.seq_item_port.connect(seqr.seq_item_export);
		end
	endfunction
endclass

