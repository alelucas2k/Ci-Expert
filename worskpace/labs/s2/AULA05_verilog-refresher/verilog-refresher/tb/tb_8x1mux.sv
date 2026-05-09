//Function: The test bench applies random values to 3-bit select lines and checks the
//dout. The waveform mux8x1_tb.vcd can be observed using waveform viewer.
//Test bench file: mux8x1_tb.v

// module mux8x1_tb;

// // Inputs
// reg clk;
// reg rstn;
// reg en;
// reg [7:0] din;
// reg [2:0] sel;

// // Outputs
// wire dout;

// // clock generation
// always #5 clk = ~clk; // toggle clock for every 5 ticks

// initial begin
//     // Initialize Inputs
//     clk = 0;
//     rstn = 1;
//     en = 0;

//     //$display("--------- Test Started ---------");

//     #10 rstn = 0;
//     #10 rstn = 1;

//     en = 1;

//     sel = 3'b000; din = 8'b00000001;
//     #10 sel = 3'b001; din = 8'b00000010;
//     #10 sel = 3'b010; din = 8'b00000100;
//     #10 sel = 3'b011; din = 8'b00001000;
//     #10 sel = 3'b100; din = 8'b00010000;
//     #10 sel = 3'b101; din = 8'b00100000;
//     #10 sel = 3'b110; din = 8'b01000000;
//     #10 sel = 3'b111; din = 8'b10000000;
//     #10 sel = 3'b111; din = 8'b00000000;
//     #10 sel = 3'b110; din = 8'b10000000;
//     #10 sel = 3'b100; din = 8'b00010000;

//     #100 $finish;
// end

// mux8x1 uut (
//     .clk(clk),
//     .rstn(rstn),
//     .en(en),
//     .din(din),
//     .sel(sel),
//     .dout(dout)
// );

// initial begin
//     $dumpfile("8x1mux.vcd");
//     $dumpvars(0, mux8x1_tb);
// end

// endmodule


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