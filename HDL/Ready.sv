//
// KFPCJr Ready.sv
// Written by kitune-san
//
module READY (
        input   logic           clock,
        input   logic           reset,

        input   logic           cpu_clock_posedge,
        input   logic           cpu_clock_negedge,

        input   logic           INTA_N,

        input   logic           IO_OR_M,
        input   logic           DEN_N,

        input   logic           IOW_N,
        input   logic           IOR_N,

        input   logic           VIDEO_READY,
        input   logic           SOUND_READY,
        input   logic           EXT_READY,

        output  logic           RDY
    );

    wire    IO_E    = ~((DEN_N | IOR_N) & IOW_N)
    logic   IO_E_N
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            IO_E_N  <= 1'b1;
        else if (~IO_E)
            IO_E_N  <= 1'b1;
        else if (cpu_clock_posedge)
            IO_E_N  <= 1'b0;
        else
            IO_E_N  <= IO_E_N;
    end

    wire    RDY1    = VIDEO_READY & SOUND_READY & EXT_READY;
    wire    AEN1_N  = IO_E_N & IO_OR_M;
    wire    AEN2_N  = INTA_N;

    wire    D_1 = (RDY1 & ~AEN1_N) | ~AEN2_N;
    logic   Q_1;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            Q_1     <= 1'b0;
        else if (cpu_clock_posedge)
            Q_1     <= D_1;
        else
            Q_1     <= Q_1;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            RDY     <= 1'b0;
        else if (cpu_clock_negedge)
            RDY     <= D_1 & Q_1;
        else
            RDY     <= Q_1;
    end

endmodule
