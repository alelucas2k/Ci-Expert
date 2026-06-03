module matrix2x2_tb;

    logic clk;
    logic rstn;
    logic en;
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] Res;

    // Memórias para latência de 1 clock
    logic [31:0] prev_A;
    logic [31:0] prev_B;
    logic prev_en;
    logic [31:0] prev_Res;

    // Fatias de 8 bits para facilitar a matemática do Checker
    logic [7:0] a00, a01, a10, a11;
    logic [7:0] b00, b01, b10, b11;
    logic [7:0] exp00, exp01, exp10, exp11;

    matrix2x2_mult dut(
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .A(A),
        .B(B),
        .Res(Res)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("matrixmult.vcd");
        $dumpvars(0, matrix2x2_tb);

        clk = 0;
        rstn = 0;
        en = 0;
        A = 0;
        B = 0;

        repeat(2) @(posedge clk);
        rstn = 1;

        // Corner Case: Matriz Nula (Zero)
        @(posedge clk);
        #1;
        en = 1;
        A = 32'd0;
        B = 32'hFFFFFFFF; // Tentando multiplicar tudo por zero

        // Corner Case: Matriz Identidade
        @(posedge clk);
        #1;
        en = 1;
        A = {8'd1, 8'd0, 8'd0, 8'd1}; 
        B = {8'd5, 8'd6, 8'd7, 8'd8}; 

        repeat(50) begin
            @(posedge clk);
            #1;
            en = $urandom_range(0,1);
            A = $urandom();
            B = $urandom();
        end

        #100 $finish;
    end

    always @(posedge clk) begin
        //registrando estados
        if (en) begin
            prev_A <= A;
            prev_B <= B;
        end
        prev_en <= en;
        prev_Res <= Res;
    end


    // Desempacota as matrizes do ciclo passado
    assign {a00, a01, a10, a11} = prev_A;
    assign {b00, b01, b10, b11} = prev_B;

    // Calcula os valores esperados. 
    assign exp00 = (a00 * b00) + (a01 * b10);
    assign exp01 = (a00 * b01) + (a01 * b11);
    assign exp10 = (a10 * b00) + (a11 * b10);
    assign exp11 = (a10 * b01) + (a11 * b11);

    always @(posedge clk) begin
        #2;
        if (!rstn) begin
            assert (Res == 32'd0) 
            else $error("Falha no Reset. Res = %h", Res);
        end
        else if (prev_en) begin
            assert (Res == {exp00, exp01, exp10, exp11}) 
            else $error("Erro Matemático: Res = %h, Esperado = %h", Res, {exp00, exp01, exp10, exp11});
        end
        else if (!prev_en) begin
            assert (Res == prev_Res) 
            else $error("Erro de Latch: Enable caiu, mas Res mudou de %h para %h", prev_Res, Res);
        end
    end

endmodule