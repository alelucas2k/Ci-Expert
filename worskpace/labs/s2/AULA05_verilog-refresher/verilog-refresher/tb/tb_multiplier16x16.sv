module multi_tb;

    logic clk;
    logic reset_n;
    logic en;
    logic [15:0] op_a;
    logic [15:0] op_b;
    logic [31:0] multi_out;

    logic [15:0] prev_a;
    logic [15:0] prev_b;
    logic prev_en;
    logic [31:0] prev_out;

multiplier dut(
    .clk(clk),
    .reset_n(reset_n),
    .en(en),
    .op_a(op_a),
    .op_b(op_b),
    .multi_out(multi_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("multiplier16x16.vcd");
    $dumpvars(0, multi_tb);

    clk = 0;
    reset_n = 0;
    en = 0;
    op_a = 0;
    op_b = 0;
    prev_a = 0;
    prev_b = 0;

    repeat(2) @(posedge clk);
    reset_n = 1;

    // teste de zero 
    @(posedge clk);
    #1;
    en = 1;
    op_a = 16'd0;
    op_b = 16'd32000;

    // estresse maximo 
    @(posedge clk);
    #1;
    en = 1;
    op_a = 16'hFFFF; // 65535 em decimal
    op_b = 16'hFFFF; // 65535 em decimal

    repeat(100)begin
        @(posedge clk);
        #1;
        en = $urandom_range(0,1);
        op_a = $urandom();
        op_b = $urandom();
    end

    #100 $finish;
end

always @(posedge clk) begin
    // registrando valores para resolver problema de sincronia
    if (en) begin
        prev_a <= op_a;
        prev_b <= op_b;
    end
    prev_en <= en;
    prev_out <= multi_out;
end

always @(posedge clk) begin
    #2;
    //teste de reset
    if (!reset_n) begin
        assert (multi_out == 0) 
        else $error("Erro no reset, out == %d", multi_out);
    end
    //teste do resultado da multiplicacao
    else if (prev_en) begin
        assert (multi_out == (prev_a * prev_b)) 
        else $error("Erro: out = %d, deveria ser %d", multi_out, (prev_a*prev_b));
    end
    //teste de permanencia da saida quando en = 0
    else if (!prev_en) begin
        assert (multi_out == prev_out) 
        else $error("Erro quando en = 0, out = %d, deveria ser %d", multi_out, prev_out);
    end
end


endmodule