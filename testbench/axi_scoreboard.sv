class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    uvm_tlm_analysis_fifo#(axi_seq_item) inp_fifo;
    uvm_tlm_analysis_fifo#(axi_seq_item) out_fifo;

    int pass_count,fail_count;
    axi_seq_item t1,t2,exp;

    reg [ADDR_WIDTH-1:0] wr_addr;
    reg [DATA_WIDTH-1:0] wr_data;
    reg [(DATA_WIDTH/8)-1:0] wr_strb;
    reg aw_received,w_received;

    reg [3:0][7:0] mem[15:0];

    function new(string name="axi_scoreboard",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        inp_fifo=new("inp_fifo",this);
        out_fifo=new("out_fifo",this);
        exp=axi_seq_item::type_id::create("exp");
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            inp_fifo.get(t1);
            reference_model(t1);
            out_fifo.get(t2);
            compare(exp,t2);
        end
    endtask
	reg bvalid_state;
	reg [1:0] bresp_state;
	reg rvalid_state;
	reg [DATA_WIDTH-1:0] rdata_state;
	reg [1:0] rresp_state;
	task reference_model(axi_seq_item t1);
		exp.copy(t1);
		if(!t1.ARESETn)begin
			wr_addr='0;
			wr_data='0;
			wr_strb='0;
			aw_received=0;
			w_received=0;
			bvalid_state=0;
			bresp_state=2'b00;
			rvalid_state=0;
			rdata_state='0;
			rresp_state=2'b00;
			for(int i=0;i<16;i++)
				mem[i]='0;
			exp.BVALID=0;
			exp.BRESP=2'b00;
			exp.RVALID=0;
			exp.RDATA='0;
			exp.RRESP=2'b00;
			return;
		end
		if(t1.AWVALID&&t1.AWREADY)begin
			wr_addr=t1.AWADDR;
			aw_received=1;
		end
		if(t1.WVALID&&t1.WREADY)begin
			wr_data=t1.WDATA;
			wr_strb=t1.WSTRB;
			w_received=1;
		end
		if(aw_received&&w_received&&!bvalid_state)begin
			if(wr_addr>=8'h40)
				bresp_state=2'b11;
			else if((wr_addr>=8'h28)&&(wr_addr<=8'h30))
				bresp_state=2'b10;
			else if(wr_addr[1:0]!=2'b00)
				bresp_state=2'b10;
			else begin
				bresp_state=2'b00;
			if(wr_strb[0])
			mem[wr_addr[5:2]][0]=wr_data[7:0];
			if(wr_strb[1])
			mem[wr_addr[5:2]][1]=wr_data[15:8];
			if(wr_strb[2])
			mem[wr_addr[5:2]][2]=wr_data[23:16];
			if(wr_strb[3])
			mem[wr_addr[5:2]][3]=wr_data[31:24];
			end
			bvalid_state=1;
			aw_received=0;
			w_received=0;
		end
		if(bvalid_state&&t1.BREADY)
			bvalid_state=0;
		if(t1.ARVALID&&t1.ARREADY&&!rvalid_state)begin
			if(t1.ARADDR>=8'h40)begin
				rdata_state='0;
				rresp_state=2'b11;
			end
			else if(t1.ARADDR[1:0]!=2'b00)begin
				rdata_state='0;
				rresp_state=2'b10;
			end
			else if((t1.ARADDR>=8'h34)&&(t1.ARADDR<=8'h38))begin
				rdata_state='0;
				rresp_state=2'b10;
			end
			else begin
				rdata_state=mem[t1.ARADDR[5:2]];
				rresp_state=2'b00;
			end
			rvalid_state=1;
		end
		if(rvalid_state&&t1.RREADY)
			rvalid_state=0;
		exp.BVALID=bvalid_state;
		exp.BRESP=bresp_state;
		exp.RVALID=rvalid_state;
		exp.RDATA=rdata_state;
		exp.RRESP=rresp_state;
	endtask

	task compare(axi_seq_item exp,axi_seq_item act);
		bit pass;
		pass=1;
		if (act.BVALID) begin
			if (act.BRESP!==exp.BRESP)
				pass=0;
		end
		if (act.RVALID) begin
			if ((act.RDATA!==exp.RDATA)||(act.RRESP!==exp.RRESP))
				pass=0;
		end
		if (pass) begin
			pass_count++;
			$display("PASSED");
			`uvm_info("SCOREBOARD",
			$sformatf("\nINPUTS: ARESETn=%0b | AWVALID=%0b | AWREADY=%0b | AWADDR=%0h | AWPROT=%0h | WVALID=%0b | WREADY=%0b | WDATA=%0h | WSTRB=%0h | BREADY=%0b | ARVALID=%0b | ARREADY=%0b | ARADDR=%0h | ARPROT=%0h | RREADY=%0b\nEXP: BVALID=%0b | BRESP=%0h | RVALID=%0b | RDATA=%0h | RRESP=%0h\nACT: BVALID=%0b | BRESP=%0h | RVALID=%0b | RDATA=%0h | RRESP=%0h",exp.ARESETn,exp.AWVALID,exp.AWREADY,exp.AWADDR,exp.AWPROT,exp.WVALID,exp.WREADY,exp.WDATA,exp.WSTRB,exp.BREADY,exp.ARVALID,exp.ARREADY,exp.ARADDR,exp.ARPROT,exp.RREADY,act.BVALID,exp.BRESP,act.RVALID,exp.RDATA,exp.RRESP,act.BVALID,act.BRESP,act.RVALID,act.RDATA,act.RRESP),UVM_LOW)
		end
		else begin
			fail_count++;
			$display("FAILED");
			`uvm_error("SCOREBOARD",
			$sformatf("\nINPUTS: ARESETn=%0b | AWVALID=%0b | AWREADY=%0b | AWADDR=%0h | AWPROT=%0h | WVALID=%0b | WREADY=%0b | WDATA=%0h | WSTRB=%0h | BREADY=%0b | ARVALID=%0b | ARREADY=%0b | ARADDR=%0h | ARPROT=%0h | RREADY=%0b\nEXP: BVALID=%0b | BRESP=%0h | RVALID=%0b | RDATA=%0h | RRESP=%0h\nACT: BVALID=%0b | BRESP=%0h | RVALID=%0b | RDATA=%0h | RRESP=%0h",exp.ARESETn,exp.AWVALID,exp.AWREADY,exp.AWADDR,exp.AWPROT,exp.WVALID,exp.WREADY,exp.WDATA,exp.WSTRB,exp.BREADY,exp.ARVALID,exp.ARREADY,exp.ARADDR,exp.ARPROT,exp.RREADY,act.BVALID,exp.BRESP,act.RVALID,exp.RDATA,exp.RRESP,act.BVALID,act.BRESP,act.RVALID,act.RDATA,act.RRESP))
		end
		$display("**********************************************************************************************************************");
	endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(),
        $sformatf("\npass count = %0d\nfail count = %0d\n",pass_count,fail_count),UVM_LOW);
    endfunction

endclass

