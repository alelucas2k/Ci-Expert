# Projeto: Calculadora de 8 bits (Calc4)

Este diretório contém a implementação de uma unidade aritmética combinacional simples, desenvolvida em **SystemVerilog** como parte das práticas de laboratório da residência.

##  Estrutura do Projeto

* **`rtl/`**: Contém o código fonte do hardware (`dut.sv`).
* **`tb/`**: Contém o ambiente de teste e estímulos (`tb_calc.sv`).

##  Descrição Rápida

O módulo principal (`calc4`) realiza quatro operações básicas controladas por um seletor de 2 bits:
1.  **Soma** (`00`)
2.  **Subtração** (`01`)
3.  **Multiplicação** (`10`)
4.  **Divisão** (`11`)

Os operandos e o resultado possuem largura de **8 bits**.
