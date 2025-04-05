# SPDX-FileCopyrightText: © 2025 J. R. Sharp
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

import numpy as np

import sys
sys.path.insert(0,'../')

from common.AXIDevice import AXIDevice

async def poll_uart(clk, dut):
    prev_val = 0
    while True:
        await RisingEdge(clk)
        if prev_val != dut.UART_VALID.value and dut.UART_VALID.value:
            print("{:c}".format(dut.UART_BYTE.value & 0xff), end="")
        prev_val = dut.UART_VALID.value


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 20 ns (50 MHz)
    
    clock_per = 20
    clock_freq = 1.0 / (clock_per * 1.e-9)

    clock = Clock(dut.CLK, 20, units="ns")
    cocotb.start_soon(clock.start())
    cocotb.start_soon(poll_uart(dut.CLK, dut))

    # Reset
    dut._log.info("Reset")
    dut.RSTb.value = 0
    await ClockCycles(dut.CLK, 10)
    dut.RSTb.value = 1

    dut._log.info("Test project behavior")

    await ClockCycles(dut.CLK, 200000)





