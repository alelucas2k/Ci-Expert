// //==============================================================================
// // File: arbiter_tb.v
// // Description:
// //   Simple testbench for the arbiter.
// //   Applies requests from client1 and client2 and observes grants.
// //==============================================================================

// module arbiter_tb;

//   // Inputs
//   reg clk;
//   reg reset_n;
//   reg priority_sel;
//   reg client1_req;
//   reg client2_req;

//   // Outputs
//   wire o_grant1;
//   wire o_grant2;

//   //--------------------------------------------------------------------------
//   // Clock generation
//   //--------------------------------------------------------------------------
//   initial begin
//       clk = 1'b0;
//       forever #5 clk = ~clk;
//   end

//   //--------------------------------------------------------------------------
//   // DUT instantiation
//   //--------------------------------------------------------------------------
//   arbiter uu_arbiter (
//       .clk         (clk),
//       .reset_n     (reset_n),
//       .priority_sel(priority_sel),
//       .client1_req (client1_req),
//       .client2_req (client2_req),
//       .o_grant1    (o_grant1),
//       .o_grant2    (o_grant2)
//   );

//   //--------------------------------------------------------------------------
//   // Stimulus
//   //--------------------------------------------------------------------------
//   initial begin
//       reset_n      = 1'b0;
//       priority_sel = 1'b0;
//       client1_req  = 1'b0;
//       client2_req  = 1'b0;

//       // Reset
//       #10 reset_n = 1'b0;
//       #10 reset_n = 1'b1;

//       // Case 1: client1 has priority
//       @(posedge clk);
//       #1;
//       priority_sel = 1'b1;
//       client1_req  = 1'b1;
//       client2_req  = 1'b0;

//       #10;
//       client1_req  = 1'b0;
//       client2_req  = 1'b1;

//       #10;
//       client1_req  = 1'b0;
//       client2_req  = 1'b0;

//       // Case 2: both request, client2 has priority
//       #10;
//       priority_sel = 1'b0;
//       client1_req  = 1'b1;
//       client2_req  = 1'b1;

//       // Case 3: both request, client1 has priority
//       #10;
//       priority_sel = 1'b1;
//       client1_req  = 1'b1;
//       client2_req  = 1'b1;

//       #100 $finish;
//   end

//   //--------------------------------------------------------------------------
//   // Dump
//   //--------------------------------------------------------------------------
//   initial begin
//       $dumpfile("arbiter.vcd");
//       $dumpvars(0,arbiter_tb);
//   end

// endmodule

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