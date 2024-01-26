
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

    logic           HLDA;

    logic           RD_N;
    logic           WR_N;
    logic           IO_OR_M;
    logic           DT_OR_R;
    logic           DEN_N;
    logic           ALE;

    logic           X_IO_OR_M;
    logic           R_OR_DT;

    logic           IOW_N;
    logic           MEMR_N;
    logic           IOR_N;
    logic           MEMW_N;
    logic           IO_E;

    BUS_ARBITER u_Bus_Arbiter (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        cpu_clock_posedge   = 1'b0;
        cpu_clock_negedge   = 1'b0;
        HLDA                = 1'b0;
        RD_N                = 1'b1;
        WR_N                = 1'b1;
        IO_OR_M             = 1'b1;
        DT_OR_R             = 1'b1;
        DEN_N               = 1'b1;
        ALE                 = 1'b0;
        #(`TB_CYCLE * 12);
    end
    endtask

    task TASK_BASIC_SYSTEM_TIMING();
    begin
        #(`TB_CYCLE * 0);
        //
        // Read
        //
        // T1
        ALE                 = 1'b1;
        DT_OR_R             = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        ALE                 = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // T2

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        RD_N                = 1'b0;
        DEN_N               = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // T3

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        HLDA                = 1'b1;
        #(`TB_CYCLE * 1);
        HLDA                = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // Twait

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        RD_N                = 1'b1;
        DEN_N               = 1'b1;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // T4

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        DT_OR_R             = 1'b1;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 12);

        //
        // Write
        //
        // T1
        ALE                 = 1'b1;

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        ALE                 = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // T2

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        WR_N                = 1'b0;
        DEN_N               = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // T3

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        HLDA                = 1'b1;
        #(`TB_CYCLE * 1);
        HLDA                = 1'b0;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // Twait

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        WR_N                = 1'b1;

        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_negedge   = 1'b0;
        #(`TB_CYCLE * 1);

        // T4

        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b1;
        #(`TB_CYCLE * 1);
        cpu_clock_posedge   = 1'b0;
        #(`TB_CYCLE * 1);

        DEN_N               = 1'b1;

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
        // IO
        IO_OR_M             = 1'b1;
        TASK_BASIC_SYSTEM_TIMING();
        // MEMORY
        IO_OR_M             = 1'b0;
        TASK_BASIC_SYSTEM_TIMING();

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

