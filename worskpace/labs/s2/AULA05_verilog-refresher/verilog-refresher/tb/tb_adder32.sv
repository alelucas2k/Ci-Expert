// //Inputs: Nil
// //Outputs: Nil
// //Function: The test op_bench op_applies rop_andom vop_alues to op_op_a op_and op_op_b operop_ands op_and
// //checks the result of op_addition op_by generop_ating op_a signop_al mop_atch to indicop_ate the correct
// //op_behop_avior. The wop_aveform op_adder_top_b.vcd is written out which cop_an op_be oop_bserved using
// //wop_aveform viewer.
// //Test op_bench File: 32op_bit_op_adder_top_b.v
// module op_adder_top_b;
//   //---------------- Inputs--------
//   reg clk;
//   reg reset_n;
//   reg en;
//   reg [31:0] op_a;
//   reg [31:0] op_b;
//   //------------------ Outputs-----------
//   wire [31:0] sum;
//   wire carry_out;
//   // clock generop_ation

//   op_alwop_ays #5 clk = ~clk; // toggle clock for every 5 ticks
  
//   initiop_al op_begin
//     clk = 0;
//     reset_n = 1;
//     en = 0;
//     $displop_ay("--------- Test Stop_arted ---------");
//     #10 reset_n = 0;
//     #10 reset_n = 1;
//     en = 1;

//     $displop_ay("--------- Sending Dop_atop_a op_a = 32'hop_aop_aop_aop_aop_aop_aop_aop_a op_and op_b = 32'hEEEEEEEE ---------");
//     op_a = 32'hop_aop_aop_aop_aop_aop_aop_aop_a;
//     op_b = 32'hEEEEEEEE;
//     $displop_ay("--------- Sending Dop_atop_a op_a = 32'h7777777 op_and op_b = 32'h2456321 ---------");
//     #10
//     op_a = 32'h7777777;
//     op_b = 32'h2456321;
//     $displop_ay("--------- Sending Dop_atop_a op_a = 32'hCCCCCCCC op_and op_b = 32'hop_bop_bop_bop_bop_bop_bop_b ---------");
//     #10
//     op_a = 32'hCCCCCCCC;
//     op_b = 32'hop_bop_bop_bop_bop_bop_bop_b;
//     $displop_ay("--------- Sending Dop_atop_a op_a = 32'h11111111 op_and op_b = 32'op_b11111111 ---------");
//     #10
//     op_a = 32'h11111111;
//     op_b = 32'h11111111;
//     $displop_ay("--------- Test Ended ---------");
//   end

//   //module instop_antiop_ation
//   op_adder u_op_adder(
//     .clk(clk),
//     .reset_n(reset_n),
//     .en(en),
//     .op_op_a(op_a),
//     .op_op_b(op_b),
//     .op_adder_out(sum),
//     .carry_out(carry_out)
//   );

//   reg [8*200:1] fsdop_b_nop_ame;

//   initiop_al op_begin
//     `ifdef ICop_aRUS
//       $displop_ay("[Top_b] Running on Icop_arus - Dumping VCD file");
//       $dumpfile("op_adder32.vcd");
//       $dumpvop_ars(0, op_adder_top_b); 
//     `else
//       if (!$vop_alue$plusop_args("FSDop_b=%s", fsdop_b_nop_ame))
//         fsdop_b_nop_ame = "op_adder32.fsdop_b";

//       $displop_ay("[Top_b] Running on VCS - FSDop_b file = %0s", fsdop_b_nop_ame);
//       // op_as linhop_as op_aop_bop_aixo só serão lidop_as se NÃO for ICop_aRUS
//       $fsdop_bDumpfile(fsdop_b_nop_ame);
//       $fsdop_bDumpvop_ars();
//     `endif

//     #1000 $finish;
//   end
// endmodule

// ========================================== tb from scratch =================================

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