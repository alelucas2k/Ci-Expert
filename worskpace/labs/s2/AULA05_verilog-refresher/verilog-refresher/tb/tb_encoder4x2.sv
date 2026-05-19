// //Function: The test bench applies random values to 4-bit din and checks the encoded
// //2-bit dout. The waveform encoder4x2_tb.vcd can be observed using waveform
// //viewer.
// //Test bench file: encoder4x2_tb.v

// module encoder4x2_tb;

// // Inputs
// reg [3:0] din;
// reg en;
// reg clk;
// reg rstn;

// // Outputs
// wire [1:0] dout;

// // clock generation
// always #5 clk = ~clk; // toggle clock for every 5 ticks

// initial begin
//     // Initialize Inputs
//     clk = 0;
//     rstn = 1;
//     en = 0;

//     //$display("--------- Test Started ---------");

//     #10 rstn = 0;
//     #10 rstn = 1;

//     en = 1;

//     din = 4'b0001;
//     #10 din = 4'b0010;
//     #10 din = 4'b0100;
//     #10 din = 4'b1000;

//     #100 $finish;
// end

// encoder4x2 uut (
//     .clk(clk),
//     .din(din),
//     .dout(dout),
//     .rstn(rstn),
//     .en(en)
// );

// initial begin
//     $dumpfile("encoder4x2.vcd");
//     $dumpvars(0, encoder4x2_tb);
// end

// endmodule

module encoder_top;

    logic en;
    logic clk;
    logic rstn;
    logic [3:0] din;
    logic [1:0] dout;

    logic [3:0] din_prev;
    logic prev_en;
    logic [1:0] prev_dout;

encoder4x2 dut(
    .clk(clk),
    .en(en),
    .rstn(rstn),
    .din(din),
    .dout(dout)
);

always #5 clk = ~clk;

initial begin
    
    $dumpfile("encoder4x2.vcd");
    $dumpvars(0, encoder_top);

    clk = 0;
    en = 0;
    rstn = 0;
    din = 0;
    prev_dout = 0;
    prev_en = 0;
    din_prev = 0;

    repeat(2) @(posedge clk);
    rstn = 1;

    repeat(20)begin
        @(posedge clk);
        #1;
        en = $urandom_range(0,1);
        din = $urandom_range(0,9);
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
        assert (dout == 2'b00) 
        else $error("Falha no reset!\n");
    end
    
    //testa se dout bate com o din
    else if (prev_en) begin
        // 1. O Checker detecta se a entrada foi um número One-Hot válido (1, 2, 4 ou 8)
        if (din_prev == 4'b0001 || din_prev == 4'b0010 || din_prev == 4'b0100 || din_prev == 4'b1000) begin
            assert (din_prev == (4'b0001 << dout)) 
            else $error("Erro: din_prev era %b, dout gerou %b. Incompatível!", din_prev, dout);
        end
        // 2. O Checker detecta que a entrada foi "lixo" (ex: 3, 5, 9...)
        else begin
            assert (dout == 2'b00)
            else $error("Erro Default: O lixo %b não zerou a saída!", din_prev);
        end
    end
    
    //testa se dout é o esperado quando en=0
    else if (!prev_en) begin
        assert (dout == prev_dout) 
        else $error("Erro no dout q=0!\n");
    end
end

endmodule