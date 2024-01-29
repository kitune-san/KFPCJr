//
// KFPCJr Peripherals.sv (MISC)
// Written by kitune-san
//
module PERIPHERALS #(
    parameter kb_over_time          = 16'd1000,
    parameter kb_bit_phase_cycle    = 16'd22000-16'd1   // 440us @ 50MHz
) (
    input   logic           clock,
    input   logic           reset,

    input   logic           cpu_clock_posedge,
    input   logic           cpu_clock_negedge,
    input   logic           pclk_enable,
    input   logic           dcsg_clock_enable,

    input   logic   [19:0]  ADDRESS,
    input   logic   [7:0]   DATA_IN,
    output  logic   [7:0]   DATA_OUT,
    input   logic           X_IO_OR_M,
    input   logic           R_OR_DT,
    input   logic           IOW_N,
    input   logic           MEMR_N,
    input   logic           IOR_N,
    input   logic           MEMW_N,
    input   logic           IO_E,
    output  logic           SOUND_READY,
    output  logic           peripherals_data_out,

    output  logic           timer_intr,
    output  logic           timer_audio,

    input   logic   [7:0]   audio_input,
    output  logic   [7:0]   audio,

    input   logic           kbd_ps2_device_clock,
    input   logic           kbd_ps2_device_data,

    output  logic           NMI
);

    //
    // Chip select
    //
    wire    timer_chip_select_n     = ~(X_IO_OR_M & ({ADDRESS[9:3], 3'h0} == 10'h40));
    wire    ppi_chip_select_n       = ~(X_IO_OR_M & ({ADDRESS[9:3], 3'h0} == 10'h60));
    wire    nmi_mask_chip_selec_n   = ~(X_IO_OR_M & ({ADDRESS[9:3], 3'h0} == 10'hA0));
    wire    dcsg_chip_select_n      = ~(X_IO_OR_M & ({ADDRESS[9:3], 3'h0} == 10'hC0));

    //
    // NMI mask
    //
    logic           prev_nmi_mask_chip_selec_n;
    logic           write_nmi_mask;
    logic           nmi_enable;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            prev_nmi_mask_chip_selec_n  <= 1'b1;
        else
            prev_nmi_mask_chip_selec_n  <= nmi_mask_chip_selec_n | IOW_N;
    end
    assign  write_nmi_mask  = ~prev_nmi_mask_chip_selec_n & (nmi_mask_chip_selec_n | IOW_N);

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            nmi_enable              <= 1'b0;
        else if (write_nmi_mask)
            nmi_enable              <= DATA_IN[7];
        else
            nmi_enable              <= nmi_enable;
    end

    //
    // IR test
    //
    logic           ir_test_enable;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            ir_test_enable          <= 1'b0;
        else if (write_nmi_mask)
            ir_test_enable          <= DATA_IN[6];
        else
            ir_test_enable          <= ir_test_enable;
    end

    //
    // Channel 1 clock select
    //
    logic           channel_1_clock_select;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            channel_1_clock_select  <= 1'b0;
        else if (write_nmi_mask)
            channel_1_clock_select  <= DATA_IN[5];
        else
            channel_1_clock_select  <= channel_1_clock_select;
    end

    //
    // 8253 (TIMER)
    //
    logic   [7:0]   timer_data_out;
    logic           timer_0_clock;
    logic           timer_1_clock;
    logic           timer_2_clock;
    logic           timer_2_gate;
    logic           timer_0_out;
    logic           timer_2_out;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            timer_0_clock           <= 1'b0;
        else if (pclk_enable)
            timer_0_clock           <= ~timer_0_clock;
        else
            timer_0_clock           <= timer_0_clock;
    end

    assign  timer_1_clock   = (channel_1_clock_select) ? timer_0_out : timer_0_clock;

    assign  timer_2_clock   = timer_0_clock;

    KF8253 u_KF8253 (
        .clock               (clock),
        .reset               (reset),
        .chip_select_n       (timer_chip_select_n),
        .read_enable_n       (IOR_N),
        .write_enable_n      (IOW_N),
        .address             (ADDRESS[1:0]),
        .data_bus_in         (DATA_IN),
        .data_bus_out        (timer_data_out),
        .counter_0_clock     (timer_0_clock),
        .counter_0_gate      (1'b1),
        .counter_0_out       (timer_0_out),
        .counter_1_clock     (timer_1_clock),
        .counter_1_gate      (1'b1),
        //.counter_1_out       (),
        .counter_2_clock     (timer_2_clock),
        .counter_2_gate      (timer_2_gate),
        .counter_2_out       (timer_2_out)
    );

    assign  timer_intr      = timer_0_out;

    //
    // 8255 (PPI)
    //
    logic   [7:0]   ppi_data_out;
    logic   [7:0]   port_b_out;
    logic           port_b_io;
    logic   [7:0]   port_c_in;
    logic   [7:0]   port_c_out;
    logic   [7:0]   port_c_io;

    KF8255 u_KF8255 (
        .clock              (clock),
        .reset              (reset),
        .chip_select_n      (ppi_chip_select_n),
        .read_enable_n      (IOR_N),
        .write_enable_n     (IOW_N),
        .address            (ADDRESS[1:0]),
        .data_bus_in        (DATA_IN),
        .data_bus_out       (ppi_data_out),
        .port_a_in          (8'hFF),
        //.port_a_out         (),
        //.port_a_io          (),
        .port_b_in          (8'hFF),
        .port_b_out         (port_b_out),
        .port_b_io          (port_b_io),
        .port_c_in          (port_c_in),
        .port_c_out         (port_c_out),
        .port_c_io          (port_c_io)
    );

    assign  timer_2_gate    = ~port_b_io & port_b_out[0];

    //assign  port_c_in[0]    = 1'b0;
    assign  port_c_in[1]    = 1'b1;
    assign  port_c_in[2]    = 1'b1;
    assign  port_c_in[3]    = 1'b1;
    assign  port_c_in[4]    = timer_2_out;
    assign  port_c_in[5]    = timer_2_out;
    //assign  port_c_in[6]    = 1'b0;
    //assign  port_c_in[7]    = 1'b0;

    //
    // Buzzer
    //
    assign  timer_audio     = timer_2_out & port_b_out[1];

    //
    // 76489 (DCSG)
    //
    logic   [7:0]   dcsg_audio_n;
    logic   [7:0]   dcsg_audio;

    KF76489 u_KF76489 (
        .clock              (clock),
        .clock_enable       (dcsg_clock_enable),
        .reset              (reset),
        .CE_N               (dcsg_chip_select_n),
        .WE_N               (IOW_N),
        .D_IN               ({DATA_IN[0], DATA_IN[1], DATA_IN[2], DATA_IN[3],
                              DATA_IN[4], DATA_IN[5], DATA_IN[6], DATA_IN[7]}),
        .READY              (SOUND_READY),
        .AOUT               (dcsg_audio_n)
    );

    KF76489_Invert_AOUT u_KF76489_Invert_AOUT (
        .AOUT_in            (dcsg_audio_n),
        .AOUT_out           (dcsg_audio)
    );

    //
    // Audio (SELECTOR)
    //
    wire    [1:0]   spkr_sw = (port_b_io) ? 2'b00 : port_b_out[6:5];

    always_comb begin
        casez (spkr_sw)
            2'b00:      audio = (timer_audio) ? 8'hFF : 8'h00;
            2'b01:      audio = 8'h00;
            2'b10:      audio = audio_input;
            2'b11:      audio = dcsg_audio;
            default:    audio = 8'h00;
        endcase
    end

    //
    // Keyboard
    //
    logic           kbd_data;
    logic           cable_connected_n;
    logic           keybd_in;
    logic           prev_keybd_in;
    logic           keybd_latch;

    KFPS2IRKB #(
        .over_time          (kb_over_time),
        .bit_phase_cycle    (kb_bit_phase_cycle)
    ) u_KFPS2IRKB (
        .clock              (clock),
        .reset              (reset),
        .device_clock       (kbd_ps2_device_clock),
        .device_data        (kbd_ps2_device_data),
        .ir_signal          (kbd_data)
    );

    assign  cable_connected_n   = 1'b0;

    assign  keybd_in            = ~kbd_data;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            prev_keybd_in           <= 1'b1;
        else
            prev_keybd_in           <= keybd_in;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            keybd_latch             <= 1'b0;
        else if (~(IOR_N | nmi_mask_chip_selec_n))
            keybd_latch             <= 1'b0;
        else if (~prev_keybd_in & keybd_in)
            keybd_latch             <= 1'b1;
        else
            keybd_latch             <= keybd_latch;
    end

    assign  port_c_in[0]    = keybd_latch;
    assign  port_c_in[6]    = keybd_in;
    assign  port_c_in[7]    = cable_connected_n;

    //
    // NMI
    //
    assign  NMI = nmi_enable & keybd_latch;

    //
    // Data out
    //
    always_comb begin
        DATA_OUT                = 8'hFF;
        peripherals_data_out    = 1'b0;

        if (~IOR_N) begin
            if (~timer_chip_select_n) begin
                DATA_OUT                = timer_data_out;
                peripherals_data_out    = 1'b1;
            end
            else if (~ppi_chip_select_n) begin
                DATA_OUT                = ppi_data_out;
                peripherals_data_out    = 1'b1;
            end
        end
    end
endmodule

