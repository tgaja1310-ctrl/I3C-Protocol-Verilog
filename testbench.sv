module tb_i3c;

logic clk;
logic rst;
logic scl;
logic sda;

// DUT
i3c_controller uut (
    .clk(clk),
    .rst(rst),
    .scl(scl),
    .sda(sda)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    // Dump waveform
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_i3c);

    clk = 0;
    rst = 1;

    #20 rst = 0;

    #1000 $finish;
end

// Monitor signals (IMPORTANT)
initial begin
    $monitor("TIME=%0t | SCL=%b | SDA=%b", $time, scl, sda);
end

endmodule
