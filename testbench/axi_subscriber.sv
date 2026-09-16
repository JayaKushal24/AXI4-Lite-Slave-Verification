class axi_subscriber extends uvm_subscriber #(axi_seq_item);
	`uvm_component_utils(axi_subscriber)
	axi_seq_item trans;
	covergroup aw_cg;
		cp_awaddr: coverpoint trans.AWADDR {
			bins rw_region={[8'h00:8'h27]};
			bins ro_region={[8'h28:8'h33]};
			bins wo_region={[8'h34:8'h3B]};
			bins rw_3c={[8'h3C:8'h3F]};
			bins invalid={[8'h40:8'hFF]};
		}
		cp_aw_alignment: coverpoint trans.AWADDR[1:0] {
			bins aligned={2'b00};
			bins unaligned={[2'b01:2'b11]};
		}
		cp_awprot: coverpoint trans.AWPROT {
			bins unprivileged_secure_data={3'b000};
			bins privileged_secure_data={3'b001};
			bins unprivileged_non_secure_data={3'b010};
			bins privileged_non_secure_data={3'b011};
			bins unprivileged_secure_instruction={3'b100};
			bins privileged_secure_instruction={3'b101};
			bins unprivileged_non_secure_instruction={3'b110};
			bins privileged_non_secure_instruction={3'b111};
		}
		cross_aw_addr_alignment: cross cp_awaddr, cp_aw_alignment;
	endgroup

	covergroup w_cg;
		cp_wstrb: coverpoint trans.WSTRB {
			bins no_strobe={4'b0000};
			bins full_strobe={4'b1111};
			bins partial[]={[4'b0001:4'b1110]};
		}
		cp_wdata: coverpoint trans.WDATA;
	endgroup

	covergroup b_cg;
		cp_bresp: coverpoint trans.BRESP {
			bins okay={2'b00};
			bins slverr={2'b10};
			bins decerr={2'b11};
		}
	endgroup

	covergroup ar_cg;
		cp_araddr: coverpoint trans.ARADDR {
			bins rw_region={[8'h00:8'h27]};
			bins ro_region={[8'h28:8'h33]};
			bins wo_region={[8'h34:8'h3B]};
			bins rw_3c={[8'h3C:8'h3F]};
			bins invalid={[8'h40:8'hFF]};
		}
		cp_ar_alignment: coverpoint trans.ARADDR[1:0] {
			bins aligned={2'b00};
			bins unaligned={[2'b01:2'b11]};
		}
		cp_arprot: coverpoint trans.ARPROT {
			bins unprivileged_secure_data={3'b000};
			bins privileged_secure_data={3'b001};
			bins unprivileged_non_secure_data={3'b010};
			bins privileged_non_secure_data={3'b011};
			bins unprivileged_secure_instruction={3'b100};
			bins privileged_secure_instruction={3'b101};
			bins unprivileged_non_secure_instruction={3'b110};
			bins privileged_non_secure_instruction={3'b111};
		}
		cross_ar_addr_alignment: cross cp_araddr, cp_ar_alignment;
	endgroup

	covergroup r_cg;
		cp_rresp: coverpoint trans.RRESP {
			bins okay={2'b00};
			bins slverr={2'b10};
			bins decerr={2'b11};
		}
	endgroup

	covergroup backpressure_cg;
		cp_aw_backpressure: coverpoint {trans.AWVALID, trans.AWREADY} {
			bins immediate={2'b11};
			bins wait_state={2'b10};
			ignore_bins idle={2'b00, 2'b01};
		}
		cp_w_backpressure: coverpoint {trans.WVALID, trans.WREADY} {
			bins immediate={2'b11};
			bins wait_state={2'b10};
			ignore_bins idle={2'b00, 2'b01};
		}
		cp_b_backpressure: coverpoint {trans.BVALID, trans.BREADY} {
			bins immediate={2'b11};
			bins wait_state={2'b10};
			ignore_bins idle={2'b00, 2'b01};
		}
		cp_ar_backpressure: coverpoint {trans.ARVALID, trans.ARREADY} {
			bins immediate={2'b11};
			bins wait_state={2'b10};
			ignore_bins idle={2'b00, 2'b01};
		}
		cp_r_backpressure: coverpoint {trans.RVALID, trans.RREADY} {
			bins immediate={2'b11};
			bins wait_state={2'b10};
			ignore_bins idle={2'b00, 2'b01};
		}
	endgroup

	function new(string name="axi_subscriber", uvm_component parent=null);
		super.new(name, parent);
		aw_cg=new();
		w_cg=new();
		b_cg=new();
		ar_cg=new();
		r_cg=new();
		backpressure_cg=new();
	endfunction

	function void write(axi_seq_item t);
		trans=t;
		if (trans.AWVALID&&trans.AWREADY) aw_cg.sample();
		if (trans.WVALID&&trans.WREADY) w_cg.sample();
		if (trans.BVALID&&trans.BREADY) b_cg.sample();
		if (trans.ARVALID&&trans.ARREADY) ar_cg.sample();
		if (trans.RVALID&&trans.RREADY) r_cg.sample();
		if (trans.AWVALID||trans.WVALID||trans.BVALID||trans.ARVALID||trans.RVALID) backpressure_cg.sample();
	endfunction
	function void report_phase(uvm_phase phase);
	        `uvm_info(get_type_name(),
	        $sformatf("\n========== AXI COVERAGE ==========\n\
		AW Coverage          : %0.2f%%\n\
		W Coverage           : %0.2f%%\n\
		B Coverage           : %0.2f%%\n\
		AR Coverage          : %0.2f%%\n\
		R Coverage           : %0.2f%%\n\
		Backpressure Coverage: %0.2f%%\n\
		===================================",
        	//aw_cg.get_inst_coverage(),w_cg.get_inst_coverage(),b_cg.get_inst_coverage(),ar_cg.get_inst_coverage(),r_cg.get_inst_coverage(),backpressure_cg.get_inst_coverage()),UVM_NONE)
		aw_cg.get_coverage(),w_cg.get_coverage(),b_cg.get_coverage(),ar_cg.get_coverage(),r_cg.get_coverage(),backpressure_cg.get_coverage()),UVM_NONE)
	endfunction
endclass

