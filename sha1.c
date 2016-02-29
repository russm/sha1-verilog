#include <stdint.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	uint32_t h0 = 0x67452301;
	uint32_t h1 = 0xEFCDAB89;
	uint32_t h2 = 0x98BADCFE;
	uint32_t h3 = 0x10325476;
	uint32_t h4 = 0xC3D2E1F0;
	uint32_t w[80];
	
	// set up the message
	w[0] = 0x80000000;
	for (int i = 1; i <= 15; i++) {
		w[i] = 0;
	}
	
	// extend the message
    for (int i = 16; i <= 79; i++) {
		uint32_t temp = (w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16]);
        w[i] = temp << 1 | temp >> 31;
	}
	
	uint32_t a = h0;
	uint32_t b = h1;
	uint32_t c = h2;
	uint32_t d = h3;
	uint32_t e = h4;
	
	for (int r = 0; r <= 79; r++) {
		uint32_t f, k;
		if (r <= 19) {
			f = (b & c) | ((~b) & d);
            k = 0x5A827999;
		} else if (r <= 39) {
            f = b ^ c ^ d;
            k = 0x6ED9EBA1;
		} else if (r <= 59) {
            f = (b & c) | (b & d) | (c & d);
            k = 0x8F1BBCDC;
		} else {
            f = b ^ c ^ d;
            k = 0xCA62C1D6;
		}
		printf("a:%08x b:%08x c:%08x d:%08x e:%08x f:%08x k:%08x w:%08x\n", a, b, c, d, e, f, k, w[r]);
		uint32_t temp = (a << 5 | a >> 27) + f + e + k + w[r];
        e = d;
        d = c;
        c = b << 30 | b >> 2;
        b = a;
        a = temp;
	}
	
	printf("a:%08x b:%08x c:%08x d:%08x e:%08x\n", a, b, c, d, e);
	
	h0 += a;
	h1 += b;
	h2 += c;
	h3 += d;
	h4 += e;
	
	printf("h0:%08x h1:%08x h2:%08x h3:%08x h4:%08x\n", h0, h1, h2, h3, h4);
	if (h0 == 0xda39a3ee && h1 == 0x5e6b4b0d && h2 == 0x3255bfef && h3 == 0x95601890 && h4 == 0xafd80709) {
		printf("GOOD!\n");
	}
	
	return 0;
}