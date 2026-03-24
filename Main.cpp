#ifndef DeviceFamily_CC23X0R5
#define DeviceFamily_CC23X0R5
#endif

#include <cstdlib>

extern "C"
{
#include "ti/drivers/Power.h"
}

// #include <ti/drivers/Board.h>
// #include <ti/drivers/GPIO.h>

// Power
extern "C" const PowerCC23X0_Config PowerCC23X0_config = {
    .policyInitFxn = NULL,
    .policyFxn = PowerCC23X0_standbyPolicy,
    .startInitialHfxtAmpCompFxn = NULL,
};


SCB_Type* scb = SCB;
NVIC_Type* nvic = NVIC;

volatile char wait = 1;

// extern uint8_t _second_stage_bootloader_start;
// extern uint8_t _second_stage_bootloader_end;
extern uint8_t _application_start;
extern uint8_t _application_end;

namespace
{
    [[noreturn]] __attribute__((naked)) void JumpAsm(uint32_t stackPointer, uint32_t resetHandler)
    {
        asm volatile(
            "msr msp,r0 \n"
            "bx  r1     \n");
    }

    [[noreturn]] void Jump(uint32_t vectorTableAddress)
    {
        // std::fill_n(NVIC->ICER, 7, 0xFFFFFFFF);
        // std::fill_n(NVIC->ICPR, 7, 0xFFFFFFFF);

        auto stackPointer = *reinterpret_cast<uint32_t*>(vectorTableAddress);
        auto resetHandler = *reinterpret_cast<uint32_t*>(vectorTableAddress + sizeof(uint32_t));
        JumpAsm(stackPointer, resetHandler);

        __builtin_unreachable();
    }
}

int main()
{

    // infra::ByteRange secondStageMemory(&_second_stage_bootloader_start, &_second_stage_bootloader_end);
    infra::ConstByteRange applicationMemory(&_application_start, &_application_end);

    Power_init();

    PowerLPF3_selectLFXT();
    PMCTLSetVoltageRegulator(PMCTL_VOLTAGE_REGULATOR_DCDC);

    while (wait)
    {
        __asm("bkpt ");
    }

    Jump(reinterpret_cast<uint32_t>(applicationMemory.begin()));
}
