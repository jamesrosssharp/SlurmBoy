# SPDX-FileCopyrightText: © 2025 J. R. Sharp
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import numpy as np

import sys
sys.path.insert(0,'../')

from common.AXIDevice import AXIDevice

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 20 ns (50 MHz)
    
    clock_per = 20
    clock_freq = 1.0 / (clock_per * 1.e-9)

    clock = Clock(dut.CLK, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.RSTb.value = 0
    await ClockCycles(dut.CLK, 10)
    dut.RSTb.value = 1

    dut._log.info("Test project behavior")

    await ClockCycles(dut.CLK, 200000)





