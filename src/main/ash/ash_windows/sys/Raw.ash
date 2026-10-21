package ash_windows.sys;

/// The raw_* builtins under readable names, plus the few helpers built on them. Addresses are plain ints;
/// nothing is checked, a wrong address crashes the process. Linux x86-64.
public final class Raw {
    private Raw() { }

    @Lower("raw_alloc($1)") public static native int alloc(int n);
    @Lower("raw_free($1)") public static native void free(int p);
    @Lower("raw_peek($1, $2)") public static native int peek(int p, int width);
    @Lower("raw_poke($1, $2, $3)") public static native void poke(int p, int width, int v);
    @Lower("raw_fill($1, $2, $3)") public static native void fill(int p, int rgb, int count);
    @Lower("raw_copy($1, $2, $3)") public static native void copy(int dst, int src, int bytes);
    @Lower("raw_syscall($1, $2, $3, $4, $5, 0, 0)") public static native int sys(int n, int a, int b, int c, int d);
    @Lower("ord(substring($1, $2, $2 + 1))") public static native int charAt(String s, int i);
    @Lower("chr($1)") public static native String chr(int c);
    @Lower("str($1)") public static native String text(int n);

    /// Milliseconds on the monotonic clock. `scratch` is 16 writable bytes.
    public static int nowMs(int scratch) {
        sys(228, 1, scratch, 0, 0);                // clock_gettime(CLOCK_MONOTONIC)
        return peek(scratch, 8) * 1000 + peek(scratch + 8, 8) / 1000000;
    }

    /// Reads a whole file into freshly allocated memory; its size is left in the first 8 bytes of `sizeOut`.
    /// Files that report no size (/proc) are read up to 64 KB. Returns 0 when the file cannot be read.
    /// The caller frees the result.
    public static int readFile(String path, int sizeOut) {
        int p = alloc(path.length() + 1);
        for (int i = 0; i < path.length(); i++) poke(p + i, 1, charAt(path, i));
        int f = sys(2, p, 0, 0, 0);                // open(path, O_RDONLY)
        free(p);
        if (f < 0) return 0;
        int size = sys(8, f, 0, 2, 0);             // lseek(f, 0, SEEK_END)
        sys(8, f, 0, 0, 0);
        int cap = size > 0 ? size : 65536;
        int data = alloc(cap);
        int total = 0;
        while (total < cap) {
            int n = sys(0, f, data + total, cap - total, 0);
            if (n <= 0) break;
            total = total + n;
        }
        sys(3, f, 0, 0, 0);
        if (size > 0 && total != size) { free(data); return 0; }
        poke(sizeOut, 8, total);
        return data;
    }
}
