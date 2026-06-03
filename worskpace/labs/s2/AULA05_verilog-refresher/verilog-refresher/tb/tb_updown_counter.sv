module updown_counter_top;

    logic clk;
    logic resetn;
    logic en;
    logic [3:0] up_counter;
    logic [3:0] down_counter;

    logic [3:0] prev_up;
    logic [3:0] prev_down;
    logic prev_en;


updowncounter dut(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .up_counter(up_counter),
    .down_counter(down_counter)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("updown_counter.vcd");
    $dumpvars(0, updown_counter_top);

    clk = 0;
    resetn = 0;
    en = 0;

    repeat(2) @(posedge clk);
    resetn = 1;

    @(posedge clk);
    #1;
    en = 1;
    repeat(20) @(posedge clk); // Deixa rodar livremente por 20 clocks

    repeat(20)begin
        @(posedge clk);
        #1;
        en = $urandom_range(0,1);
    end

    repeat(4) @(posedge clk);
    resetn = 0;

    #500 $finish;

end

always @(posedge clk) begin
    prev_down <= down_counter;
    prev_up <= up_counter;
    prev_en <= en;
end

always @(posedge clk) begin
    #2;
    if (!resetn) begin
        assert (up_counter == 4'b0000 && down_counter == 4'b1111) 
        else $error("Erro no reset!\n");
    end
    else if (prev_en) begin
        assert (up_counter == (prev_up + 4'b0001) && down_counter == (prev_down-4'b0001)) 
        else $error("Up_counter == %d e prev + 1 == %d, down_counter == %d e prev_down + 1 == %d", up_counter, (prev_up+1), down_counter, (prev_down-1));
    end
    else if (!prev_en) begin
        assert (up_counter == prev_up && down_counter == prev_down) 
        else $error("Erro no enable, up_counter devia ser %d mas é %d, down_couter devia ser %d mas é %d", up_counter, prev_up, down_counter, prev_down);
    end
end

endmodule