package ash_windows.gfx;

import ash.util.ArrayList;
import ash.util.List;

/// The points of a glyph's contours in font units (y up): collected from a TrueType glyph, composites included.
public final class Outline {
    public final List<Integer> xs = new ArrayList<>();
    public final List<Integer> ys = new ArrayList<>();
    public final List<Boolean> on = new ArrayList<>();      // on-curve point, or a quadratic control point
    public final List<Integer> ends = new ArrayList<>();    // index of the last point of each contour

    private final TrueType f;

    public Outline(TrueType font, int gid) {
        this.f = font;
        add(gid, 0, 0, 0);
    }

    private void add(int gid, int dx, int dy, int depth) {
        int g = f.glyph(gid);
        if (g < 0 || depth > 4) return;
        int nc = f.i16(g);
        if (nc >= 0) simple(g, nc, dx, dy);
        else composite(g, dx, dy, depth);
    }

    private void composite(int g, int dx, int dy, int depth) {
        int p = g + 10;
        int flags = 0x20;
        while ((flags & 0x20) != 0) {            // MORE_COMPONENTS
            flags = f.u16(p);
            int gid = f.u16(p + 2);
            int a = (flags & 1) != 0 ? f.i16(p + 4) : f8(f.u8(p + 4));
            int b = (flags & 1) != 0 ? f.i16(p + 6) : f8(f.u8(p + 5));
            p = p + ((flags & 1) != 0 ? 8 : 6);
            if ((flags & 8) != 0) p = p + 2;     // scale / 2x2 transforms are not applied
            else if ((flags & 0x40) != 0) p = p + 4;
            else if ((flags & 0x80) != 0) p = p + 8;
            if ((flags & 2) != 0) add(gid, dx + a, dy + b, depth + 1);
            else add(gid, dx, dy, depth + 1);
        }
    }

    private void simple(int g, int nc, int dx, int dy) {
        int endPts = g + 10;
        int n = f.u16(endPts + 2 * (nc - 1)) + 1;
        int p = endPts + 2 * nc + 2 + f.u16(endPts + 2 * nc);
        int[] flags = new int[n];
        for (int i = 0; i < n;) {
            int fl = f.u8(p);
            p = p + 1;
            flags[i] = fl;
            i = i + 1;
            int repeat = (fl & 8) != 0 ? f.u8(p) : 0;
            if ((fl & 8) != 0) p = p + 1;
            for (int k = 0; k < repeat && i < n; k++) { flags[i] = fl; i = i + 1; }
        }
        int base = xs.size();
        int v = 0;
        for (int i = 0; i < n; i++) {
            int fl = flags[i];
            if ((fl & 2) != 0) { v = v + ((fl & 16) != 0 ? f.u8(p) : -f.u8(p)); p = p + 1; }
            else if ((fl & 16) == 0) { v = v + f.i16(p); p = p + 2; }
            xs.add(v + dx);
            on.add((fl & 1) != 0);
        }
        v = 0;
        for (int i = 0; i < n; i++) {
            int fl = flags[i];
            if ((fl & 4) != 0) { v = v + ((fl & 32) != 0 ? f.u8(p) : -f.u8(p)); p = p + 1; }
            else if ((fl & 32) == 0) { v = v + f.i16(p); p = p + 2; }
            ys.add(v + dy);
        }
        for (int c = 0; c < nc; c++) ends.add(base + f.u16(endPts + 2 * c));
    }

    private static int f8(int b) { return b > 127 ? b - 256 : b; }
}
