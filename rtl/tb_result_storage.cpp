#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <verilated.h>
#include "testbench.h"
#include "Vresult_storage.h"

int main(int argc, char** argv)
{

    Verilated::commandArgs(argc, argv);
    TESTBENCH<Vresult_storage> *tb = new TESTBENCH<Vresult_storage>();
        
    tb->opentrace("result_storage.vcd");

    tb->m_core->DIN_WE = 0;
    tb->m_core->ADDR_RESET = 0;
    tb->reset();
    
    for(int i = 0; i < 16; i++){
        tb->m_core->DIN_WE = 1;
        tb->m_core->DIN = 0x100+i;
        tb->tick();
    }
    tb->m_core->DIN_WE = 0;
    tb->tick();

    tb->m_core->READ_ADDR = 0;
    tb->tick();
    for(int i = 0; i < 16; i++){
        tb->m_core->READ_ADDR = i+1;
        assert(tb->m_core->READ_DOUT == 0x100+i);
        tb->tick();
    }
    
    for(int i = 0; i < 50; i++) tb->tick();

    tb->m_core->ADDR_RESET = 1;
    tb->tick();
    tb->m_core->ADDR_RESET = 0;
    tb->tick();
    
    for(int i = 0; i < 16; i++){
        tb->m_core->DIN_WE = 1;
        tb->m_core->DIN = 0x200+i;
        tb->tick();
    }
    tb->m_core->DIN_WE = 0;
    tb->tick();

    tb->m_core->READ_ADDR = 0;
    tb->tick();
    for(int i = 0; i < 16; i++){
        tb->m_core->READ_ADDR = i+1;
        assert(tb->m_core->READ_DOUT == 0x200+i);
        tb->tick();
    }


}
