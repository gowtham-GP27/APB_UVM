## APB  
#### Introduction   
APB is a low-power, low-bandwidth bus protocol mainly used to connect peripheral devices (timers, UARTs, GPIO, etc.) to the system.
It is non-pipelined and has a simple interface compared to AHB/AXI.
Focus is on minimum power consumption and reduced interface complexity rather than high performance.

#### Features  
Simple, low-latency bus for peripherals.
Non-pipelined (each transaction is independent).
Supports single-cycle data transfer after the setup phase.
Optimized for low power consumption.
Does not support burst transfers or out-of-order transactions like AXI.

#### What are we doing here ?  
In the verification of the APB protocol with one master and two slaves, we build a UVM environment that models the standard layered architecture. At the transaction level, we define an APB sequence item capturing fields such as address, write data, read data, direction, and control signals (PADDR, PWRITE, PSEL, PENABLE, PREADY, PRDATA, PWDATA). The sequencer generates these items and passes them to the driver. The driver, in turn, drives the APB master interface by toggling the signals according to the APB timing specification, ensuring that the setup and access phases are modeled correctly. This constitutes the active agent for the APB master side.

On the slave side, we model both active and passive components depending on the verification intent. We emulate slave responses, we use an active slave driver that responds to the master’s transactions by asserting PREADY, driving PRDATA during reads, or latching PWDATA during writes. Alongside, we connect a passive monitor to each slave interface. The passive monitor does not drive signals; instead, it observes PADDR, PWRITE, PSELx, PENABLE, and PREADY, reconstructs the transaction, and forwards it as an analysis transaction. This is crucial for checking whether the correct slave is selected based on the 9th bit of the address and whether data is transferred as per the protocol.

The architecture also includes a scoreboard and coverage collector. The scoreboard compares the expected behavior with the actual observed transactions from the passive monitors. For example, if the driver issues a write to slave 1, the scoreboard expects slave 1’s monitor to capture the write transaction and ensures that no activity occurs on slave 2. Similarly, for reads, it checks that the data returned on PRDATA matches the expected model. Coverage is collected from the monitors to ensure that all protocol scenarios, such as write/read operations, both slave selections, and error signaling through PSLVERR, are exercised.

Finally, the environment ties these components together. It instantiates the master agent (active), the two slave interfaces (each with a passive monitor and optionally an active responder), the scoreboard, and the coverage collector. The connections are established through analysis ports so that all observed transactions flow into the checking and coverage components. This modular setup ensures a thorough verification of the APB protocol implementation with multiple slaves, covering both functional correctness and protocol compliance.

#### USING THE MAKEFILE  
make c → Compile design files  
make s → Run simulation without coverage  
make cov → Run simulation with coverage and generate HTML report  
make clean → Remove compiled libraries and reset workspace  
