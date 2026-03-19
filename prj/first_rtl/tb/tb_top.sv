module tb_top();
    int idx=0;
    initial begin
        repeat(10)begin
            $display("Hello, VCS! i=%2d", idx)
        end
    end
endmodule
