import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

class AXIDevice:
    ''' AXI Device class.

    We feed in the signals of the AXI device we wish to test, and then perform
    methods on these signals to do AXI transactions

    '''


    def __init__(self, clk, _awvalid, _awready, _awaddr, _wvalid, _wready, _wdata, _wstrb, _arvalid, _arready, _araddr, _rvalid, _rready, _rdata):

        self.awvalid = _awvalid
        self.awready = _awready
        self.awaddr  = _awaddr
        self.wvalid  = _wvalid
        self.wready  = _wready
        self.wdata   = _wdata
        self.wstrb   = _wstrb

        self.arvalid = _arvalid
        self.arready = _arready
        self.araddr  = _araddr
        self.rvalid  = _rvalid
        self.rready  = _rready
        self.rdata   = _rdata
        

        self.clk = clk

        self.awvalid.value = 0
        self.arvalid.value = 0
        self.wvalid.value = 0
        self.rvalid.value = 0



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
 
    async def read(self, address):
        self.arvalid.value = 1
        self.araddr.value  = address
        self.rvalid.value  = 1

        while not self.rready.value:
            await ClockCycles(self.clk, 1)

        val = self.rdata.value 

        self.arvalid.value = 0
        self.araddr.value  = 0
        self.rvalid.value  = 0 

        await ClockCycles(self.clk, 1)
 
        return val


