TEST?=axi_aw_before_w_test

clean:
	rm -rf *.rc work csrc  vdCovLog coverage_report  simv.daidir *.conf
	rm -rf transcript compile.log simv.vdb ucli.key vc_hdrs.h simv sim.log
	clear

compile:
	vlog ./design/axi_dut.sv
	vlog ./tb/axi_pkg.sv
	vlog ./tb/tb_top.sv

run:	compile
	vsim -c tb_top +UVM_TESTNAME=$(TEST) -do "run -all;quit;" 

vcs_run:	
	vcs -full64 -sverilog -ntb_opts uvm -debug_access+all +incdir+./tb   ./tb/axi_pkg.sv ./tb/tb_top.sv -l compile.log && ./simv +UVM_TESTNAME=$(TEST)  -l sim.log


vcs_all:
	vcs -full64 -sverilog -ntb_opts uvm -licqueue -cm line+cond+fsm+tgl+branch+assert -assert enable_diag +incdir+./tb  ./tb/axi_pkg.sv ./tb/tb_top.sv -l compile.log
	./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=$(TEST) -l simulation.log
	urg -dir simv.vdb -report coverage_report
