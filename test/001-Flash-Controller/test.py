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

    slv = AXIDevice(dut.CLK, dut.reg_axi_awvalid, dut.reg_axi_awready, dut.reg_axi_awaddr, dut.reg_axi_wvalid, dut.reg_axi_wready, dut.reg_axi_wdata, dut.reg_axi_wstrb,
                             dut.reg_axi_arvalid, dut.reg_axi_arready, dut.reg_axi_araddr, dut.reg_axi_rvalid, dut.reg_axi_rready, dut.reg_axi_rdata)

    await slv.write(0, 0x12345678, 0xf)
    assert dut.f0.cmd == 0x12345678

    await ClockCycles(dut.CLK, 10)

    await slv.write(0, 0x87654321, 0xf)
    assert dut.f0.cmd == 0x87654321

    await ClockCycles(dut.CLK, 10)

    await slv.staggered_write(0x1, 0x11223344, 0xf)
    assert dut.f0.data == 0x11223344

    await ClockCycles(dut.CLK, 10)

    dat = await slv.read(0x1)

    assert dat == 0x11223344
    
    await ClockCycles(dut.CLK, 10)
