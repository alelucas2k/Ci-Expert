module arbiter_top;

    logic clk;
    logic reset_n;

    logic priority_sel;
    logic client1_req;
    logic client2_req;

    logic o_grant1;
    logic o_grant2;

arbiter dut(
    .clk(clk),
    .reset_n(reset_n),
    .priority_sel(priority_sel),
    .client1_req(client1_req),
    .client2_req(client2_req),
    .o_grant1(o_grant1),
    .o_grant2(o_grant2)
);

always #5 clk = ~clk;
integer i;

initial begin

    $dumpfile("arbiter.vcd");
    $dumpvars(0, arbiter_top);

    clk = 0;
    reset_n = 0;
    priority_sel = 0;
    client1_req = 0;
    client2_req = 0;

    repeat(2) @(posedge clk);
    reset_n = 1;

    for(i=0; i<8; i=i+1)begin
        @(posedge clk);
        priority_sel <= i[2];
        client1_req <= i[1];
        client2_req <= i[0];

        @(posedge clk);
        client1_req <= 0;
        client2_req <= 0;
        repeat(4) @(posedge clk);
    end

    #1000 $finish;
end

always @(posedge clk) begin
    #1;
    
    if (reset_n && (client1_req || client2_req)) begin
        fork
            check_saidas(priority_sel, client1_req, client2_req);
        join_none
        
    end
end

task automatic check_saidas(input logic p_sel, input logic r1, input logic r2);

    repeat(2) @(posedge clk);
    #1;

    if (r1 && r2) begin
        if (p_sel == 1) begin
            assert (o_grant1 == 1) else $error("Falha: Prioridade 1 devia atender cliente 1 primeiro");
            
            @(posedge clk); 
            #1; 
            
            assert (o_grant2 == 1) else $error("Falha: Fila nao andou para cliente 2");    
        end else begin
            assert (o_grant2 == 1) else $error("Falha: Prioridade 0 devia atender cliente 2 primeiro");
            
            @(posedge clk); 
            #1; 
            
            assert (o_grant1 == 1) else $error("Falha: Fila nao andou para cliente 1");    
        end
    end
    else if (r1 && !r2) begin

        assert (o_grant1 == 1) else $error("Falha, cliente 1 pediu sozinho mas não recebeu a vez! p_sel = %b", p_sel);
    end
    else if (!r1 && r2) begin
        
        assert (o_grant2 == 1) else $error("Falha, cliente 2 pediu sozinho mas não recebeu a vez! p_sel = %b", p_sel);
    end

endtask

always @(posedge clk)begin
    #2;
    if (!reset_n) begin
        assert (o_grant1 == 0 && o_grant2 == 0) 
        else $error("Erro no reset");
    end
end


endmodule