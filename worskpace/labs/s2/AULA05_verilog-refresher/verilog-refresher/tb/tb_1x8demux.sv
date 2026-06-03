module demux_top;

    logic clk;
    logic rstn;
    logic [2:0] sel;
    logic en;
    logic din;
    logic [7:0] dout;

    demux1x8 dut(
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .en(en),
        .din(din),
        .dout(dout)
    );

    logic [2:0] prev_sel;
    logic prev_in;

    always #5 clk = ~clk;

    initial begin

        $dumpfile("1x8demux.vcd");
        $dumpvars(0,demux_top);

        clk = 0;
        en  = 0;
        rstn= 0;
        sel = 0;
        din = 0;
        prev_in = 0;
        prev_sel = 000;

        repeat(2) @(posedge clk);
        rstn = 1;

        repeat(10)begin
            
            @(posedge clk);
            #1;
            en = 1;
            din = $urandom_range(0,1);
            sel = $urandom();

            @(posedge clk);
            #1;
            en = 0;

        end
         #500 $finish;
    end

    always @(posedge clk) begin
        if (en) begin
            prev_in <= din;
            prev_sel <= sel;           
        end
    end


    always @(posedge clk) begin
        #2;
        if(!rstn)begin
            assert (dout == 0) 
            else $error("Falha no reset. Dout n zerou!");
            end
        else if(en)begin
            assert (dout[prev_sel] == prev_in) 
            else   $error("Erro: dout[%0d] deveria ser %b, mas é %b", sel, prev_in, dout[prev_sel]);
        end 
    end
endmodule