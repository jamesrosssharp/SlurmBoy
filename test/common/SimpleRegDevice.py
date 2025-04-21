import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge

class SimpleRegDevice:
    ''' Simple Register Interface Device class.

    Since AXI is a bit complicated for simple interfaces, we simplify the register interface a bit 
    and just give some basic signals


    '''

    def __init__(self, clk, addr, data_in, data_out, read_ready, read_valid, write_valid, write_ready):

        self.clk = clk

        self.addr = addr
        self.data_in = data_in
        self.data_out = data_out
        self.read_ready = read_ready
        self.read_valid = read_valid
        self.write_valid = write_valid
        self.write_ready = write_ready


    async def write(self, address, data):
        self.addr.value = address
        self.data_in.value = data
        self.write_valid.value = 1

        # Wait until write_ready is high
        while True:
            await RisingEdge(self.clk)
            if self.write_ready.value == 1:
                break

        # Deassert write_valid after handshake
        self.write_valid.value = 0

    async def read(self, address):
        self.addr.value = address
        self.read_ready.value = 1

        while True:
            await RisingEdge(self.clk)
            if self.read_valid.value == 1:
                break

        data = self.data_out.value

        self.read_ready.value = 0
        return data
