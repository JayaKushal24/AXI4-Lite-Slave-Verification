TEST?=axi_aw_before_w_test
SEEDS?=1 2

clean:
	rm -rf work csrc simv simv.daidir simv.vdb ucli.key vdCovLog coverage_report transcript
	rm -f verdiLog *.rc *.fsdb *.log *.conf vc_hdrs.h
	clear

compile:
	vlog ./design/axi_dut.sv
	vlog ./tb/axi_pkg.sv
	vlog ./tb/tb_top.sv

run:	compile
	vsim -c tb_top +UVM_TESTNAME=$(TEST) -do "run -all;quit;"

vcs_compile:
	vcs -full64 -sverilog -ntb_opts uvm -licqueue -debug_access+all \
        -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
        -cm line+cond+fsm+tgl+branch+assert -assert enable_diag \
        +incdir+./testbench ./testbench/axi_pkg.sv ./testbench/tb_top.sv -l compile.log

vcs_run: vcs_compile
	./simv +UVM_TESTNAME=$(TEST) -l simulation.log

vcs_all: vcs_compile
	./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=$(TEST) -l simulation.log
	urg -dir simv.vdb -report coverage_report

regression: vcs_compile
	@for seed in $(SEEDS); do \
                echo "Running TEST=$(TEST) SEED=$$seed"; \
                ./simv -cm line+cond+fsm+tgl+branch+assert \
                +UVM_TESTNAME=$(TEST) +ntb_random_seed=$$seed -l simulation_$$seed.log; \
        done
	cat simulation_*.log > regression.log
view_cov:
	verdi -cov simv.vdb/

view_wave:
	verdi -ssf ./wave.fsdb &
