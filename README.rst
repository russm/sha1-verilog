====================
Verilog SHA1 guesser
====================

sha1.v
======

A simple single-purpose SHA1 hasher in Verilog.

This is *not* a stream hasher. It takes a prior context (h0-h4) and a
512-bit data block, and returns the updated context 80 cycles later.
Padding is *not* handled, you will need to ensure the stream tail is
correctly padded.

sha1_guesser.v
==============

Brute force SHA1. Give it a context, a block (presumably a padded final
block), a target hash/mask, and tell it where to put the counter/nonce.

When ``match`` is high, read the block/nonce/hash from ``nonce``/
``block_out``/``context_out`` respectively. When ``done`` is high, the
nonce space has been exhausted.
