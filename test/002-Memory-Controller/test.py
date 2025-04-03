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

    slv = AXIDevice(dut.CLK, dut.mem_axi_awvalid, dut.mem_axi_awready, dut.mem_axi_awaddr, dut.mem_axi_wvalid, dut.mem_axi_wready, dut.mem_axi_wdata, dut.mem_axi_wstrb,
                             dut.mem_axi_arvalid, dut.mem_axi_arready, dut.mem_axi_araddr, dut.mem_axi_rvalid, dut.mem_axi_rready, dut.mem_axi_rdata)


    await ClockCycles(dut.CLK, 10)

    for i in range(0, 32):

        dat = await slv.read(i*4)

        assert dat == 0x11223344 + (i%32)
    
    await ClockCycles(dut.CLK, 10)

    await slv.write(0x10000000, 0x76543210, 0xf)

    await ClockCycles(dut.CLK, 10)

    dat = await slv.read(0x10000000)

    assert dat == 0x76543210
    


