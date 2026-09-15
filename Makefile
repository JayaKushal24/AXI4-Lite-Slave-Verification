TEST?=axi_aw_before_w_test

clean:
	rm -rf verdiLog *.rc *.fsdb *.log  work csrc  vdCovLog coverage_report simv.daidir *.conf
	rm -rf transcript simv.vdb ucli.key vc_hdrs.h simv
	clear

compile:
	vlog ./design/axi_dut.sv
	vlog ./tb/axi_pkg.sv
	vlog ./tb/tb_top.sv

run:	compile
	vsim -c tb_top +UVM_TESTNAME=$(TEST) -do "run -all;quit;" 

vcs_run:	
	vcs -full64 -sverilog -ntb_opts uvm -debug_access+all +incdir+./testbench   ./testbench/axi_pkg.sv ./testbench/tb_top.sv -l compile.log && ./simv +UVM_TESTNAME=$(TEST)  -l sim.log


vcs_all:
	vcs -full64 -sverilog -ntb_opts uvm -licqueue -debug_access+all -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a -cm line+cond+fsm+tgl+branch+assert -assert enable_diag +incdir+./testbench ./testbench/axi_pkg.sv ./testbench/tb_top.sv -l compile.log
	./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=$(TEST) -l simulation.log
	urg -dir simv.vdb -report coverage_report

view_cov:
	verdi -cov simv.vdb/

view_wave:
	verdi -ssf ./wave.fsdb & 
