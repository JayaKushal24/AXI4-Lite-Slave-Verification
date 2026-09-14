class axi_environment extends uvm_env;
	`uvm_component_utils(axi_environment)
	axi_agent active_agent;
	axi_agent passive_agent;
	axi_subscriber scb;
	axi_scoreboard sco;
	
	axi_config active_cfg;
	axi_config passive_cfg;
	
	function new(string name ="axi_environment", uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		active_cfg = axi_config::type_id::create("active_cfg");
		passive_cfg = axi_config::type_id::create("passive_cfg");
		
		active_cfg.is_active=UVM_ACTIVE;
		passive_cfg.is_active=UVM_PASSIVE;
		
		uvm_config_db#(axi_config)::set(this,"active_agent*","cfg",active_cfg);
		uvm_config_db#(axi_config)::set(this,"passive_agent*","cfg",passive_cfg);
		
		active_agent=axi_agent::type_id::create("active_agent",this);
		passive_agent=axi_agent::type_id::create("passive_agent",this);
		scb=axi_subscriber::type_id::create("scb",this);
		sco=axi_scoreboard::type_id::create("sco",this);
	endfunction
	
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		active_agent.mon.ap.connect(sco.inp_fifo.analysis_export);
		passive_agent.mon.ap.connect(sco.out_fifo.analysis_export);
		active_agent.mon.ap.connect(scb.analysis_export);
	endfunction
endclass

