package ash_windows.gfx;

import ash_windows.sys.Raw;

/// Undoes PNG's per-row prediction filters in place. Each row is a filter byte followed by w * bpp bytes.
public final class PngFilter {
    private PngFilter() { }

    public static bool run(int data, int stride, int rows, int bpp) {
        for (int y = 0; y < rows; y++) {
            int row = data + y * (stride + 1);
            int type = Raw.peek(row, 1);
            if (type > 4) return false;
            for (int i = 0; i < stride; i++) {
                int at = row + 1 + i;
                int a = i >= bpp ? Raw.peek(at - bpp, 1) : 0;                       // left
                int b = y > 0 ? Raw.peek(at - stride - 1, 1) : 0;                   // above
                int c = y > 0 && i >= bpp ? Raw.peek(at - stride - 1 - bpp, 1) : 0; // above left
                int guess = type == 1 ? a : (type == 2 ? b : (type == 3 ? (a + b) / 2 : (type == 4 ? paeth(a, b, c) : 0)));
                Raw.poke(at, 1, (Raw.peek(at, 1) + guess) & 255);
            }
        }
        return true;
    }

    private static int paeth(int a, int b, int c) {
        int p = a + b - c;
        int pa = Math.abs(p - a);
        int pb = Math.abs(p - b);
        int pc = Math.abs(p - c);
        return pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
    }
}
