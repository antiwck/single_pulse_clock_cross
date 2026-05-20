# Single Pulse Clock Crossing

A Clock Domain Crossing (CDC) module that safely transfers single pulse signals between asynchronous clock domains. 
It uses Gray-coded request/acknowledgment counters to ensure no pulses are lost, regardless of clock frequency relationship (fast-to-slow or slow-to-fast). 
The `busy` signal indicates when the buffer is full and can't accept more pulses, while `b` outputs the received pulses in the destination clock domain.

The module synchronizes `a` pulses from domain A to domain B. 
If domain A sends pulses faster than domain B can consume, `b` will remain asserted for multiple cycles to represent the queued pulses. 


<img src="Single Pulse Clock Crosser.png"><br />
The image above shows an example of pulse "a" in clock domain a clock crossing to pulse "b" in clock domain b with 100 pulses.
Given that the clock frequency of clock a is 100Mhz, and clock b is 28.41Mhz. [Asynchronous clocks]
