// //Function: The test bench applies random values to 3-bit select lines and checks the
// //dout. The waveform demux_tb.vcd can be observed using waveform viewer.
// //Test bench file: demux3x8_tb.v

// module demux1x8_tb;

// // Inputs
// reg clk;
// reg rstn;
// reg en;
// reg [2:0] sel;
// reg din;

// // Outputs
// wire [7:0] dout;

// // clock generation
// always #5 clk = ~clk; // toggle clock for every 5 ticks

// initial begin
//     clk = 0;
//     rstn = 0;
//     en = 0;

//     //$display("--------- Test Started ---------");

//     #10 rstn = 0;
//     #10 rstn = 1;

//     en = 1;

//     sel = 3'b000; din = 1'b1;
//     #10 sel = 3'b001; din = 1'b1;
//     #10 sel = 3'b010; din = 1'b1;
//     #10 sel = 3'b011; din = 1'b1;
//     #10 sel = 3'b100; din = 1'b1;
//     #10 sel = 3'b101; din = 1'b1;
//     #10 sel = 3'b110; din = 1'b1;
//     #10 sel = 3'b111; din = 1'b1;

//     #100 $finish;
// end

// demux1x8 uut (
//     .clk(clk),
//     .rstn(rstn),
//     .en(en),
//     .sel(sel),
//     .din(din),
//     .dout(dout)
// );

// initial begin
//     $dumpfile("1x8demux.vcd");
//     $dumpvars(0, demux1x8_tb);
// end

// endmodule

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