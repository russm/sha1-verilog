// wire [159:0] context_initial = {32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0};

// process a SHA1 block
module sha1_block (
    input wire clk,
    input wire start,
    input wire [159:0] context_in,
    input wire [511:0] block,
    output wire done,
    output wire [159:0] context_out);

reg [6:0] round;
reg [159:0] context;

wire [159:0] context_next;

assign done = round == 80;

wire [31:0] h0 = context_in[159:128];
wire [31:0] h1 = context_in[127:96];
wire [31:0] h2 = context_in[95:64];
wire [31:0] h3 = context_in[63:32];
wire [31:0] h4 = context_in[31:0];

wire [31:0] a = context[159:128];
wire [31:0] b = context[127:96];
wire [31:0] c = context[95:64];
wire [31:0] d = context[63:32];
wire [31:0] e = context[31:0];

wire [31:0] w;
wire [31:0] k = (round <= 19) ? 32'h5A827999 :
                (round <= 39) ? 32'h6ED9EBA1 :
                (round <= 59) ? 32'h8F1BBCDC :
                                32'hCA62C1D6;

reg [31:0] f;
wire [31:0] f_zero = ((b & c) | (~b & d));
wire [31:0] f_next_20;
wire [31:0] f_next_40;
wire [31:0] f_next_60;
wire [31:0] f_next_80;

assign context_out = {h0+a, h1+b, h2+c, h3+d, h4+e};

w_machine w_machine (.clk(clk), .load(start), .block(block), .w(w));
sha1_round sha1_round (
    .context_in(context),
    .w(w), .k(k), .f(f),
    .context_out(context_next),
    .f_next_20(f_next_20),
    .f_next_40(f_next_40),
    .f_next_60(f_next_60),
    .f_next_80(f_next_80));

always @(posedge clk)
begin
    if (start) begin
        round <= 0;
        context <= context_in;
        f <= f_zero;
    end else begin
        round <= (round + 1) % 128;
        context <= context_next;
        if (round+1 <= 19) // set up *next* round's f
            f <= f_next_20;
        else if (round+1 <= 39)
            f <= f_next_40;
        else if (round+1 <= 59)
            f <= f_next_60;
        else
            f <= f_next_80;
    end
end

endmodule


// generate w values
module w_machine (
    input wire clk,
    input wire load,
    input wire [511:0] block,
    output wire [31:0] w);

reg [511:0] state;
assign w = state[511:480];
wire [31:0] w_im3 = state[95:64];
wire [31:0] w_im8 = state[255:224];
wire [31:0] w_im14 = state[447:416];
wire [31:0] w_im16 = state[511:480];
wire [31:0] w_temp = w_im3 ^ w_im8 ^ w_im14 ^ w_im16;
wire [31:0] w_next = {w_temp[30:0], w_temp[31]};

always @(posedge clk)
begin
    if (load)
        state <= block;
    else begin
        state <= {state[479:0], w_next};
    end
end

endmodule


// combinatorial part of a plain SHA1 round
module sha1_round (
    input wire [159:0] context_in,
    input wire [31:0] w,
    input wire [31:0] k,
    input wire [31:0] f,
    output wire [159:0] context_out,
    output wire [31:0] f_next_20,
    output wire [31:0] f_next_40,
    output wire [31:0] f_next_60,
    output wire [31:0] f_next_80);

wire [31:0] a_in = context_in[159:128];
wire [31:0] b_in = context_in[127:96];
wire [31:0] c_in = context_in[95:64];
wire [31:0] d_in = context_in[63:32];
wire [31:0] e_in = context_in[31:0];

wire [31:0] a_out = {a_in[26:0], a_in[31:27]} + f + e_in + k + w;
wire [31:0] b_out = a_in;
wire [31:0] c_out = {b_in[1:0],b_in[31:2]};
wire [31:0] d_out = c_in;
wire [31:0] e_out = d_in;

assign f_next_20 = ((b_out & c_out) | (~b_out & d_out));
assign f_next_40 = (b_out ^ c_out ^ d_out);
assign f_next_60 = ((b_out & c_out) | (b_out & d_out) | (c_out & d_out));
assign f_next_80 = (b_out ^ c_out ^ d_out);

assign context_out = {a_out, b_out, c_out, d_out, e_out};

endmodule
