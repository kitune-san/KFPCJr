//
// KFPCJr Chipset
// Written by kitune-san
//
module CHIPSET (
        input   logic           clock,
        input   logic           reset,

        input   logic           cpu_clock_posedge,
        input   logic           cpu_clock_negedge,
        input   logic           pclk_enable,
        input   logic           osc_enable,

        input   logic   [19:0]  ADDRESS,
        input   logic   [7:0]   DATA_IN,
        output  logic   [7:0]   DATA_OUT,

        output  logic           RDY,
        output  logic           HOLD,
        input   logic           HLDA,

        output  logic           NMI,
        output  logic           INTR,
        input   logic           INTA_N,

        input   logic           RD_N,
        input   logic           WR_N,
        input   logic           IO_OR_M,
        input   logic           DT_OR_R,
        input   logic           DEN_N,
        input   logic           ALE
    );

    logic   X_IO_OR_M;
    logic   R_OR_DT;
    logic   IOW_N;
    logic   MEMR_N;
    logic   IOR_N;
    logic   MEMW_N;

    BUS_ARBITER u_BUS_ARBITER (
        .clock                          (clock),
        .cpu_clock_posedge              (cpu_clock_posedge),
        .cpu_clock_negedge              (cpu_clock_negedge),
        .RD_N                           (RD_N),
        .WR_N                           (WR_N),
        .IO_OR_M                        (IO_OR_M),
        .DT_OR_R                        (DT_OR_R),
        .ALE                            (ALE),
        .X_IO_OR_M                      (X_IO_OR_M),
        .R_OR_DT                        (R_OR_DT),
        .IOW_N                          (IOW_N),
        .MEMR_N                         (MEMR_N),
        .IOR_N                          (IOR_N),
        .MEMW_N                         (MEMW_N)
    );

    READY u_Ready (
        .clock                          (clock),
        .reset                          (reset),
        .cpu_clock_posedge              (cpu_clock_posedge),
        .cpu_clock_negedge              (cpu_clock_negedge),
        .INTA_N                         (INTA_N),
        .IO_OR_M                        (IO_OR_M),
        .DEN_N                          (DEN_N),
        .IOW_N                          (IOW_N),
        .IOR_N                          (IOR_N),
        .VIDEO_READY                    (),
        .SOUND_READY                    (),
        .EXT_READY                      (),
        .RDY                            (RDY)
    );

    logic           interrupt_controller_cs_n;
    logic   [7:0]   interrupt_bus_out_data;
    logic           interrupt_bus_io;
    logic           interrupt_buffer_enable;
    logic           interrupt_sp_or_en;

    interrupt_controller_cs_n   = ~(X_IO_OR_M & ({ADDRESS[9:3], 3'h0} == 10'h20));

    KF8259 u_KF8259 (
        .clock                          (clock),
        .reset                          (reset),
        .chip_select_n                  (interrupt_controller_cs_n),
        .read_enable_n                  (IOR_N),
        .write_enable_n                 (IOW_N),
        .address                        (ADDRESS[0]),
        .data_bus_in                    (DATA_IN),
        .data_bus_out                   (interrupt_bus_out_data),
        .data_bus_io                    (interrupt_bus_io),
        .cascade_in                     (3'b000),
        //.cascade_out                    (),
        //.cascade_io                     (),
        .slave_program_n                (1'b1),
        .buffer_enable                  (interrupt_buffer_enable),
        .slave_program_or_enable_buffer (interrupt_sp_or_en),
        .interrupt_acknowledge_n        (),
        .interrupt_to_cpu               (INTR),
        .interrupt_request              ()
    );


    always_comb begin
        if (DEN_N || (~interrupt_buffer_enable & ~interrupt_sp_or_en))
            DATA_OUT    = (~interrupt_bus_io) ? interrupt_bus_out_data : 8'hFF;
        else if (~DT_OR_R)
            if (~interrupt_controller_cs_n && ~IOR_N)
                DATA_OUT    = (~interrupt_bus_io) ? interrupt_bus_out_data : 8'hFF;
            else
                DATA_OUT    = 8'hFF;
        else
            DATA_OUT    = 8'hFF;
    end
endmodule

