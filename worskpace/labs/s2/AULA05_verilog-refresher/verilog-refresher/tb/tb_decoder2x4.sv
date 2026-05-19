// 




module decoder_top;
    logic clk;
    logic rstn;
    logic en;
    logic [1:0] din;
    logic [3:0] dout;

    logic [1:0] din_prev;
    logic prev_en;
    logic [3:0] prev_dout;


decoder2x4 dut(
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .din(din),
    .dout(dout)
);


always #5 clk = ~clk;

initial begin
    $dumpfile("decoder2x4.vcd");
    $dumpvars(0, decoder_top);


    clk = 0;
    rstn = 0;
    en = 0;
    din = 0;
    din_prev = 0;

    repeat(2) @(posedge clk);
    rstn = 1;

    repeat(100)begin
        @(posedge clk);
        #1;
        en = $urandom_range(0,1);
        din = $urandom_range(0,3);
    end

    
    #1000 $finish;
end

always @(posedge clk) begin
    //armazena estados para contonar o atraso de dout em relação a din
    if (en) begin
        din_prev <= din;
    end
    prev_dout <= dout;
    prev_en <= en;
end


always @(posedge clk) begin
    #2;
    //teste dout quando reset
    if (!rstn) begin
        assert (dout == 4'b0000) 
        else $error("Falha no reset!\n");
    end
    //testa se dout bate com o din
    else if (prev_en) begin
        assert (dout == (4'b0001 << din_prev)) 
        else $error("Erro: dout deveria ser %b, mas é %b", (4'b0001 << din_prev), dout);
    end
    //testa se dout é o esperado quando en=o
    else if (!prev_en) begin
        assert (dout == prev_dout) 
        else $error("Erro no dout q=0!\n");
    end
end

endmodule 
