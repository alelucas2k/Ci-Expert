// 1. Definição da Interface
interface somador_if(input logic clk);
  logic [7:0] a;
  logic [7:0] b;
  logic [8:0] soma;
  logic       rst_n;
endinterface

module top;
  // 2. Gerador de Clock
  logic clk = 0;
  always #5 clk = ~clk; // Clock de 10 unidades de tempo

  // 3. Instância da Interface
  somador_if cabo(clk);

  // 4. Instância do Hardware (DUT)
  // Conecte as portas do seu 'somador' aos sinais da interface 'cabo'
  somador u_adder (
    .a    (cabo.a),
    .b    (cabo.b),
    .soma (cabo.soma),
    .rst_n(cabo.rst_n) 
  );

  // 5. Bloco de Estímulo
  initial begin
    // Habilite o GTKWave
    $dumpfile("simulacao.vcd");
    $dumpvars(0, top);

    // --- SEU TRABALHO COMEÇA AQUI ---
    
    // a) Inicialize o reset (lembre-se: rst_n costuma ser ativo em 0)
    cabo.rst_n = 0; 
    
    // b) Espere dois ciclos de clock
    repeat(2) @(posedge clk);
    
    // c) Desative o reset
    cabo.rst_n = 1;

    // d) Aplique valores para testar
    cabo.a = 8'd10;
    cabo.b = 8'd20;

    // e) Espere um pouco para o hardware calcular e finalize
    #20;
    $display("Teste finalizado. Resultado: %d", cabo.soma);
    $finish;
  end

  // 6. Seu Monitor (Opcional, mas recomendado)
  // Tente colocar o assert que discutimos antes aqui embaixo!
  always @(posedge cabo.clk) begin
    if(!cabo.rst_n)
        assert (cabo.soma == 0) 
        if else(cabo.soma == (cabo.a + cabo.b))
            else error_process
  end

endmodule