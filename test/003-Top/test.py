# SPDX-FileCopyrightText: © 2025 J. R. Sharp
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

import numpy as np

import sys
sys.path.insert(0,'../')

from common.AXIDevice import AXIDevice

uart_text = ""


async def poll_uart(clk, dut):
    global uart_text
    prev_val = 0
    while True:
        await RisingEdge(clk)
        if prev_val != dut.UART_VALID.value and dut.UART_VALID.value:
            my_str = "{:c}".format(dut.UART_BYTE.value & 0xff) 
            print(my_str, end="")
            uart_text += my_str 
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

    await ClockCycles(dut.CLK, 1000000)

    assert uart_text == """Sieve of Eratosthenes\r
=====================\r
0002 is prime\r
0003 is prime\r
0005 is prime\r
0007 is prime\r
000b is prime\r
000d is prime\r
0011 is prime\r
0013 is prime\r
done!\r
"""
