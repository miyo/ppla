
all:
	-rm -rf project_1
	vivado -mode batch -source create_project.tcl
	cp project_1/project_1.srcs/sources_1/bd/design_1/hw_handoff/design_1.hwh
	cp `find . -name \*.bit -print` design_1.bit
	-rm -rf NA
