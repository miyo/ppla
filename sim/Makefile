
.PHONY: link all sim

all: link sim

ppla: ppla.sv tb_ppla.cpp testbench.h
	verilator --cc ppla.sv --trace --exe tb_ppla.cpp
	make -C obj_dir -f Vppla.mk 

spi_controller: spi_controller.sv tb_spi_controller.cpp testbench.h
	verilator --cc spi_controller.sv --trace --exe tb_spi_controller.cpp
	make -C obj_dir -f Vspi_controller.mk 

repeater: repeater.sv tb_repeater.cpp testbench.h
	verilator -Wall --cc repeater.sv --trace --exe tb_repeater.cpp
	make -C obj_dir -f Vrepeater.mk 

result_storage: result_storage.sv dualportram.v tb_result_storage.cpp testbench.h
	verilator -Wall --cc result_storage.sv dualportram.v --trace --exe tb_result_storage.cpp
	make -C obj_dir -f Vresult_storage.mk 

sim: spi_controller repeater result_storage ppla
	./obj_dir/Vspi_controller sim
	./obj_dir/Vrepeater
	./obj_dir/Vresult_storage sim
	./obj_dir/Vppla

clean:
	-rm -rf obj_dir
	-rm -f *.vcd
	find . -type l -print0 | xargs -0 rm 

link:
	ln -sf ../ip_repo/ppla_spi_repeater_1.0/src/* .
