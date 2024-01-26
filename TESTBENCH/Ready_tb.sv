
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

    logic           INTA_N;

    logic           IO_OR_M;
    logic           IO_E;

    logic           VIDEO_READY;
    logic           SOUND_READY;
    logic           EXT_READY;

    logic           RDY;

    READY u_Ready (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        cpu_clock_posedge   = 1'b0;
        cpu_clock_negedge   = 1'b0;
        INTA_N              = 1'b1;
        IO_OR_M             = 1'b0;
        IO_E                = 1'b0;
        VIDEO_READY         = 1'b1;
        SOUND_READY         = 1'b1;
        EXT_READY           = 1'b1;

        #(`TB_CYCLE * 12);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;

        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : INTA
    //
    task TASK_INTA();
    begin
        IO_OR_M             = 1'b1;

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        #(`TB_CYCLE * 0);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        INTA_N              = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        INTA_N              = 1'b1;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);


        IO_OR_M             = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : IO
    //
    task TASK_IO();
    begin
        IO_OR_M             = 1'b1;

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        IO_E                = 1'b1;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        IO_E                = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);


        IO_OR_M             = 1'b0;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : READY Signal
    //
    task TASK_READY_SIG();
    begin
        VIDEO_READY         = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        VIDEO_READY         = 1'b1;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);


        SOUND_READY         = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        SOUND_READY         = 1'b1;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);


        EXT_READY           = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        EXT_READY           = 1'b1;
        #(`TB_CYCLE * 1);

        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;

        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        TASK_INTA();
        TASK_IO();
        TASK_READY_SIG();
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

