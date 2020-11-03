#include <cstdlib>
#include <iostream>
#include <fstream>
#include <vector>
#include <verilated.h>
#include "testbench.h"
#include "Vspi_controller.h"

void emit_spi(TESTBENCH<Vspi_controller> *tb,
          int sclk_half_period,
          int cpol,
          int cpha,
          int cs_delay,
          int data_delay,
          int miso_width,
          int mosi_width,
          long long din){
    tb->m_core->KICK = 1;
    tb->m_core->SCLK_HALF_PERIOD = sclk_half_period;
    tb->m_core->CPOL <= cpol;
    tb->m_core->CPHA <= cpha;
    tb->m_core->CS_DELAY = cs_delay;
    tb->m_core->DATA_DELAY = data_delay;
    tb->m_core->MISO_WIDTH = miso_width;
    tb->m_core->MOSI_WIDTH = mosi_width;
    tb->m_core->DIN = din;
    tb->tick();
    tb->m_core->KICK = 0;
    do{
        tb->tick();
    }while(!(tb->m_core->KICK == 0 && tb->m_core->BUSY == 0));
}

void set_cpol(TESTBENCH<Vspi_controller> *tb, int cpol){
    for(int i = 0; i < 50; i++){ tb->tick(); }
    tb->m_core->CPOL = cpol;
    for(int i = 0; i < 50; i++){ tb->tick(); }
}

int main(int argc, char** argv)
{

    Verilated::commandArgs(argc, argv);
    TESTBENCH<Vspi_controller> *tb = new TESTBENCH<Vspi_controller>();
        
    tb->m_core->CLK = 0;
    tb->m_core->RESET = 1;
    tb->m_core->KICK = 0;
    tb->m_core->DIN = 0;
    tb->m_core->SCLK_HALF_PERIOD = 0;
    tb->m_core->CS_DELAY = 0;
    tb->m_core->DATA_DELAY = 0;
    tb->m_core->MISO_WIDTH = 0;
    tb->m_core->MOSI_WIDTH = 0;
    tb->m_core->CPOL = 0;
    tb->m_core->CPHA = 0;
    tb->m_core->MISO = 0;
    
    tb->reset();
    
    tb->opentrace("trace.vcd");
    
    tb->m_core->MISO = 1;

    tb->tick();
    tb->tick();
    tb->tick();
    tb->tick();
    tb->tick();
    tb->tick();
    tb->tick();

    set_cpol(tb, 0);
    emit_spi(tb, 5, 0, 0, 1, 1, 16, 16, 0x94a5000000000000L);
    set_cpol(tb, 1);
    emit_spi(tb, 5, 1, 0, 1, 1, 16, 16, 0x94a5000000000000L);
    
    set_cpol(tb, 0);
    emit_spi(tb, 5, 0, 1, 1, 1, 16, 16, 0x94a5000000000000L);
    set_cpol(tb, 1);
    emit_spi(tb, 5, 1, 1, 1, 1, 16, 16, 0x94a5000000000000L);

    set_cpol(tb, 0);
    emit_spi(tb, 2, 0, 0, 0, 0, 32, 32, 0x94a5343400000000L);
    
    set_cpol(tb, 0);
    emit_spi(tb, 2, 10, 0, 0, 0, 32, 32, 0x94a594a500000000L);
    
    set_cpol(tb, 0);
    emit_spi(tb, 2, 0, 10, 0, 0, 32, 32, 0x94a594a500000000L);
    

    for(int i = 0; i < 50; i++){ tb->tick(); }

}
