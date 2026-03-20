module calc4 (
    input  logic [7:0] a,      // Operando A
    input  logic [7:0] b,      // Operando B
    input  logic [1:0] op,     // Seletor de Operação
    output logic [7:0] result  // Resultado
);

    // Bloco combinacional para definir a operação baseada em 'op'
    always_comb begin
        case (op)
            2'b00:   result = a + b;      // Soma
            2'b01:   result = a - b;      // Subtração
            2'b10:   result = a * b;      // Multiplicação
            2'b11:   result = a / b;      // Divisão
            default: result = 8'd0;       // Valor padrão (segurança)
        endcase
    end

endmodule
