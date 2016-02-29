module sha1_guesser #(
	parameter NONCE_SIZE = 16,
	parameter NONCE_START = 503
) (
	input wire clk,
	input wire start,
	input wire [159:0] context_in,
	input wire [511:0] block_in,
	input wire [159:0] target,
	input wire [159:0] target_mask,
	output wire hash,
	output wire match,
	output reg done,
	output reg [NONCE_SIZE-1:0] nonce,
	output wire [511:0] block_out,
	output wire [159:0] context_out);

wire [511:0] block = {block_in[511:NONCE_START+1], nonce, block_in[NONCE_START-NONCE_SIZE:0]};
assign block_out = block;
assign hash = sha1_done;
assign match = sha1_done & ((context_out & target_mask) == target);

wire sha1_almost_start = start | sha1_done;
reg sha1_start;
wire sha1_done;

wire [NONCE_SIZE-1:0] zero_nonce = {1'b0};

sha1_block sha1_block (.clk(clk), .start(sha1_start), .context_in(context_in), .block(block), .done(sha1_done), .context_out(context_out));

always @(posedge clk)
begin
    if (start) begin
	    nonce <= 0;
		done <= 0;
	end else if (sha1_done) begin
		if (~nonce == zero_nonce) begin
		    done <= 1;
		end else begin
	        nonce <= nonce + 1;
		end
	end
	if (sha1_almost_start) begin
	    sha1_start <= 1;
	end else begin
	    sha1_start <= 0;
	end
end

endmodule
