#include <cstdlib>
#include <iostream>
#include <fstream>
#include <vector>
#include <verilated.h>
#include "testbench.h"
#include "Vrepeater.h"

void sim(TESTBENCH<Vrepeater> *tb, int busy_cycles, int post_margin, int repetition, int mode){
    int busy_counter = 0;
    tb->m_core->POST_MARGIN = post_margin;
    tb->m_core->REPETITION = repetition;
    tb->m_core->MODE = mode;
    for(int i = 0; ; i++){
        if(i == 0){
            tb->m_core->KICK = 1;
        }else{
            tb->m_core->KICK = 0;
        }

        if(tb->m_core->TARGET_BUSY == 1){
            busy_counter++;
        }
        if(busy_counter==busy_cycles){
            tb->m_core->TARGET_BUSY = 0;
        }
        if(tb->m_core->TARGET_KICK == 1){
            tb->m_core->TARGET_BUSY = 1;
            busy_counter = 0;
        }
        if(i > 2 && tb->m_core->BUSY == 0){
            break;
        }
        if(i > 0 & i % 32 == 0){
            tb->m_core->EXT_TRIG = 1;
        }else{
            tb->m_core->EXT_TRIG = 0;
        }
        
        tb->tick();
        if(tb->m_tickcount > 10000){
            std::cout << "timeout error" << std::endl;
            break;
        }
    }
    tb->m_core->EXT_TRIG = 0;
}

int main(int argc, char** argv)
{

    Verilated::commandArgs(argc, argv);
    TESTBENCH<Vrepeater> *tb = new TESTBENCH<Vrepeater>();
        
    tb->opentrace("repeater.vcd");

    tb->reset();

    tb->m_core->KICK = 1;
    tb->tick();
    tb->m_core->KICK = 0;
    tb->tick();
    while(tb->m_core->BUSY){ tb->tick(); }
    for(int i = 0; i < 10; i++) tb->tick();

    sim(tb, 10, 0, 0, 0);
    for(int i = 0; i < 10; i++) tb->tick();
    
    sim(tb, 10, 5, 0, 0);
    for(int i = 0; i < 10; i++) tb->tick();
    
    sim(tb, 10, 0, 10, 0);
    for(int i = 0; i < 10; i++) tb->tick();
    
    sim(tb, 10, 5, 10, 0);
    for(int i = 0; i < 10; i++) tb->tick();

    sim(tb, 10, 0, 10, 1);
    for(int i = 0; i < 10; i++) tb->tick();

}
