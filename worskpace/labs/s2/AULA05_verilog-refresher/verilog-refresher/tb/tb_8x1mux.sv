module mux_top;

    logic clk;
    logic rstn;
    logic en;
    logic [7:0] din;
    logic [2:0] sel;
    logic dout;

    logic [7:0] prev_din;
    logic [2:0] prev_sel;
    logic prev_en;

    mux8x1 dut(
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .en(en),
        .din(din),
        .dout(dout)
    );


    always #5 clk = ~clk;

    initial begin

        $dumpfile("8x1mux.vcd");
        $dumpvars(0, mux_top);
        
        clk = 0;
        rstn =0;
        sel = 0;
        en = 0;  
        din = 0; 
        prev_din = 0;
        prev_sel = 0;

        repeat(2) @(posedge clk);
        rstn = 1;

        repeat(100)begin
            
            @(posedge clk);
            #1;
            en = $urandom_range(0,1);
            din = $urandom();
            sel = $urandom();

        end

        #2000 $finish;
    end

    always @(posedge clk) begin
        if (en) begin
            prev_din <= din;
            prev_sel <= sel;
        end
        prev_en <= en;
    end

    always @(posedge clk) begin
        #2;
        if (!rstn) begin
            assert (dout == 0) 
            else $error("Falha no reset");
            end
        else if (prev_en) begin
            assert (prev_din[prev_sel] == dout) 
            else $error("Erro: din[%0d] deveria ser %b mas é %b", prev_sel, prev_din[prev_sel], dout);
        end
    end

endmodule