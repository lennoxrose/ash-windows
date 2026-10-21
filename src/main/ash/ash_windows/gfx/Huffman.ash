package ash_windows.gfx;

/// A canonical Huffman code, built from code lengths and decoded bit by bit.
public final class Huffman {
    private final int[] count = new int[16];
    private final int[] symbol;

    /// A code over `n` symbols whose lengths (0 = unused) are lengths[off .. off + n).
    public Huffman(int[] lengths, int off, int n) {
        symbol = new int[n + 1];
        int[] next = new int[17];
        for (int i = 0; i < n; i++) count[lengths[off + i]]++;
        count[0] = 0;
        for (int len = 1; len < 16; len++) next[len + 1] = next[len] + count[len];
        for (int i = 0; i < n; i++) {
            int len = lengths[off + i];
            if (len == 0) continue;
            symbol[next[len]] = i;
            next[len]++;
        }
    }

    /// The next symbol, -1 when the bits match no code.
    public int decode(Bits in) {
        int code = 0;
        int first = 0;
        int index = 0;
        for (int len = 1; len < 16; len++) {
            code = code | in.take(1);
            int c = count[len];
            if (code - c < first) return symbol[index + code - first];
            index = index + c;
            first = (first + c) << 1;
            code = code << 1;
        }
        return -1;
    }
}
