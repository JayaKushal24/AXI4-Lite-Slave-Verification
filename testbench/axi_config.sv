class axi_config extends uvm_object;
	`uvm_object_utils(axi_config)
	
	uvm_active_passive_enum is_active;
	
	function new(string name="axi_config");
		super.new(name);
	endfunction
endclass

