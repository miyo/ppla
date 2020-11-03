
.PHONY: all sim

all: sim

spi_controller: spi_controller.sv tb_spi_controller.cpp
	verilator -Wall --cc spi_controller.sv --trace --exe tb_spi_controller.cpp
	make -C obj_dir -f Vspi_controller.mk 

sim: spi_controller
	./obj_dir/Vspi_controller sim

clean:
	-rm -rf obj_dir
	-rm -f *.vcd
