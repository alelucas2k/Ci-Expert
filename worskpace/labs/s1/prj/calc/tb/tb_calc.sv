module tb_calc;
  
  //1. Declarar os sinais - "cabos de conexão" 
  logic [7:0] t_a, t_b; //usar t_ pra identificar que é do tb
  logic [1:0] t_op;
  logic [7:0] t_result;
  
  //2. Instanciar o dut (conectar o tb ao compontente)
  //nome do módulo + nome da instancia
  calc4 dut(
  	
    .a(t_a), //conectar o sinal a do dut ao t_a do tb
    .b(t_b),
    .op(t_op),
    .result(t_result)
          
    
  );
  
  //3. Criar o bloco de estiímulos
	initial begin
      //configurar dump p/ ver as ondas
      $dumpfile("dump.vcd");
      $dumpvars(0, tb_calc);

      //teste soma
      //seguir format <tamanho>'<base><valor>
      t_a = 8'd10; t_b = 8'd5; t_op = 2'b00;
      #10

      //teste sub
      t_a = 8'd20; t_b = 8'd8; t_op = 2'b01;
      #10

      //teste multi
      t_a = 8'd4; t_b = 8'd3; t_op = 2'b10;
      #10

      //teste div
      t_a = 8'd100; t_b = 8'd10; t_op = 2'b11;
      #10

      $display("fim dos testes");
      $finish;
    end
endmodule
