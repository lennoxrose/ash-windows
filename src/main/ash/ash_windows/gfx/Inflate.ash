package ash_windows.gfx;

import ash_windows.sys.Raw;

/// DEFLATE decompression (RFC 1951) into a buffer of known size.
public final class Inflate {
    private static final int[] LEN_BASE = {3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258};
    private static final int[] LEN_EXTRA = {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0};
    private static final int[] DIST_BASE = {1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577};
    private static final int[] DIST_EXTRA = {0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13};
    private static final int[] ORDER = {16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15};

    private Inflate() { }

    /// Decompresses the raw DEFLATE stream in `in` into `out` (cap bytes). Returns the output size, -1 on bad data.
    public static int run(Bits in, int out, int cap) {
        int n = 0;
        int last = 0;
        while (last == 0 && n >= 0 && !in.pastEnd()) {
            last = in.take(1);
            int type = in.take(2);
            if (type == 0) n = stored(in, out, cap, n);
            else if (type == 1) n = fixed(in, out, cap, n);
            else if (type == 2) n = dynamic(in, out, cap, n);
            else n = -1;
        }
        return in.pastEnd() ? -1 : n;
    }

    private static int stored(Bits in, int out, int cap, int n) {
        in.alignByte();
        int len = in.take(16);
        in.take(16);
        if (n + len > cap || !in.copyTo(out + n, len)) return -1;
        return n + len;
    }

    private static int fixed(Bits in, int out, int cap, int n) {
        int[] lengths = new int[320];
        for (int i = 0; i < 288; i++) lengths[i] = i < 144 ? 8 : (i < 256 ? 9 : (i < 280 ? 7 : 8));
        for (int i = 0; i < 30; i++) lengths[288 + i] = 5;
        return codes(in, new Huffman(lengths, 0, 288), new Huffman(lengths, 288, 30), out, cap, n);
    }

    private static int dynamic(Bits in, int out, int cap, int n) {
        int nlen = in.take(5) + 257;
        int ndist = in.take(5) + 1;
        int[] lengths = new int[320];
        int ncode = in.take(4) + 4;
        for (int i = 0; i < ncode; i++) lengths[ORDER[i]] = in.take(3);
        Huffman lencode = new Huffman(lengths, 0, 19);
        int[] all = new int[320];
        for (int i = 0; i < nlen + ndist;) {
            int sym = lencode.decode(in);
            if (sym < 0 || in.pastEnd()) return -1;
            if (sym < 16) { all[i] = sym; i++; continue; }
            int prev = sym == 16 && i > 0 ? all[i - 1] : 0;
            int rep = sym == 16 ? 3 + in.take(2) : (sym == 17 ? 3 + in.take(3) : 11 + in.take(7));
            if (i + rep > nlen + ndist) return -1;
            for (int k = 0; k < rep; k++) { all[i] = prev; i++; }
        }
        return codes(in, new Huffman(all, 0, nlen), new Huffman(all, nlen, ndist), out, cap, n);
    }

    private static int codes(Bits in, Huffman lit, Huffman dist, int out, int cap, int n) {
        while (!in.pastEnd()) {
            int sym = lit.decode(in);
            if (sym < 0) return -1;
            if (sym == 256) return n;
            if (sym < 256) {
                if (n >= cap) return -1;
                Raw.poke(out + n, 1, sym);
                n++;
                continue;
            }
            sym = sym - 257;
            if (sym >= 29) return -1;
            int len = LEN_BASE[sym] + in.take(LEN_EXTRA[sym]);
            int ds = dist.decode(in);
            if (ds < 0 || ds >= 30) return -1;
            int d = DIST_BASE[ds] + in.take(DIST_EXTRA[ds]);
            if (d > n || n + len > cap) return -1;
            for (int k = 0; k < len; k++) { Raw.poke(out + n, 1, Raw.peek(out + n - d, 1)); n++; }
        }
        return -1;
    }
}
