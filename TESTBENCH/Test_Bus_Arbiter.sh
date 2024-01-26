#!/bin/sh

iverilog -o tb.vvp ../HDL/Bus_Arbiter.sv ./Bus_Arbiter_tb.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

