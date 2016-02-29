module testbed;

integer ticks;

reg clk, start;
wire hash, match, done;
wire [159:0] context_initial = {32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0};
wire [15:0] nonce;
wire [511:0] block_out;
wire [159:0] context_out;

// string "abc"
wire [511:0] block = {"abc", 8'h80, 416'd0, 64'd24}; // length in *bits*
wire [159:0] target = { 160'hFF };
wire [159:0] target_mask = { 160'hFF };


sha1_guesser #(.NONCE_SIZE(16)) sha1_guesser (
	.clk(clk),
	.start(start),
	.context_in(context_initial),
	.block_in(block),
	.target(target),
	.target_mask(target_mask),
	.hash(hash),
	.match(match),
	.done(done),
	.nonce(nonce),
	.block_out(block_out),
	.context_out(context_out));

initial
begin
  ticks = 0;
  $display("starting");
  // $display("block:%h", block);
  tick;
  start = 1'b1;
  tick;
  tick;
  tick;
  start = 1'b0;
  while (!done) begin
    tick;
  end
  tick;
  $display("done");
  $finish;
end

task tick;
begin
  #1;
  clk = 1;
  #1;
  clk = 0;
  ticks = ticks + 1;
  dumpstate;
end
endtask

task dumpstate;
begin
  if (match) begin
    $display("%d %b %b %b %h %h", ticks, start, match, done, nonce, context_out);
  end
//  $display("%b %b %h", start, done, context_out);
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
