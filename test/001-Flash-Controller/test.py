# SPDX-FileCopyrightText: © 2025 J. R. Sharp
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import numpy as np

import sys
sys.path.insert(0,'../')

from common.SimpleRegDevice import SimpleRegDevice

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 20 ns (50 MHz)
    
    clock_per = 20
    clock_freq = 1.0 / (clock_per * 1.e-9)

    clock = Clock(dut.CLK, 20, units="ns")
    cocotb.start_soon(clock.start())

    dev = SimpleRegDevice(
        dut.CLK,
        dut.reg_addr,
        dut.reg_data_in,
        dut.reg_data_out,
        dut.reg_RD_ready,
        dut.reg_RD_valid,
        dut.reg_WR_valid,
        dut.reg_WR_ready
    )

    # Reset
    dut._log.info("Reset")
    dut.RSTb.value = 0
    await ClockCycles(dut.CLK, 10)
    dut.RSTb.value = 1

    dut._log.info("Test project behavior")

    # Example write

    val = 0xCAFEBABE
    await dev.write(address=0x01, data=val)

    # Example read
    result = await dev.read(address=0x01)
    dut._log.info(f"Read data: 0x{int(result):08X}")

    assert result == val

    await ClockCycles(dut.CLK, 10)
