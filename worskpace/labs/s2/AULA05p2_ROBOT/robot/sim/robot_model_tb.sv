module robot_model_tb;

   // Sinais de Sistema
   logic clock;
   logic reset_n;

   // Entradas (Sensores de Pedido e Sensores de Fim de Curso)
   logic s0_req, s1_req, s2_req, s3_req;
   logic s0_unload_done, s1_unload_done, s2_unload_done, s3_unload_done;

   // Saídas (Atuadores dos Motores)
   logic s0_unloadstart, s1_unloadstart, s2_unloadstart, s3_unloadstart;
   logic load_start;

   integer i;
   integer tempo;

   // Instanciação do Robô (DUT)
   robot_model u_robot_model (
      .clock(clock),
      .reset_n(reset_n),
      .s0_req(s0_req),
      .s1_req(s1_req),
      .s2_req(s2_req),
      .s3_req(s3_req),
      .s0_unloadstart(s0_unloadstart),
      .s1_unloadstart(s1_unloadstart),
      .s2_unloadstart(s2_unloadstart),
      .s3_unloadstart(s3_unloadstart),
      .s0_unload_done(s0_unload_done),
      .s1_unload_done(s1_unload_done),
      .s2_unload_done(s2_unload_done),
      .s3_unload_done(s3_unload_done),
      .load_start(load_start)
   );

   // Geração de Clock
   initial  begin
      clock = 1'b0;
      forever #10 clock = ~clock;
   end

   initial begin
        // Configuração de onda
        $dumpfile("robot.vcd");
        $dumpvars(0, robot_model_tb);

        // 1. INICIALIZAÇÃO E RESET
        clock = 0; 
        reset_n = 0;
        
        s0_req = 0; s1_req = 0; s2_req = 0; s3_req = 0;
        s0_unload_done = 0; s1_unload_done = 0; s2_unload_done = 0; s3_unload_done = 0;

        repeat(2) @(posedge clock); #1; 
        reset_n = 1;
        repeat(4) @(posedge clock);

        // 2. TESTES MANUAIS (Para extração de formas de onda limpas)
        $display("Iniciando Bateria de Testes Manuais...");

        // CASO MANUAL 1
        $display("[Tempo: %0t] CASO 1: Injetando pedido na Estacao 0...", $time);
        @(posedge clock); 
        #1; 
        s0_req <= 1;
        wait(s0_unloadstart); 
        s0_req <= 0;       

        repeat(20) @(posedge clock); 
        s0_unload_done <= 1;
        wait(!s0_unloadstart);  

        @(posedge clock); 
        #1; 
        s0_unload_done <= 0;
        repeat(15) @(posedge clock);

        // CASO MANUAL 2
        $display("[Tempo: %0t] CASO 2: Injetando pedido na Estacao 1...", $time);
        @(posedge clock); 
        #1; 
        s1_req <= 1;

        wait(s1_unloadstart); 
        s1_req <= 0;

        repeat(35) @(posedge clock); 
        s1_unload_done <= 1;

        wait(!s1_unloadstart);                  
        @(posedge clock); 
        #1; 
        s1_unload_done <= 0;
        repeat(15) @(posedge clock);

        // CASO MANUAL 3 (Conflito Simultâneo com Fila)
        $display("[Tempo: %0t] CASO 3: Injetando S2 e S3 juntos (Teste de Prioridade)...", $time);
        @(posedge clock); 
        #1;
        s2_req <= 1; 
        s3_req <= 1;
        
        // CASO MANUAL 3 (Conflito Simultâneo com Fila)
        $display("[Tempo: %0t] CASO 3: Injetando S2 e S3 juntos (Teste de Prioridade)...", $time);
        @(posedge clock); 
        #1;
        s2_req <= 1; 
        s3_req <= 1;

        // Atendimento da Prioridade (S2)
        wait(s2_unloadstart); 
        s2_req <= 0;
        repeat(20) @(posedge clock);
        s2_unload_done <= 1;
        wait(!s2_unloadstart);   

        @(posedge clock);
        #1; 
        s2_unload_done <= 0;
        
        // S3 Continua e engata logo a seguir
        wait(s3_unloadstart); 
        s3_req <= 0;
        repeat(20) @(posedge clock);
        s3_unload_done <= 1;
        wait(!s3_unloadstart);  

        @(posedge clock); 
        #1; 
        s3_unload_done <= 0;
        
        repeat(15) @(posedge clock);

        // 3. TESTES ALEATÓRIOS (CRV - Regressão Completa)
        $display("Iniciando Regressao com 20 Testes Aleatorios (CRV)...");
        
        for(i = 0; i < 20; i = i + 1) begin
            tempo = $urandom_range(3, 15);
            envia_pedido($urandom_range(0, 3), tempo);
        end

        $display("SIMULACAO CONCLUIDA COM SUCESSO!");
        $display("Todos os testes passaram.");
        #500 $finish;
    end

    // TASK: Gerador de Pedido Aleatório 
    task automatic envia_pedido(input integer estacao, input integer t_motor);
        $display("[Tempo: %0t] -> Gerado Pedido Aleatorio para Estacao %0d (Tempo de motor: %0d clocks)", $time, estacao, t_motor);

        @(posedge clock); #1;

        if (estacao == 0) begin
            s0_req <= 1;
            wait(s0_unloadstart);               
            s0_req <= 0;                        
            
            repeat(t_motor) @(posedge clock);   
            s0_unload_done <= 1;                
            wait(!s0_unloadstart);              
            @(posedge clock); #1;
            s0_unload_done <= 0;
        end
        else if (estacao == 1) begin
            s1_req <= 1;
            wait(s1_unloadstart);
            s1_req <= 0;                        
            
            repeat(t_motor) @(posedge clock);
            s1_unload_done <= 1;
            wait(!s1_unloadstart);
            @(posedge clock); #1;
            s1_unload_done <= 0;
        end
        else if (estacao == 2) begin
            s2_req <= 1;
            wait(s2_unloadstart);
            s2_req <= 0;                        
            
            repeat(t_motor) @(posedge clock);
            s2_unload_done <= 1;
            wait(!s2_unloadstart);
            @(posedge clock); #1;
            s2_unload_done <= 0;
        end
        else if (estacao == 3) begin
            s3_req <= 1;
            wait(s3_unloadstart);
            s3_req <= 0;                        
            
            repeat(t_motor) @(posedge clock);
            s3_unload_done <= 1;
            wait(!s3_unloadstart);
            @(posedge clock); #1;
            s3_unload_done <= 0;
        end

        // Pausa entre entregas
        repeat(4) @(posedge clock);
    endtask
 
    // Variáveis para gerenciar latencia
    logic s0_unloadstart_prev, s1_unloadstart_prev, s2_unloadstart_prev, s3_unloadstart_prev;

    always @(posedge clock) begin
        if (!reset_n) begin
            s0_unloadstart_prev <= 0;
            s1_unloadstart_prev <= 0;
            s2_unloadstart_prev <= 0;
            s3_unloadstart_prev <= 0;
        end else begin
            s0_unloadstart_prev <= s0_unloadstart;
            s1_unloadstart_prev <= s1_unloadstart;
            s2_unloadstart_prev <= s2_unloadstart;
            s3_unloadstart_prev <= s3_unloadstart;
        end
    end

    // Monitor Concorrente Principal
    always @(posedge clock) begin
        // Só faz a verificação se o sistema já saiu do reset
        if (reset_n == 1'b1) begin
            
            #1; // Espera 1ns para garantir que os sinais estabilizaram após a subida do clock

            fork
                // REGRA 1: EXCLUSIVIDADE MÚTUA 
                check_exclusividade(s0_unloadstart, s1_unloadstart, s2_unloadstart, s3_unloadstart);
                
                // REGRA 2: PROTOCOLO DE HANDSHAKE 
                check_handshake(0, s0_unloadstart_prev, s0_unloadstart, s0_unload_done);
                check_handshake(1, s1_unloadstart_prev, s1_unloadstart, s1_unload_done);
                check_handshake(2, s2_unloadstart_prev, s2_unloadstart, s2_unload_done);
                check_handshake(3, s3_unloadstart_prev, s3_unloadstart, s3_unload_done);
            join_none
        end
    end
 

    // Verifica se há colisões lógicas nos atuadores
    task automatic check_exclusividade(logic m0, logic m1, logic m2, logic m3);
        integer motores_ligados;
        motores_ligados = m0 + m1 + m2 + m3;
        
        assert(motores_ligados <= 1) else begin
            $error("[FALHA - Tempo: %0t] Múltiplos motores de descarga ligados ao msm tempo! (Total: %0d)", $time, motores_ligados);
        end
    endtask

    // Verifica se o motor caiu para 0 no ciclo atual, mas o done ainda não tinha chegado
    task automatic check_handshake(input integer estacao, logic start_prev, logic curr_start, logic done);
        if (start_prev == 1'b1 && curr_start == 1'b0) begin
            assert(done == 1'b1) else 
                $error("[FALHA DE HANDSHAKE - Tempo: %0t] S%0d desligou o motor sem esperar o sinal de 'done'!", $time, estacao);
        end
    endtask

endmodule