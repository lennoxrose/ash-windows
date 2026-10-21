package ash_windows.gfx;

import ash_windows.sys.Raw;

/// Reads uncompressed 24- and 32-bit BMP files (what most tools export).
public final class Bmp {
    private Bmp() { }

    /// The picture in the file, null when it is missing or in another BMP flavour.
    public static Image? load(String path) {
        int so = Raw.alloc(8);
        int d = Raw.readFile(path, so);
        int size = Raw.peek(so, 8);
        Raw.free(so);
        if (d == 0) return null;
        int w = Raw.peek(d + 18, 4);
        int h = Raw.peek(d + 22, 4);
        bool topDown = h > 1000000000;                // a negative height (rows stored top to bottom), read unsigned
        if (topDown) { long wrapped = h; h = (int) (4294967296L - wrapped); }
        int bits = Raw.peek(d + 28, 2);
        int stride = (w * bits + 31) / 32 * 4;
        bool ok = size > 54 && Raw.peek(d, 2) == 0x4d42 && Raw.peek(d + 30, 4) == 0 && (bits == 24 || bits == 32) && w > 0 && h > 0;
        if (!ok || Raw.peek(d + 10, 4) + stride * h > size) { Raw.free(d); return null; }
        int px = Raw.alloc(w * h * 4);
        for (int y = 0; y < h; y++) {
            int row = d + Raw.peek(d + 10, 4) + (topDown ? y : h - 1 - y) * stride;
            for (int x = 0; x < w; x++) {
                int a = bits == 32 ? Raw.peek(row + x * 4 + 3, 1) : 255;
                Raw.poke(px + (y * w + x) * 4, 4, a << 24 | Raw.peek(row + x * (bits / 8) + 2, 1) << 16 | Raw.peek(row + x * (bits / 8) + 1, 1) << 8 | Raw.peek(row + x * (bits / 8), 1));
            }
        }
        Raw.free(d);
        return new Image(px, w, h);
    }
}
