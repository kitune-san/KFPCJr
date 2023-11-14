//
// KFPCJr Chipset
// Written by kitune-san
//
module CHIPSET (
        input           clock,
        input           reset,

        input           cpu_clock_posedge,
        input           cpu_clock_negedge,
        input           pclk_enable,
        input           osc_enable,

        input   [19:0]  ADDRESS,
        input   [7:0]   DATA_IN,
        output  [7:0]   DATA_OUT,

        output          RDY,
        output          HOLD,
        input           HLDA,

        output          NMI,
        output          INTR,
        input           INTA_N,

        input           RD_N,
        input           WR_N,
        input           IO_OR_M,
        input           DT_OR_R,
        input           DEN_N,
        input           ALE
    );


    BUS_ARBITER u_BUS_ARBITER
    (
        .clock                          (clock),
        .cpu_clock_posedge              (cpu_clock_posedge),
        .cpu_clock_negedge              (cpu_clock_negedge),
        .RD_N                           (RD_N),
        .WR_N                           (WR_N),
        .IO_OR_M                        (IO_OR_M),
        .DT_OR_R                        (DT_OR_R),
        .ALE                            (ALE),
        .X_IO_OR_M                      (),
        .R_OR_DT                        (),
        .IOW_N                          (),
        .MEMR_N                         (),
        .IOR_N                          (),
        .MEMW_N                         ()
    );

endmodule

