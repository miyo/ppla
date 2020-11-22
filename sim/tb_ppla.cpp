#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <verilated.h>
#include "testbench.h"
#include "Vppla.h"

int read_data(TESTBENCH<Vppla> *tb, int addr)
{
    tb->m_core->DATA_ADDR = addr;
    tb->tick();
    tb->tick();
    int d = tb->m_core->DATA_DOUT;
    std::cout << addr << " " << std::setw(8) << std::setfill('0') << std::hex << d << std::endl;
    return d;
}

int read_ctrl(TESTBENCH<Vppla> *tb, int addr)
{
    tb->m_core->CTRL_ADDR = addr;
    tb->m_core->CTRL_WE = 0;
    tb->tick();
    tb->tick();
    int d = tb->m_core->CTRL_DOUT;
    std::cout << addr << " " << std::setw(8) << std::setfill('0') << std::hex << d << std::endl;
    return d;
}

void write_ctrl(TESTBENCH<Vppla> *tb, int addr, int data)
{
    tb->m_core->CTRL_ADDR = addr;
    tb->m_core->CTRL_DIN = data;
    tb->m_core->CTRL_WE = 1;
    tb->tick();
    tb->m_core->CTRL_WE = 0;
    tb->tick();
}

int main(int argc, char** argv)
{

   Verilated::commandArgs(argc, argv);
    TESTBENCH<Vppla> *tb = new TESTBENCH<Vppla>();
        
    tb->opentrace("ppla.vcd");

    tb->m_core->SPI_MISO = 1;

    tb->reset();

    for(int i = 0; i <=8; i++){
        read_ctrl(tb, i);
    }
    
    write_ctrl(tb, 1, (10<<16)+(0&0x0000FFFF));
    write_ctrl(tb, 2, 0x94a594a5);
    write_ctrl(tb, 3, 5);
    write_ctrl(tb, 4, 4); // cs_delay
    write_ctrl(tb, 5, 3); // data_delay
    write_ctrl(tb, 6, 16);
    write_ctrl(tb, 7, 16);
    write_ctrl(tb, 8, 0); // CPHA=0, CPOL=0
    
    assert(read_ctrl(tb, 1) == (10<<16)+(0&0x0000FFFF));
    assert(read_ctrl(tb, 2) == 0x94a594a5);
    assert(read_ctrl(tb, 3) == 5);
    assert(read_ctrl(tb, 4) == 4);
    assert(read_ctrl(tb, 5) == 3);
    assert(read_ctrl(tb, 6) == 16);
    assert(read_ctrl(tb, 7) == 16);
    assert(read_ctrl(tb, 8) == 0); // CPHA=0, CPOL=0

    for(int i = 0; i < 10; i++) tb->tick();

    write_ctrl(tb, 0, 1);
    
    for(int i = 0; i < 10000; i++){
        int d = read_ctrl(tb, 0);
        if((d & 0x80000000) == 0){
            break;
        }
    }

    for(int i = 0; i < 11; i++){
        read_data(tb, i);
    }
}
