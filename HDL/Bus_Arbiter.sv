//
// KFPCJr Bus_Arbiter
// Written by kitune-san
//
module BUS_ARBITER (
        input   logic           clock,
        input   logic           reset,

        input   logic           cpu_clock_posedge,
        input   logic           cpu_clock_negedge,

        input   logic           RD_N,
        input   logic           WR_N,
        input   logic           IO_OR_M,
        input   logic           DT_OR_R,
        input   logic           ALE,

        output  logic           X_IO_OR_M,
        output  logic           R_OR_DT,

        output  logic           IOW_N,
        output  logic           MEMR_N,
        output  logic           IOR_N,
        output  logic           MEMW_N
    )

    logic   Latchd_X_IO_OR_M;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
           Latchd_X_IO_OR_M     <= 1'b1;
        else if (ALE)
            Latchd_X_IO_OR_M    <= IO_OR_M;
        else
            Latchd_X_IO_OR_M    <= Latchd_X_IO_OR_M;
    end

    assign  X_IO_OR_M   = (HOLDA) ? 1'b1 : Latchd_X_IO_OR_M;

    assign  R_OR_DT     = ~DT_OR_R;

    logic   read_pulse;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            read_pulse          <= 1'b1;
        else if (RD_N)
            read_pulse          <= 1'b1;
        else if (cpu_clock_negedge)
            read_pulse          <= 1'b0;
        else
            read_pulse          <= read_pulse;
    end

    logic   write_pulse;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            write_pulse         <= 1'b1;
        else if (WR_N)
            write_pulse         <= 1'b1;
        else if (cpu_clock_negedge)
            write_pulse         <= 1'b0;
        else
            write_pulse         <= write_pulse;
    end

    logic   dtr_ale_pulse;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            dtr_ale_pulse       <= 1'b1;
        else if (DT_OR_R)
            dtr_ale_pulse       <= 1'b1;
        else if (cpu_clock_posedge)
            dtr_ale_pulse       <= ALE;
        else
            dtr_ale_pulse       <= dtr_ale_pulse;
    end

    logic   r_ale_pulse_shift;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            dtr_ale_pulse_shift <= 1'b0;
        else if (DT_OR_R)
            dtr_ale_pulse_shift <= 1'b0;
        else if (cpu_clock_negedge)
            dtr_ale_pulse_shift <= dtr_ale_pulse;
        else
            dtr_ale_pulse_shift <= dtr_ale_pulse_shift;
    end

    wire    read_ale_pulse  = ~(~RD_N | dtr_ale_pulse_shift);

    assign  IOW_N   = HLDA | ~IO_OR_M | write_pulse;
    assign  MEMR_N  = HLDA |  IO_OR_M | read_ale_pulse;
    assign  IOR_N   = HLDA | ~IO_OR_M | read_pulse;
    assign  MEMW_N  = HLDA |  IO_OR_M | WR_N;

endmodule;

