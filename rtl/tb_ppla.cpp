#include <cstdlib>
#include <iostream>
#include <fstream>
#include <vector>
#include <verilated.h>
#include "testbench.h"
#include "Vppla.h"

int main(int argc, char** argv)
{

    Verilated::commandArgs(argc, argv);
    TESTBENCH<Vppla> *tb = new TESTBENCH<Vppla>();
        
    tb->opentrace("ppla.vcd");

    tb->reset();

    for(int i = 0; i < 10; i++) tb->tick();

}
