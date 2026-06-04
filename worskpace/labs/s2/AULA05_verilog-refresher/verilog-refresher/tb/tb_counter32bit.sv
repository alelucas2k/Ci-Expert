module counter_top;

    // Sinais de controle e dados
    logic clk;
    logic reset_n;
    logic en;
    logic load;
    
    logic [31:0] counter_out;
    logic counter_overflow;

    // Variáveis para rastrear o estado no clock anterior
    logic prev_en;
    logic prev_load;
    logic [31:0] prev_counter_out;
    logic prev_counter_overflow;

    // Instanciação do DUT
    counter_overflow dut(
        .clk(clk),
        .reset_n(reset_n),
        .en(en),
        .load(load),
        .counter_out(counter_out),
        .counter_overflow(counter_overflow)
    );

    // Geração do Clock
    always #5 clk = ~clk;

    initial begin
        // Configuração de onda
        $dumpfile("counter32bit.vcd");
        $dumpvars(0, counter_top);

        // Condições Iniciais
        clk = 0;
        reset_n = 0;
        en = 0;
        load = 0;
        
        prev_en = 0;
        prev_load = 0;
        prev_counter_out = 0;
        prev_counter_overflow = 0;

        // Aplica o Reset
        repeat(2) @(posedge clk);
        reset_n = 1;

        // 1. Força o Load primeiro para deixarmos o contador perto do limite
        @(posedge clk); #1;
        load = 1;
        en = 0;

        // 2. Tira o Load, liga o Enable e deixa contar até estourar (Overflow)
        @(posedge clk); #1;
        load = 0;
        en = 1;

        // Conta por 15 ciclos (como o load joga para o final com "1000", ele vai estourar aqui)
        repeat(15) begin
            @(posedge clk); #1;
        end

        // 3. Estímulos Aleatórios
        repeat(50) begin
            @(posedge clk); #1;
            // Deixa o enable alto com mais frequência (80% de chance) para o contador andar
            en = ($urandom_range(0, 9) > 2) ? 1 : 0; 
            // O load acontece raramente (10% de chance)
            load = ($urandom_range(0, 9) > 8) ? 1 : 0; 
        end

        #1000 $finish;
    end

    // Armazena estados para contornar o atraso sequencial (latência de 1 clock)
    always @(posedge clk) begin
        prev_en <= en;
        prev_load <= load;
        prev_counter_out <= counter_out;
        prev_counter_overflow <= counter_overflow;
    end

    // Checker Concorrente
    always @(posedge clk) begin
        #2; // Espera os sinais estabilizarem
        
        // teste da saída quando reset
        if (!reset_n) begin
            assert ({counter_overflow, counter_out} == 33'd0) 
            else $error("Falha no reset! A saída não zerou.");
        end
        
        // testa se o Load funciona e carrega a constante correta (assumindo prioridade sobre en)
        else if (prev_load) begin
            assert ({counter_overflow, counter_out} == 33'b111111111111111111111111111111000)
            else $error("Erro no Load: Saida gerou %b_%b. Incompatível!", counter_overflow, counter_out);
        end
        
        // testa se o contador incrementa (+1) corretamente quando habilitado
        else if (prev_en) begin
            assert ({counter_overflow, counter_out} == {prev_counter_overflow, prev_counter_out} + 33'd1)
            else $error("Erro de Incremento: En estava 1, mas o valor anterior não somou +1 corretamente!");
        end
        
        // testa se a saída é retida (Hold) quando não há load nem enable
        else if (!prev_en && !prev_load) begin
            assert ({counter_overflow, counter_out} == {prev_counter_overflow, prev_counter_out})
            else $error("Erro Default: O contador alterou o valor sem estar habilitado!");
        end
    end

endmodule