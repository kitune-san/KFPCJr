#!/bin/sh

iverilog -o tb.vvp ../HDL/Ready.sv ./Ready_tb.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

