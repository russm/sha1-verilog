module testbed;

reg clk;
reg start;
wire [159:0] context_initial = {32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0};
wire done;
wire [159:0] context_out;

// zero-length data
//wire [511:0] block = {8'h80, 504'h0};

// string "abc"
//wire [511:0] block = {"abc", 8'h80, 416'd0, 64'd24}; // length in *bits*

// 55-character string (largest 1-block hash)
wire [511:0] block = {"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012", 8'h80, 64'd440}; // length in *bits*


sha1_block sha1_block (.clk(clk), .start(start), .context_in(context_initial), .block(block), .done(done), .context_out(context_out));

initial begin
  $display("starting");
  $display("block:%h", block);
  tick;
  start = 1'b1;
  tick;
  tick;
  tick;
  start = 1'b0;
  repeat (81) begin
    tick;
  end
  $display("done");
  $finish;
end

task tick;
begin
  #1;
  clk = 1;
  #1;
  clk = 0;
  dumpstate;
end
endtask

task dumpstate;
begin
  $display("%b %b %h", start, done, context_out);
//  $display("a:%h b:%h c:%h d:%h e:%h f:%h k:%h w:%h",
//    sha1_block.a,
//    sha1_block.b,
//    sha1_block.c,
//    sha1_block.d,
//    sha1_block.e,
//    sha1_block.f,
//    sha1_block.k,
//    sha1_block.w);
end
endtask

endmodule
