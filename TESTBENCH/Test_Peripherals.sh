#!/bin/sh

iverilog -o tb.vvp \
    ../HDL/KF8253/HDL/KF8253_Control_Logic.sv \
    ../HDL/KF8253/HDL/KF8253_Counter.sv \
    ../HDL/KF8253/HDL/KF8253.sv \
    ../HDL/KF8255/HDL/KF8255_Control_Logic.sv \
    ../HDL/KF8255/HDL/KF8255_Group.sv \
    ../HDL/KF8255/HDL/KF8255_Port.sv \
    ../HDL/KF8255/HDL/KF8255_Port_C.sv \
    ../HDL/KF8255/HDL/KF8255.sv \
    ../HDL/KF76489/HDL/KF76489_Attenuation.sv \
    ../HDL/KF76489/HDL/KF76489_Bus_Control_Logic.sv \
    ../HDL/KF76489/HDL/KF76489_Invert_AOUT.sv \
    ../HDL/KF76489/HDL/KF76489_Noise_Generator.sv \
    ../HDL/KF76489/HDL/KF76489_Tone_Generator.sv \
    ../HDL/KF76489/HDL/KF76489.sv \
    ../HDL/KFPS2IRKB/HDL/KFPS2KB_Shift_Register.sv \
    ../HDL/KFPS2IRKB/HDL/KFPS2KB.sv \
    ../HDL/KFPS2IRKB/HDL/KFPS2IRKB.sv \
    ../HDL/Peripherals.sv \
    -I../HDL/KF8253/HDL/ \
    -I../HDL/KF8255/HDL/ \
    ./Peripherals_tb.sv -g2012 -DIVERILOG
vvp tb.vvp -v
gtkwave tb.vcd

