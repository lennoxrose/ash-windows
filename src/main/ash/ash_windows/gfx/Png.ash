package ash_windows.gfx;

import ash_windows.sys.Raw;

/// Reads PNG files: 8-bit grey, grey+alpha, RGB, RGBA and palette images, not interlaced.
public final class Png {
    private Png() { }

    private static int be32(int p) { return Raw.peek(p, 1) << 24 | Raw.peek(p + 1, 1) << 16 | Raw.peek(p + 2, 1) << 8 | Raw.peek(p + 3, 1); }

    /// The picture in the file, null when it is missing, damaged or in a flavour not supported.
    public static Image? load(String path) {
        int so = Raw.alloc(8);
        int d = Raw.readFile(path, so);
        int size = Raw.peek(so, 8);
        Raw.free(so);
        if (d == 0) return null;
        int w = 0;
        int h = 0;
        int type = -1;
        int plte = 0;
        int idatSize = 0;
        int idat = Raw.alloc(size);
        bool ok = size > 33 && be32(d) == 0x89504e47 && Raw.peek(d + 24, 1) == 8 && Raw.peek(d + 28, 1) == 0;
        for (int at = 8; ok && at + 12 <= size;) {
            int len = be32(d + at);
            int tag = be32(d + at + 4);
            int body = d + at + 8;
            if (len < 0 || at + 12 + len > size) { ok = false; break; }
            if (tag == 0x49484452) { w = be32(body); h = be32(body + 4); type = Raw.peek(body + 9, 1); }
            if (tag == 0x504c5445) plte = body;
            if (tag == 0x49444154) { Raw.copy(idat + idatSize, body, len); idatSize = idatSize + len; }
            if (tag == 0x49454e44) break;
            at = at + 12 + len;
        }
        int bpp = type == 0 ? 1 : (type == 2 ? 3 : (type == 3 ? 1 : (type == 4 ? 2 : 4)));
        ok = ok && w > 0 && h > 0 && type >= 0 && type != 1 && type <= 6 && idatSize > 6 && (type != 3 || plte != 0);
        Image? img = ok ? decode(idat, idatSize, plte, w, h, type, bpp) : null;
        Raw.free(idat);
        Raw.free(d);
        return img;
    }

    private static Image? decode(int idat, int idatSize, int plte, int w, int h, int type, int bpp) {
        int stride = w * bpp;
        int raw = Raw.alloc(h * (stride + 1) + 8);
        int n = Inflate.run(new Bits(idat + 2, idatSize - 2), raw, h * (stride + 1));      // after the 2-byte zlib header
        if (n != h * (stride + 1) || !PngFilter.run(raw, stride, h, bpp)) { Raw.free(raw); return null; }
        int px = Raw.alloc(w * h * 4);
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++) {
                int p = raw + y * (stride + 1) + 1 + x * bpp;
                int v = Raw.peek(p, 1);
                int rgb = type == 2 || type == 6 ? Raw.peek(p, 1) << 16 | Raw.peek(p + 1, 1) << 8 | Raw.peek(p + 2, 1)
                        : (type == 3 ? Raw.peek(plte + v * 3, 1) << 16 | Raw.peek(plte + v * 3 + 1, 1) << 8 | Raw.peek(plte + v * 3 + 2, 1) : v * 65793);
                int a = type == 6 ? Raw.peek(p + 3, 1) : (type == 4 ? Raw.peek(p + 1, 1) : 255);
                Raw.poke(px + (y * w + x) * 4, 4, a << 24 | rgb);
            }
        Raw.free(raw);
        return new Image(px, w, h);
    }
}
