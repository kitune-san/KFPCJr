
`define TB_CYCLE        20
`define TB_FINISH_COUNT 40000

module tb();

    timeunit        1ns;
    timeprecision   10ps;

    //
    // Generate wave file to check
    //
`ifdef IVERILOG
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
`endif

    //
    // Generate clock
    //
    logic   clock;
    initial clock = 1'b0;
    always #(`TB_CYCLE / 2) clock = ~clock;

    //
    // Generate reset
    //
    logic reset;
    initial begin
        reset = 1'b1;
            # (`TB_CYCLE * 10)
        reset = 1'b0;
    end

    //
    // Cycle counter
    //
    logic   [31:0]  tb_cycle_counter;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            tb_cycle_counter <= 32'h0;
        else
            tb_cycle_counter <= tb_cycle_counter + 32'h1;
    end

    always_comb begin
        if (tb_cycle_counter == `TB_FINISH_COUNT) begin
            $display("***** SIMULATION TIMEOUT ***** at %d", tb_cycle_counter);
`ifdef IVERILOG
            $finish;
`elsif MODELSIM
            $stop;
`else
            $finish;
`endif
        end
    end

    //
    // Module under test
    //
    logic           cpu_clock_posedge;
    logic           cpu_clock_negedge;
    logic           pclk_enable;
    logic           dcsg_clock_enable;

    logic   [19:0]  ADDRESS;
    logic   [7:0]   DATA_IN;
    logic   [7:0]   DATA_OUT;
    logic           X_IO_OR_M;
    logic           R_OR_DT;
    logic           IOW_N;
    logic           MEMR_N;
    logic           IOR_N;
    logic           MEMW_N;
    logic           IO_E;
    logic           SOUND_READY;
    logic           peripherals_data_out;

    logic           timer_intr;
    logic           timer_audio;

    logic   [7:0]   audio_input;
    logic   [7:0]   audio;

    logic           kbd_ps2_device_clock;
    logic           kbd_ps2_device_data;

    logic           NMI;

    PERIPHERALS #(
        .kb_over_time           (16'd6),
        .kb_bit_phase_cycle     (16'd12-16'd1)
    ) u_Peripherals (.*);


    //
    // Clock enable
    //
    always_ff @(negedge clock, posedge reset) begin
        if (reset) begin
            pclk_enable         <= 1'b0;
            dcsg_clock_enable   <= 1'b0;
        end
        else begin
            pclk_enable         <= ~pclk_enable;
            dcsg_clock_enable   <= ~dcsg_clock_enable;
        end
    end

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        cpu_clock_posedge       = 1'b0;
        cpu_clock_negedge       = 1'b0;
        ADDRESS                 = 20'h00000;
        DATA_IN                 = 8'h00;
        X_IO_OR_M               = 1'b0;
        R_OR_DT                 = 1'b1;
        IOW_N                   = 1'b1;
        MEMR_N                  = 1'b1;
        IOR_N                   = 1'b1;
        MEMW_N                  = 1'b1;
        IO_E                    = 1'b0;
        audio_input             = 8'h00;
        kbd_ps2_device_clock    = 1'b1;
        kbd_ps2_device_data     = 1'b1;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : IO Read
    //
    task TASK_IO_READ(input [19:0] address);
    begin
        #(`TB_CYCLE * 0);
        ADDRESS                 = address;
        DATA_IN                 = 8'h00;
        X_IO_OR_M               = 1'b1;
        R_OR_DT                 = 1'b1;
        IOW_N                   = 1'b1;
        MEMR_N                  = 1'b1;
        IOR_N                   = 1'b0;
        MEMW_N                  = 1'b1;
        IO_E                    = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b0;
        #(`TB_CYCLE * 1);
        ADDRESS                 = 20'h00000;
        DATA_IN                 = 8'h00;
        X_IO_OR_M               = 1'b0;
        R_OR_DT                 = 1'b1;
        IOW_N                   = 1'b1;
        MEMR_N                  = 1'b1;
        IOR_N                   = 1'b1;
        MEMW_N                  = 1'b1;
        IO_E                    = 1'b0;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : IO Write
    //
    task TASK_IO_WRITE(input [19:0] address, input [7:0] data);
    begin
        #(`TB_CYCLE * 0);
        ADDRESS                 = address;
        DATA_IN                 = data;
        X_IO_OR_M               = 1'b1;
        R_OR_DT                 = 1'b0;
        IOW_N                   = 1'b0;
        MEMR_N                  = 1'b1;
        IOR_N                   = 1'b1;
        MEMW_N                  = 1'b1;
        IO_E                    = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge       = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge       = 1'b0;
        #(`TB_CYCLE * 1);
        ADDRESS                 = 20'h00000;
        DATA_IN                 = 8'h00;
        X_IO_OR_M               = 1'b0;
        R_OR_DT                 = 1'b1;
        IOW_N                   = 1'b1;
        MEMR_N                  = 1'b1;
        IOR_N                   = 1'b1;
        MEMW_N                  = 1'b1;
        IO_E                    = 1'b0;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        TASK_IO_READ(20'h00040);
        TASK_IO_WRITE(20'h00040, 8'h55);

        #(`TB_CYCLE * 1);

        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end

endmodule

