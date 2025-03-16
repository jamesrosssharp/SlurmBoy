# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import numpy as np


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

    # Set the input values you want to test

    dut.reg_axi_awvalid.value = 1
    dut.reg_axi_awaddr.value = 0x000000000
    dut.reg_axi_wvalid.value = 1
    dut.reg_axi_wdata.value = 0xaa55aa55

    await ClockCycles(dut.CLK, 2)

    dut.reg_axi_awvalid.value = 0
    dut.reg_axi_awaddr.value = 0x000000000
    dut.reg_axi_wvalid.value = 0
    dut.reg_axi_wdata.value = 0

    await ClockCycles(dut.CLK, 10)

    dut.reg_axi_awvalid.value = 1
    dut.reg_axi_awaddr.value = 0x000000000
    dut.reg_axi_wvalid.value = 1
    dut.reg_axi_wdata.value = 0x12345678

    await ClockCycles(dut.CLK, 4)

    dut.reg_axi_awvalid.value = 0
    dut.reg_axi_awaddr.value = 0x000000000
    dut.reg_axi_wvalid.value = 0
    dut.reg_axi_wdata.value = 0

    await ClockCycles(dut.CLK, 10)


