# SPDX-FileCopyrightText: © 2025 J. R. Sharp
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import numpy as np

class AXIDevice:
    ''' AXI Device class.

    We feed in the signals of the AXI device we wish to test, and then perform
    methods on these signals to do AXI transactions

    '''


    def __init__(self, clk, _awvalid, _awready, _awaddr, _wvalid, _wready, _wdata, _wstrb):

        self.awvalid = _awvalid
        self.awready = _awready
        self.awaddr  = _awaddr
        self.wvalid  = _wvalid
        self.wready  = _wready
        self.wdata   = _wdata
        self.wstrb   = _wstrb

        self.clk = clk


    async def write(self, address, value, strb):
        self.awvalid.value = 1
        self.awaddr.value  = address
        self.wvalid.value  = 1
        self.wdata.value   = value
        self.wstrb.value   = strb

        while not self.wready.value:
            await ClockCycles(self.clk, 1)

        self.awvalid.value = 0
        self.awaddr.value  = 0
        self.wvalid.value  = 0
        self.wdata.value   = 0
        self.wstrb.value   = 0

        await ClockCycles(self.clk, 1)
   
    async def staggered_write(self, address, value, strb):
        self.awvalid.value = 1
        self.awaddr.value  = address

        await ClockCycles(self.clk, 2)

        self.awvalid.value = 0
        self.awaddr.value  = 0
        self.wvalid.value  = 1
        self.wdata.value   = value
        self.wstrb.value   = strb

        while not self.wready.value:
            await ClockCycles(self.clk, 1)

        self.awvalid.value = 0
        self.awaddr.value  = 0
        self.wvalid.value  = 0
        self.wdata.value   = 0
        self.wstrb.value   = 0

        await ClockCycles(self.clk, 1)
 



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

    slv = AXIDevice(dut.CLK, dut.reg_axi_awvalid, dut.reg_axi_awready, dut.reg_axi_awaddr, dut.reg_axi_wvalid, dut.reg_axi_wready, dut.reg_axi_wdata, dut.reg_axi_wstrb)

    await slv.write(0, 0x12345678, 0xf)
    assert dut.f0.cmd == 0x12345678

    await ClockCycles(dut.CLK, 10)

    await slv.write(0, 0x87654321, 0xf)
    assert dut.f0.cmd == 0x87654321

    await ClockCycles(dut.CLK, 10)

    await slv.staggered_write(0x1, 0x11223344, 0xf)
    assert dut.f0.data == 0x11223344

    await ClockCycles(dut.CLK, 10)


