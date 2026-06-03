module adder_top;
    logic en;
    logic clk;
    logic reset_n;
    logic [31:0] op_a;
    logic [31:0] op_b;
    logic [31:0] adder_out;
    logic carry_out;


  adder dut(
    .en(en),
    .clk(clk),
    .reset_n(reset_n),
    .op_a(op_a),
    .op_b(op_b),
    .adder_out(adder_out),
    .carry_out(carry_out)
  );

  //variaveis para armazenar os valores do estado anterior
  logic [31:0] prev_a;
  logic [31:0] prev_b;
  logic en_prev;

  always #5 clk = ~clk;

  initial begin

    $dumpfile("adder32.vcd");
    $dumpvars(0, adder_top);

    en = 0;
    clk = 0;
    reset_n = 0;
    op_a = 0;
    op_b = 0;

    repeat(2) @(posedge clk); // Espera 2 clocks no reset
    reset_n = 1;   

    repeat(10)begin

      //gerar novos dados a cada 10 unidades de tempo
      @(posedge clk);
      #1; //esperar uma unidade após a borda positiva
      en = 1;
      op_a = $urandom();
      op_b = $urandom();

      @(posedge clk);
      #1;
      en = 0;
      
    end;    
    #100 $finish;
  end

  //armazenar o estado anterior
  always @(posedge clk) begin
    prev_a <= op_a;
    prev_b <= op_b;
    en_prev <= en;
  end

  always @(posedge clk) begin
    #1; 
    // aguardar 1 unidade de tempo para o dado estabilizar
    if(!reset_n)begin
        assert (adder_out == 0) 
      else $error("Falha! Adder out não zerou no reset.");
      end
    else if(en_prev) begin
      assert (adder_out == (prev_a + prev_b)) 
    else $error("Erro: %d + %d != %d", prev_a, prev_b, adder_out);
    end
  end

endmodule