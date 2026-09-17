class axi_base_test extends uvm_test;
	`uvm_component_utils(axi_base_test)
	axi_environment env;
	function new(string name = "axi_base_test",uvm_component parent = null);
		super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_environment::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
	task run_phase(uvm_phase phase);
		//phase.set_drain_time(this,100ns);
		phase.phase_done.set_drain_time(this,100ns);
    endtask

endclass



class axi_random_test extends axi_base_test;
    `uvm_component_utils(axi_random_test)
    function new(string name = "axi_random_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi_random_sequence seq;
        phase.raise_objection(this);
        seq = axi_random_sequence::type_id::create("seq");
        seq.start(env.active_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass



class axi_aw_before_w_test extends axi_base_test;
    `uvm_component_utils(axi_aw_before_w_test)
    function new(string name = "axi_aw_before_w_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        axi_aw_before_w_sequence seq;
        phase.raise_objection(this);
        seq = axi_aw_before_w_sequence::type_id::create("seq");
        seq.start(env.active_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass



class axi_w_before_aw_test extends axi_base_test;
    `uvm_component_utils(axi_w_before_aw_test)
    function new(string name = "axi_w_before_aw_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        axi_w_before_aw_sequence seq;
        phase.raise_objection(this);
        seq = axi_w_before_aw_sequence::type_id::create("seq");
        seq.start(env.active_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass


class axi_aw_w_same_cycle_test extends axi_base_test;
    `uvm_component_utils(axi_aw_w_same_cycle_test)
    function new(string name = "axi_aw_w_same_cycle_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        axi_aw_w_same_cycle_sequence seq;
        phase.raise_objection(this);
        seq = axi_aw_w_same_cycle_sequence::type_id::create("seq");
        seq.start(env.active_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass



class axi_read_test extends axi_base_test;
    `uvm_component_utils(axi_read_test)
    function new(string name = "axi_read_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction
/*    task run_phase(uvm_phase phase);
        axi_rd_sequence seq;
        phase.raise_objection(this);
        seq = axi_rd_sequence::type_id::create("seq");
        seq.start(env.active_agent.seqr);
        phase.drop_objection(this);
    endtask */
	task run_phase(uvm_phase phase);
		axi_rd_sequence rd_seq;
		axi_w_before_aw_sequence w_before_aw_seq;
		phase.raise_objection(this);
		w_before_aw_seq=axi_w_before_aw_sequence::type_id::create("w_before_aw_seq");
		w_before_aw_seq.start(env.active_agent.seqr);
		rd_seq=axi_rd_sequence::type_id::create("rd_seq");
		rd_seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass



class axi_simultaneous_read_write_test extends axi_base_test;
    `uvm_component_utils(axi_simultaneous_read_write_test)
    function new(string name = "axi_simultaneous_read_write_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        axi_simultaneous_read_write_sequence seq;
        phase.raise_objection(this);
        seq = axi_simultaneous_read_write_sequence::type_id::create("seq");
        seq.start(env.active_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass



class axi_read_write_only_test extends axi_base_test;
	`uvm_component_utils(axi_read_write_only_test)
	function new(string name="axi_read_write_only_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	task run_phase(uvm_phase phase);
		axi_read_write_only_sequence seq;
		phase.raise_objection(this);
		seq=axi_read_write_only_sequence::type_id::create("seq");
		seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass



class axi_write_read_only_test extends axi_base_test;
	`uvm_component_utils(axi_write_read_only_test)
	function new(string name="axi_write_read_only_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	task run_phase(uvm_phase phase);
		axi_write_read_only_sequence seq;
		phase.raise_objection(this);
		seq=axi_write_read_only_sequence::type_id::create("seq");
		seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass


class axi_unaligned_read_test extends axi_base_test;
	`uvm_component_utils(axi_unaligned_read_test)
	function new(string name="axi_unaligned_read_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		axi_unaligned_read_sequence seq;
		phase.raise_objection(this);
		seq=axi_unaligned_read_sequence::type_id::create("seq");
		seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass

class axi_unaligned_write_test extends axi_base_test;
	`uvm_component_utils(axi_unaligned_write_test)
	function new(string name="axi_unaligned_write_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	task run_phase(uvm_phase phase);
		axi_unaligned_write_sequence seq;
		phase.raise_objection(this);
		seq=axi_unaligned_write_sequence::type_id::create("seq");
		seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass


class axi_invalid_read_test extends axi_base_test;
	`uvm_component_utils(axi_invalid_read_test)
	function new(string name="axi_invalid_read_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		axi_invalid_read_sequence seq;
		phase.raise_objection(this);
		seq=axi_invalid_read_sequence::type_id::create("seq");
		seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass


class axi_invalid_write_test extends axi_base_test;
	`uvm_component_utils(axi_invalid_write_test)
	function new(string name="axi_invalid_write_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	task run_phase(uvm_phase phase);
		axi_w_before_aw_sequence valid_seq;
		axi_invalid_write_sequence invalid_seq;
		phase.raise_objection(this);
        valid_seq = axi_w_before_aw_sequence::type_id::create("valid_seq");
        valid_seq.start(env.active_agent.seqr);
		invalid_seq=axi_invalid_write_sequence::type_id::create("invalid_seq");
		invalid_seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass

class axi_backpressure_test extends axi_base_test;
	`uvm_component_utils(axi_backpressure_test)
	function new(string name="axi_backpressure_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	task run_phase(uvm_phase phase);
		axi_backpressure_sequence seq;
		phase.raise_objection(this);
		seq=axi_backpressure_sequence::type_id::create("seq");
		seq.start(env.active_agent.seqr);
		phase.drop_objection(this);
	endtask
endclass


class axi_regression_test extends axi_base_test;
	`uvm_component_utils(axi_regression_test)
	function new(string name="axi_regression_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	task run_phase(uvm_phase phase);
		axi_aw_before_w_sequence				aw_before_w_seq;
		axi_w_before_aw_sequence				w_before_aw_seq;
		axi_rd_sequence							rd_seq;
		axi_aw_w_same_cycle_sequence			aw_w_same_cycle_seq;
		axi_simultaneous_read_write_sequence	simultaneous_rw_seq;
		axi_read_write_only_sequence			read_write_only_seq;
		axi_write_read_only_sequence			write_read_only_seq;
		axi_unaligned_write_sequence			unaligned_write_seq;
		axi_unaligned_read_sequence				unaligned_read_seq;
		axi_invalid_write_sequence				invalid_write_seq;
		axi_invalid_read_sequence				invalid_read_seq;
		axi_backpressure_sequence				backpressure_seq;
		axi_random_sequence						random_seq;

		phase.raise_objection(this);

		`uvm_info("REGRESSION","Starting AW before W sequence",UVM_LOW)
		aw_before_w_seq=axi_aw_before_w_sequence::type_id::create("aw_before_w_seq");
		aw_before_w_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting W before AW sequence",UVM_LOW)
		w_before_aw_seq=axi_w_before_aw_sequence::type_id::create("w_before_aw_seq");
		w_before_aw_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Read sequence",UVM_LOW)
		rd_seq=axi_rd_sequence::type_id::create("rd_seq");
		rd_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting AW and W same-cycle sequence",UVM_LOW)
		aw_w_same_cycle_seq=axi_aw_w_same_cycle_sequence::type_id::create("aw_w_same_cycle_seq");
		aw_w_same_cycle_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting simultaneous read/write sequence",UVM_LOW)
		simultaneous_rw_seq=axi_simultaneous_read_write_sequence::type_id::create("simultaneous_rw_seq");
		simultaneous_rw_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Read from Write-Only sequence",UVM_LOW)
		read_write_only_seq=axi_read_write_only_sequence::type_id::create("read_write_only_seq");
		read_write_only_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Write to Read-Only sequence",UVM_LOW)
		write_read_only_seq=axi_write_read_only_sequence::type_id::create("write_read_only_seq");
		write_read_only_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Unaligned Write sequence",UVM_LOW)
		unaligned_write_seq=axi_unaligned_write_sequence::type_id::create("unaligned_write_seq");
		unaligned_write_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Unaligned Read sequence",UVM_LOW)
		unaligned_read_seq=axi_unaligned_read_sequence::type_id::create("unaligned_read_seq");
		unaligned_read_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Invalid Write sequence",UVM_LOW)
		invalid_write_seq=axi_invalid_write_sequence::type_id::create("invalid_write_seq");
		invalid_write_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Invalid Read sequence",UVM_LOW)
		invalid_read_seq=axi_invalid_read_sequence::type_id::create("invalid_read_seq");
		invalid_read_seq.start(env.active_agent.seqr);

		`uvm_info("REGRESSION","Starting Backpressure sequence",UVM_LOW)
		backpressure_seq=axi_backpressure_sequence::type_id::create("backpressure_seq");
		backpressure_seq.start(env.active_agent.seqr);

//		`uvm_info("REGRESSION","Starting Random sequence",UVM_LOW)
//		random_seq=axi_random_sequence::type_id::create("random_seq");
//		random_seq.start(env.active_agent.seqr);

		phase.drop_objection(this);
	endtask
endclass
