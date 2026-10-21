package ash_windows.gfx;

import ash_windows.sys.Raw;

/// Reads bits, least significant first, from a block of raw memory (the order DEFLATE uses).
public final class Bits {
    private final int data;
    private final int size;
    private int pos = 0;
    private int buf = 0;
    private int cnt = 0;

    public Bits(int data, int size) {
        this.data = data;
        this.size = size;
    }

    /// The next n bits (n <= 16) as a number; zeros past the end.
    public int take(int n) {
        while (cnt < n) {
            buf = buf | ((pos < size ? Raw.peek(data + pos, 1) : 0) << cnt);
            pos++;
            cnt = cnt + 8;
        }
        int v = buf & ((1 << n) - 1);
        buf = buf >> n;
        cnt = cnt - n;
        return v;
    }

    public bool pastEnd() { return pos > size + 4; }

    /// Drops the rest of the current byte.
    public void alignByte() {
        buf = 0;
        cnt = 0;
    }

    /// Copies the next n whole bytes (after alignByte) to `dst`; false when the input is too short.
    public bool copyTo(int dst, int n) {
        if (pos + n > size) return false;
        Raw.copy(dst, data + pos, n);
        pos = pos + n;
        return true;
    }
}
