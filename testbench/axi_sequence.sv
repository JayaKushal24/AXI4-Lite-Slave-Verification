//1
class axi_base_sequence extends uvm_sequence#(axi_seq_item);
	`uvm_object_utils(axi_base_sequence)
	function new(string name="axi_base_sequence");
		super.new(name);
	endfunction
	int wait_cycles=2;
endclass

//3
class axi_aw_before_w_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_aw_before_w_sequence)
	function new(string name="axi_aw_before_w_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing AW handshake before W handshake",UVM_LOW)
		repeat(100) begin
			start_item(req);//AW signals
			assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY)with{
				AWVALID==1;WVALID==0;BREADY==0;
				AWADDR dist {[8'h00:8'h27]:/15,[8'h28:8'h33]:/35,[8'h34:8'h3F]:/15,[8'h40:8'hFF]:/35};
				AWADDR[1:0]==2'b00;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.AWVALID&&rsp.AWREADY)) begin//wait until AW handshake
				start_item(req);
				finish_item(req);
				get_response(rsp);
			end
			
			repeat(wait_cycles) begin//wait cycles
				start_item(req);
				assert(req.randomize(AWVALID,WVALID,AWADDR)with{
					AWVALID==0;
					WVALID==0;
					AWADDR dist {[8'h00:8'h27]:/20,[8'h28:8'h33]:/35,[8'h34:8'h3F]:/20,[8'h40:8'hFF]:/25};
					AWADDR[1:0]==2'b00;
				});
				finish_item(req);
				get_response(rsp);
			end
			
			start_item(req);//W signals
			assert(req.randomize(AWVALID,WVALID,BREADY,WDATA,WSTRB)with{AWVALID==0;WVALID==1;BREADY==0;});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.WVALID&&rsp.WREADY))begin
				start_item(req);
				finish_item(req);
				get_response(rsp);
			end
			
			start_item(req);
			assert(req.randomize(AWVALID,WVALID,BREADY)with{AWVALID==0;WVALID==0;BREADY==1;});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.BVALID&&rsp.BREADY))begin
				start_item(req);
				assert(req.randomize(AWVALID,WVALID,BREADY)with{AWVALID==0;WVALID==0;BREADY==1;});
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass


/* //4
class axi_w_before_aw_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_w_before_aw_sequence)
	function new(string name="axi_w_before_aw_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing W handshake before AW handshake",UVM_LOW)
		repeat(100) begin
			start_item(req);//W signals
			assert(req.randomize(AWVALID,WVALID,WDATA,WSTRB,BREADY)with{AWVALID==0;WVALID==1;BREADY==0;});
			//assert(req.randomize(WDATA,WSTRB)with{AWVALID==0;WVALID==1;});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.WVALID&&rsp.WREADY))begin
				start_item(req);
				req.AWVALID=0;req.WVALID=1;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end
					
			repeat(wait_cycles) begin//wait cycles
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end
			
			start_item(req);//AW signals
			assert(req.randomize(AWVALID,WVALID,BREADY,AWADDR,AWPROT)with{
				AWVALID==1;WVALID==0;BREADY==0;
				AWADDR dist{[8'h00:8'h27]:/40,[8'h28:8'h33]:/15,[8'h34:8'h3B]:/20,[8'h3C:8'h3F]:/20,[8'h40:8'hFF]:/15};
				AWADDR[1:0] dist {2'b00:=80,[2'b01:2'b11]:=20};
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.AWVALID&&rsp.AWREADY)) begin//wait until handshake
				start_item(req);
				req.AWVALID=1;req.WVALID=0;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end	
			
			start_item(req);
			assert(req.randomize(AWVALID,WVALID,BREADY)with{AWVALID==0;WVALID==0;BREADY==1;});
			finish_item(req);
			get_response(rsp);
			
			while(!(rsp.BVALID&&rsp.BREADY))begin
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass */

// 4
class axi_w_before_aw_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_w_before_aw_sequence)
	function new(string name = "axi_w_before_aw_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req, rsp;
		bit reset_seen;
		req = axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing W handshake before AW handshake",UVM_LOW)
		repeat(100) begin
			reset_seen = 0;
			start_item(req);
			assert(req.randomize(AWVALID, WVALID, WDATA, WSTRB, BREADY)with {
					AWVALID == 0;WVALID  == 1;BREADY  == 0;
				});
			finish_item(req);
			get_response(rsp);

			while (!(rsp.WVALID && rsp.WREADY)) begin
				if (!rsp.ARESETn) begin
					reset_seen = 1;
					`uvm_info(get_type_name(),"Reset detected while waiting for W handshake",UVM_LOW)
					break;
				end
				start_item(req);
				req.AWVALID = 0;req.WVALID  = 1;req.BREADY  = 0;
				finish_item(req);
				get_response(rsp);
			end

			//if reset occurred,abandon this transaction
			if (reset_seen)
				continue;

			repeat(wait_cycles) begin
				start_item(req);
				req.AWVALID = 0;req.WVALID  = 0;req.BREADY  = 0;
				finish_item(req);
				get_response(rsp);
				if (!rsp.ARESETn) begin
					reset_seen = 1;
					`uvm_info(get_type_name(),"Reset detected during wait between W and AW",UVM_LOW)
					break;
				end
			end

			if (reset_seen)
				continue;
			start_item(req);
			assert(req.randomize(AWVALID, WVALID, BREADY,AWADDR, AWPROT)with {
					AWVALID == 1;WVALID  == 0;BREADY  == 0;
					AWADDR dist {[8'h00:8'h27] :/ 40,[8'h28:8'h33] :/ 15,[8'h34:8'h3B] :/ 20,[8'h3C:8'h3F] :/ 20,[8'h40:8'hFF] :/ 15};
					AWADDR[1:0] dist {2'b00       := 80,[2'b01:2'b11] := 20};
				});
			finish_item(req);
			get_response(rsp);

			while (!(rsp.AWVALID && rsp.AWREADY)) begin
				if (!rsp.ARESETn) begin
					reset_seen = 1;
					`uvm_info(get_type_name(),"Reset detected while waiting for AW handshake",UVM_LOW)
					break;
				end
				start_item(req);
				req.AWVALID = 1;req.WVALID  = 0;req.BREADY  = 0;
				finish_item(req);
				get_response(rsp);
			end
			if (reset_seen)
				continue;
			start_item(req);
			assert(req.randomize(AWVALID, WVALID, BREADY)with {AWVALID == 0;WVALID  == 0;BREADY  == 1;});
			finish_item(req);
			get_response(rsp);

			while (!(rsp.BVALID && rsp.BREADY)) begin
				if (!rsp.ARESETn) begin
					reset_seen = 1;
					`uvm_info(get_type_name(),"Reset detected while waiting for B handshake",UVM_LOW)
					break;
				end
				start_item(req);
				req.AWVALID = 0;
				req.WVALID  = 0;
				req.BREADY  = 1;
				finish_item(req);
				get_response(rsp);
			end
			if (reset_seen) begin
				`uvm_info(get_type_name(),"Transaction abandoned due to reset",UVM_LOW)
				continue;
			end
			`uvm_info(get_type_name(),"W-before-AW transaction completed",UVM_LOW)
		end
	endtask
endclass

//5
class axi_rd_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_rd_sequence)
	function new(string name="axi_rd_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing normal AXI4-Lite read transactions",UVM_LOW)
		repeat(100) begin
		start_item(req);
		assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY,AWVALID,WVALID)with{
			ARVALID==1;RREADY==0;AWVALID==0;WVALID==0;
			ARADDR dist {[8'h00:8'h27]:/40,[8'h28:8'h33]:/40,[8'h34:8'h3B]:/10,[8'h3C:8'h3F]:/15,[8'h40:8'hFF]:/15};
			ARADDR[1:0] dist {2'b00:=80,[2'b01:2'b11]:=20};
		});
		finish_item(req);
		get_response(rsp);
		while(!(rsp.ARVALID&&rsp.ARREADY)) begin
			start_item(req);
			req.ARVALID=1;req.RREADY=0;req.AWVALID=0;req.WVALID=0;
			finish_item(req);
			get_response(rsp);
		end

		repeat(wait_cycles) begin
			start_item(req);
			req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=0;
			finish_item(req);
			get_response(rsp);
		end

		start_item(req);
		req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
		finish_item(req);
		get_response(rsp);
		while(!(rsp.RVALID&&rsp.RREADY)) begin
			start_item(req);
			req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
			finish_item(req);
			get_response(rsp);
		end
		end
	endtask
endclass



//6
class axi_aw_w_same_cycle_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_aw_w_same_cycle_sequence)
	function new(string name="axi_aw_w_same_cycle_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		bit aw_done,w_done;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing AW and W handshakes in the same cycle",UVM_LOW)
		repeat(100) begin
			aw_done=0;w_done=0;
			start_item(req);
			assert(req.randomize(AWVALID,WVALID,BREADY,AWADDR,AWPROT,WDATA,WSTRB)with{
				AWVALID==1;WVALID==1;BREADY==0;AWADDR[1:0]==2'b00;
			});
			finish_item(req);
			get_response(rsp);
			if(rsp.AWVALID && rsp.AWREADY)	aw_done = 1;
			if(rsp.WVALID && rsp.WREADY)	w_done=1;
			while(!(aw_done && w_done)) begin
					start_item(req);
					req.AWVALID=!aw_done;req.WVALID=!w_done;req.BREADY=0;
					finish_item(req);
					get_response(rsp);
					if(rsp.AWVALID && rsp.AWREADY)	aw_done=1;
					if(rsp.WVALID && rsp.WREADY)	w_done=1;
			end			
			start_item(req);//B response
			req.AWVALID=0;req.WVALID=0;req.BREADY=1;
			finish_item(req);
			get_response(rsp);
            while(!(rsp.BVALID && rsp.BREADY)) begin
                start_item(req);
                req.AWVALID=0;req.WVALID=0;req.BREADY=1;
                finish_item(req);
                get_response(rsp);
            end
		end
	endtask
endclass


//7
class axi_simultaneous_read_write_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_simultaneous_read_write_sequence)
	function new(string name="axi_simultaneous_read_write_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		bit aw_done,w_done,ar_done,b_done,r_done;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing simultaneous read and write transactions",UVM_LOW)
		repeat(100) begin
			aw_done=0;w_done=0;ar_done=0;b_done=0;r_done=0;
			start_item(req);
			assert(req.randomize(AWVALID,WVALID,ARVALID,BREADY,RREADY,AWADDR,AWPROT,WDATA,WSTRB,ARADDR,ARPROT)with{
				AWVALID==1;WVALID==1;ARVALID==1;BREADY==1;RREADY==1;AWADDR[1:0]==2'b00;ARADDR[1:0]==2'b00;
			});
			finish_item(req);
			get_response(rsp);

			if(rsp.AWVALID && rsp.AWREADY) 	aw_done=1;
			if(rsp.WVALID && rsp.WREADY) 	w_done=1;
			if(rsp.ARVALID && rsp.ARREADY) 	ar_done=1;
			if(rsp.BVALID && rsp.BREADY) 	b_done=1;
			if(rsp.RVALID && rsp.RREADY) 	r_done=1;

			while(!(aw_done && w_done && ar_done)) begin
				start_item(req);
				req.AWVALID=!aw_done;req.WVALID=!w_done;req.BREADY=!b_done;req.ARVALID=!ar_done;req.RREADY=!r_done;
				finish_item(req);
				get_response(rsp);

				if(rsp.AWVALID && rsp.AWREADY) aw_done=1;
				if(rsp.WVALID && rsp.WREADY) w_done=1;
				if(rsp.ARVALID && rsp.ARREADY) ar_done=1;
				if(rsp.BVALID && rsp.BREADY) b_done=1;
				if(rsp.RVALID && rsp.RREADY) r_done=1;
			end

			while(!(b_done && r_done)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.ARVALID=0;req.BREADY=!b_done;req.RREADY=!r_done;
				finish_item(req);
				get_response(rsp);
				if(rsp.BVALID && rsp.BREADY) b_done=1;
				if(rsp.RVALID && rsp.RREADY) r_done=1;
			end
		end
	endtask
endclass


//8
class axi_read_write_only_sequence extends axi_base_sequence;
    `uvm_object_utils(axi_read_write_only_sequence)
    function new(string name="axi_read_write_only_sequence");
        super.new(name);
    endfunction
    task body();
        axi_seq_item req,rsp;
        bit [7:0]addr_array[]={8'h34,8'h38};
        req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing read from Write-Only (WO) registers",UVM_LOW)
        foreach(addr_array[i]) begin
            start_item(req);//writing to write only register
            assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY,WDATA,WSTRB) with {
                AWVALID==1;WVALID==0;BREADY==0;AWADDR==addr_array[i];AWADDR[1:0]==2'b00;
            });
            finish_item(req);
            get_response(rsp);
            while(!(rsp.AWVALID&&rsp.AWREADY)) begin
                start_item(req);
                req.AWVALID=1;req.WVALID=0;req.BREADY=0;
                finish_item(req);
                get_response(rsp);
            end
			
            start_item(req);//write data
            assert(req.randomize(AWVALID,WVALID,BREADY,WDATA,WSTRB) with {
                AWVALID==0;WVALID==1;BREADY==0;WSTRB==4'hF;
            });
            finish_item(req);
            get_response(rsp);
            while(!(rsp.WVALID&&rsp.WREADY)) begin
                start_item(req);
                req.AWVALID=0;req.WVALID=1;req.BREADY=0;
                finish_item(req);
                get_response(rsp);
            end

            start_item(req);//response
            req.AWVALID=0;req.WVALID=0;req.BREADY=1;
            finish_item(req);
            get_response(rsp);
            while(!(rsp.BVALID&&rsp.BREADY)) begin
                start_item(req);
                req.AWVALID=0;req.WVALID=0;req.BREADY=1;
                finish_item(req);
                get_response(rsp);
            end

            start_item(req);// Read from Write-Only register
            assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY,AWVALID,WVALID) with {
                ARVALID==1;RREADY==0;AWVALID==0;WVALID==0;ARADDR==addr_array[i];ARADDR[1:0]==2'b00;
            });
            finish_item(req);
            get_response(rsp);
            while(!(rsp.ARVALID&&rsp.ARREADY)) begin
                start_item(req);
                req.ARVALID=1;req.RREADY=0;req.AWVALID=0;req.WVALID=0;
                finish_item(req);
                get_response(rsp);
            end
			
            start_item(req);//read response
            req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
            finish_item(req);
            get_response(rsp);
            while(!(rsp.RVALID&&rsp.RREADY)) begin
                start_item(req);
                req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
                finish_item(req);
                get_response(rsp);
            end
        end
    endtask
endclass


//9
class axi_write_read_only_sequence extends axi_base_sequence;
    `uvm_object_utils(axi_write_read_only_sequence)
    function new(string name="axi_write_read_only_sequence");
        super.new(name);
    endfunction
    task body();
        axi_seq_item req,rsp;
        bit [7:0] addr_array[]={8'h28,8'h2C,8'h30};
        req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing write to Read-Only (RO) registers",UVM_LOW)
        foreach(addr_array[i]) begin
            start_item(req);//write to read only register
            assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY) with {
                AWVALID==1;WVALID==0;BREADY==0;AWADDR==addr_array[i];AWADDR[1:0]==2'b00;
            });
            finish_item(req);
            get_response(rsp);
            while(!(rsp.AWVALID&&rsp.AWREADY)) begin
                start_item(req);
                req.AWVALID=1;req.WVALID=0;req.BREADY=0;
                finish_item(req);
                get_response(rsp);
            end

            start_item(req);//write data
            assert(req.randomize(AWVALID,WVALID,BREADY,WDATA,WSTRB) with {
                AWVALID==0;WVALID==1;BREADY==0;WSTRB==4'hF;
            });
            finish_item(req);
            get_response(rsp);
            while(!(rsp.WVALID&&rsp.WREADY)) begin
                start_item(req);
                req.AWVALID=0;req.WVALID=1;req.BREADY=0;
                finish_item(req);
                get_response(rsp);
            end

            start_item(req);//write response
            req.AWVALID=0;req.WVALID=0;req.BREADY=1;
            finish_item(req);
            get_response(rsp);
            while(!(rsp.BVALID&&rsp.BREADY)) begin
                start_item(req);
                req.AWVALID=0;req.WVALID=0;req.BREADY=1;
                finish_item(req);
                get_response(rsp);
            end
			
			start_item(req);//read from read-only register
            assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY,AWVALID,WVALID) with {
                ARVALID==1;RREADY==0;AWVALID==0;WVALID==0;ARADDR==addr_array[i];ARADDR[1:0]==2'b00;
            });
            finish_item(req);
            get_response(rsp);
            while(!(rsp.ARVALID&&rsp.ARREADY)) begin
                start_item(req);
                req.ARVALID=1;req.RREADY=0;req.AWVALID=0;req.WVALID=0;
                finish_item(req);
                get_response(rsp);
            end
			
            start_item(req);//read response
            req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
            finish_item(req);
            get_response(rsp);
            while(!(rsp.RVALID&&rsp.RREADY)) begin
                start_item(req);
                req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
                finish_item(req);
                get_response(rsp);
            end
        end
    endtask
endclass


//10
class axi_unaligned_write_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_unaligned_write_sequence)
	function new(string name="axi_unaligned_write_sequence");
		super.new(name);
	endfunction

	task body();
		axi_seq_item req,rsp;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing unaligned write address and SLVERR response",UVM_LOW)
		repeat(1) begin
			start_item(req);
			assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY)with{//addr writing
				AWVALID==1;WVALID==0;BREADY==0;AWADDR==8'h0C;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.AWVALID&&rsp.AWREADY)) begin
				start_item(req);
				req.AWVALID=1;req.WVALID=0;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			assert(req.randomize(AWVALID,WVALID,BREADY,WDATA,WSTRB)with{//data writing
				AWVALID==0;WVALID==1;BREADY==0;WSTRB==4'hF;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.WVALID&&rsp.WREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=1;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			req.AWVALID=0;req.WVALID=0;req.BREADY=1;//bresp check
			finish_item(req);
			get_response(rsp);
			while(!(rsp.BVALID&&rsp.BREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=1;
				finish_item(req);
				get_response(rsp);
			end
			
			start_item(req);//reading valid data
			assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY,AWVALID,WVALID)with{
				ARVALID==1;RREADY==0;AWVALID==0;WVALID==0;ARADDR==8'h0C;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.ARVALID&&rsp.ARREADY)) begin
				start_item(req);
				req.ARVALID=1;req.RREADY=0;req.AWVALID=0;req.WVALID=0;
				finish_item(req);
				get_response(rsp);
			end
			start_item(req);
			req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.RVALID&&rsp.RREADY)) begin
				start_item(req);
				req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
				finish_item(req);
				get_response(rsp);
			end
			
			 
			start_item(req);//writing invalid data
			assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY)with{//unaligned aw write
				AWVALID==1;WVALID==0;BREADY==0;AWADDR==8'h0D;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.AWVALID&&rsp.AWREADY)) begin
				start_item(req);
				req.AWVALID=1;req.WVALID=0;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			assert(req.randomize(AWVALID,WVALID,BREADY,WDATA,WSTRB)with{//unaligned w write
				AWVALID==0;WVALID==1;BREADY==0;WSTRB==4'hF;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.WVALID&&rsp.WREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=1;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			req.AWVALID=0;req.WVALID=0;req.BREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.BVALID&&rsp.BREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=1;
				finish_item(req);
				get_response(rsp);
			end
			
			//reading invalid data
			start_item(req);
			assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY,AWVALID,WVALID)with{
				ARVALID==1;RREADY==0;AWVALID==0;WVALID==0;ARADDR==8'h0C;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.ARVALID&&rsp.ARREADY)) begin
				start_item(req);
				req.ARVALID=1;req.RREADY=0;req.AWVALID=0;req.WVALID=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.RVALID&&rsp.RREADY)) begin
				start_item(req);
				req.ARVALID=0;req.AWVALID=0;req.WVALID=0;req.RREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass


//11
class axi_unaligned_read_sequence extends axi_base_sequence;//unaligned read address
	`uvm_object_utils(axi_unaligned_read_sequence)
	function new(string name="axi_unaligned_read_sequence");
		super.new(name);
	endfunction

	task body();
		axi_seq_item req,rsp;
		bit[7:0] addr[2]={8'h00,8'h04};
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing unaligned read address and SLVERR response",UVM_LOW)
		repeat(1) begin
			foreach(addr[i]) begin
				start_item(req);//aw
				assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY,WDATA,WSTRB)with{
					AWVALID==1;WVALID==0;BREADY==0;
				});
				req.AWADDR=addr[i];
				finish_item(req);
				get_response(rsp);
				while(!(rsp.AWVALID&&rsp.AWREADY)) begin
					start_item(req);
					req.AWVALID=1;req.WVALID=0;req.BREADY=0;
					finish_item(req);
					get_response(rsp);
				end

				start_item(req);//w
				req.AWVALID=0;req.WVALID=1;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
				while(!(rsp.WVALID&&rsp.WREADY)) begin
					start_item(req);
					req.AWVALID=0;req.WVALID=1;req.BREADY=0;
					finish_item(req);
					get_response(rsp);
				end

				start_item(req);//b
				req.AWVALID=0;req.WVALID=0;req.BREADY=1;
				finish_item(req);
				get_response(rsp);
				while(!(rsp.BVALID&&rsp.BREADY)) begin
					start_item(req);
					req.AWVALID=0;req.WVALID=0;req.BREADY=1;
					finish_item(req);
					get_response(rsp);
				end
			end

			start_item(req);//ar
			assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY)with{
				ARVALID==1;RREADY==0;
			});
			req.ARADDR=8'h02;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.ARVALID&&rsp.ARREADY)) begin
				start_item(req);
				req.ARVALID=1;req.RREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);//r
			req.ARVALID=0;req.RREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.RVALID&&rsp.RREADY)) begin
				start_item(req);
				req.ARVALID=0;req.RREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass


//12
class axi_invalid_write_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_invalid_write_sequence)
	function new(string name="axi_invalid_write_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		req=axi_seq_item::type_id::create("req");
		for(int addr=8'h40;addr<=8'hFC;addr=addr+4) begin
			start_item(req);
			assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY,WDATA,WSTRB)with{
				AWADDR==addr;AWVALID==1;WVALID==0;BREADY==0;WDATA==32'h12345678;WSTRB==4'hF;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.AWVALID&&rsp.AWREADY)) begin
				start_item(req);
				req.AWADDR=addr;req.AWVALID=1;req.WVALID=0;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			req.AWVALID=0;req.WVALID=1;req.BREADY=0;req.WDATA=32'h12345678;req.WSTRB=4'hF;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.WVALID&&rsp.WREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=1;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			req.AWVALID=0;req.WVALID=0;req.BREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.BVALID&&rsp.BREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end

		for(int addr=8'h00;addr<=8'h3C;addr=addr+4) begin
			start_item(req);
			assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY)with{
				ARADDR==addr;ARVALID==1;RREADY==0;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.ARVALID&&rsp.ARREADY)) begin
				start_item(req);
				req.ARADDR=addr;req.ARVALID=1;req.RREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);
			req.ARVALID=0;req.RREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.RVALID&&rsp.RREADY)) begin
				start_item(req);
				req.ARVALID=0;req.RREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass

//13
class axi_invalid_read_sequence extends axi_base_sequence;//decoder error
	`uvm_object_utils(axi_invalid_read_sequence)
	function new(string name="axi_invalid_read_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing invalid read address and DECERR response",UVM_LOW)
		repeat(100) begin
			start_item(req);//ar
			assert(req.randomize(ARADDR,ARPROT,ARVALID,RREADY)with{
				ARVALID==1;RREADY==0;ARADDR inside{[8'h40:8'hFC]};
				//ARADDR[1:0]==2'b00;
			});
			finish_item(req);
			get_response(rsp);
			while(!(rsp.ARVALID&&rsp.ARREADY)) begin
				start_item(req);
				req.ARVALID=1;req.RREADY=0;
				finish_item(req);
				get_response(rsp);
			end

			start_item(req);//r
			req.ARVALID=0;req.RREADY=1;
			finish_item(req);
			get_response(rsp);
			while(!(rsp.RVALID&&rsp.RREADY)) begin
				start_item(req);
				req.ARVALID=0;req.RREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass


class axi_backpressure_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_backpressure_sequence)
	function new(string name="axi_backpressure_sequence");
		super.new(name);
	endfunction
	task body();
		axi_seq_item req,rsp;
		bit aw_done,w_done,ar_done;
		bit[7:0]addr[]='{8'h00,8'h04,8'h08,8'h0C,8'h10,8'h14,8'h18,8'h1C};
		req=axi_seq_item::type_id::create("req");
		`uvm_info(get_type_name(),"Testing B and R response backpressure",UVM_LOW)
		foreach(addr[i]) begin
/* 			aw_done=0;w_done=0;
			start_item(req);
			assert(req.randomize(AWVALID,WVALID,BREADY,AWPROT,WDATA,WSTRB)with{
				AWVALID==1;WVALID==1;BREADY==0;
				AWADDR[1:0]==2'b00;
			});
			req.AWADDR=addr[i];
			finish_item(req);
			get_response(rsp);
			if(rsp.AWVALID&&rsp.AWREADY)	aw_done=1;
			if(rsp.WVALID&&rsp.WREADY)		w_done=1;
			while(!(aw_done&&w_done)) begin
				start_item(req);
				req.AWVALID=!aw_done;req.WVALID=!w_done;req.BREADY=0;req.AWADDR=addr[i];
				finish_item(req);
				get_response(rsp);
				if(rsp.AWVALID&&rsp.AWREADY)	aw_done=1;
				if(rsp.WVALID&&rsp.WREADY)		w_done=1;
			end */
			
				start_item(req);//aw
				assert(req.randomize(AWADDR,AWPROT,AWVALID,WVALID,BREADY,WDATA,WSTRB)with{
					AWVALID==1;WVALID==0;BREADY==0;
				});
				req.AWADDR=addr[i];
				finish_item(req);
				get_response(rsp);
				while(!(rsp.AWVALID&&rsp.AWREADY)) begin
					start_item(req);
					req.AWVALID=1;req.WVALID=0;req.BREADY=0;
					finish_item(req);
					get_response(rsp);
				end

				start_item(req);//w
				req.AWVALID=0;req.WVALID=1;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
				while(!(rsp.WVALID&&rsp.WREADY)) begin
					start_item(req);
					req.AWVALID=0;req.WVALID=1;req.BREADY=0;
					finish_item(req);
					get_response(rsp);
				end
				
			repeat(5) begin//b backpressure
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=0;
				finish_item(req);
				get_response(rsp);
			end
			while(!(rsp.BVALID&&rsp.BREADY)) begin
				start_item(req);
				req.AWVALID=0;req.WVALID=0;req.BREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end

		foreach(addr[i]) begin
			ar_done=0;
			start_item(req);
			assert(req.randomize(ARVALID,RREADY,ARPROT,ARADDR)with{
				ARVALID==1;RREADY==0;ARADDR[1:0]==2'b00;
			});
			req.ARADDR=addr[i];
			finish_item(req);
			get_response(rsp);
			if(rsp.ARVALID&&rsp.ARREADY)	ar_done=1;
			while(!ar_done) begin
				start_item(req);
				req.ARVALID=1;req.RREADY=0;
				req.ARADDR=addr[i];
				finish_item(req);
				get_response(rsp);
				if(rsp.ARVALID&&rsp.ARREADY)	ar_done=1;
			end
			repeat(5) begin//r backpressure
				start_item(req);
				req.ARVALID=0;req.RREADY=0;
				finish_item(req);
				get_response(rsp);
			end
			while(!(rsp.RVALID&&rsp.RREADY)) begin
				start_item(req);
				req.ARVALID=0;req.RREADY=1;
				finish_item(req);
				get_response(rsp);
			end
		end
	endtask
endclass

class axi_random_sequence extends axi_base_sequence;
	`uvm_object_utils(axi_random_sequence)

	function new(string name = "axi_random_sequence");
		super.new(name);
	endfunction

	int aw_count = 0;
	int w_count  = 0;
	int b_count  = 0;
	int ar_count = 0;
	int r_count  = 0;

	bit aw_flag = 0;
	bit w_flag  = 0;
	bit b_flag  = 0;
	bit ar_flag = 0;
	bit r_flag  = 0;

	task body();
		axi_seq_item req;
		axi_seq_item rsp;

		req = axi_seq_item::type_id::create("req");

		`uvm_info(get_type_name(),"Testing random AXI4-Lite read/write transactions",UVM_LOW)

		assert(req.randomize() with {
			AWVALID dist {1 := 80, 0 := 20};
			WVALID  dist {1 := 80, 0 := 20};
			BREADY  dist {1 := 80, 0 := 20};
			ARVALID dist {1 := 80, 0 := 20};
			RREADY  dist {1 := 80, 0 := 20};

			AWADDR dist {
				[8'h00:8'h27] := 40,
				[8'h28:8'h33] := 15,
				[8'h34:8'h3F] := 40,
				[8'h40:8'hFF] := 15
			};

			AWADDR[1:0] dist {
				2'b00 := 80,
				[2'b01:2'b11] := 20
			};

			ARADDR dist {
				[8'h00:8'h27] := 40,
				[8'h28:8'h33] := 40,
				8'h3C := 5,
				[8'h34:8'h3B] := 10,
				[8'h40:8'hFF] := 15
			};

			ARADDR[1:0] dist {
				2'b00 := 80,
				[2'b01:2'b11] := 20
			};
		}) else begin
			`uvm_fatal(get_type_name(),"Initial randomization failed")
		end

		repeat(100) begin
			start_item(req);
			finish_item(req);
			get_response(rsp);

			if((req.AWVALID && rsp.AWREADY) || aw_flag) begin
				assert(req.randomize(AWADDR,AWPROT,AWVALID) with {
					AWVALID dist {1 := 80,0 := 20};
					AWADDR dist {
						[8'h00:8'h27] := 40,
						[8'h28:8'h33] := 15,
						[8'h34:8'h3F] := 40,
						[8'h40:8'hFF] := 15
					};
					AWADDR[1:0] dist {
						2'b00 := 80,
						[2'b01:2'b11] := 20
					};
				}) else begin
					`uvm_error(get_type_name(),"AW randomization failed")
				end
				aw_count = 0;
				aw_flag = 0;
			end
			else if(req.AWVALID && !rsp.AWREADY) begin
				aw_count = 0;
			end
			else begin
				aw_count++;
				if(aw_count >= 2) begin
					aw_flag = 1;
					aw_count = 0;
				end
			end

			if((req.WVALID && rsp.WREADY) || w_flag) begin
				assert(req.randomize(WDATA,WSTRB,WVALID) with {
					WVALID dist {1 := 80,0 := 20};
				}) else begin
					`uvm_error(get_type_name(),"W randomization failed")
				end
				w_count = 0;
				w_flag = 0;
			end
			else if(req.WVALID && !rsp.WREADY) begin
				w_count = 0;
			end
			else begin
				w_count++;
				if(w_count >= 2) begin
					w_flag = 1;
					w_count = 0;
				end
			end

			if((rsp.BVALID && req.BREADY) || b_flag) begin
				assert(req.randomize(BREADY) with {
					BREADY dist {1 := 80,0 := 20};
				}) else begin
					`uvm_error(get_type_name(),"BREADY randomization failed")
				end
				b_count = 0;
				b_flag = 0;
			end
			else if(rsp.BVALID && !req.BREADY) begin
				b_count++;
				if(b_count >= 2) begin
					b_flag = 1;
					b_count = 0;
				end
			end
			else begin
				b_count++;
				if(b_count >= 2) begin
					b_flag = 1;
					b_count = 0;
				end
			end

			if((req.ARVALID && rsp.ARREADY) || ar_flag) begin
				assert(req.randomize(ARADDR,ARPROT,ARVALID) with {
					ARVALID dist {1 := 80,0 := 20};
					ARADDR dist {
						[8'h00:8'h27] := 40,
						[8'h28:8'h33] := 40,
						8'h3C := 5,
						[8'h34:8'h3B] := 10,
						[8'h40:8'hFF] := 15
					};
					ARADDR[1:0] dist {
						2'b00 := 80,
						[2'b01:2'b11] := 20
					};
				}) else begin
					`uvm_error(get_type_name(),"AR randomization failed")
				end
				ar_count = 0;
				ar_flag = 0;
			end
			else if(req.ARVALID && !rsp.ARREADY) begin
				ar_count = 0;
			end
			else begin
				ar_count++;
				if(ar_count >= 2) begin
					ar_flag = 1;
					ar_count = 0;
				end
			end

			if((rsp.RVALID && req.RREADY) || r_flag) begin
				assert(req.randomize(RREADY) with {
					RREADY dist {1 := 80,0 := 20};
				}) else begin
					`uvm_error(get_type_name(),"RREADY randomization failed")
				end
				r_count = 0;
				r_flag = 0;
			end
			else if(rsp.RVALID && !req.RREADY) begin
				r_count++;
				if(r_count >= 2) begin
					r_flag = 1;
					r_count = 0;
				end
			end
			else begin
				r_count++;
				if(r_count >= 2) begin
					r_flag = 1;
					r_count = 0;
				end
			end
		end
	endtask
endclass
