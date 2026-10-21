package ash_windows.gfx;

/// Turns an Outline into a Glyph: scales it, walks its contours (quadratic curves with implied on-curve
/// points) and rasterises the result.
public final class Tracer {
    private Tracer() { }

    public static Glyph render(Outline o, double scale, double advance, int gid) {
        int n = o.xs.size();
        if (n == 0) return new Glyph(0, 0, 0, 0, 0, advance, gid);
        double minX = o.xs.get(0);
        double maxX = minX;
        double minY = o.ys.get(0);
        double maxY = minY;
        for (int i = 1; i < n; i++) {
            minX = Math.min(minX, o.xs.get(i));
            maxX = Math.max(maxX, o.xs.get(i));
            minY = Math.min(minY, o.ys.get(i));
            maxY = Math.max(maxY, o.ys.get(i));
        }
        int ox = (int) Math.floor(minX * scale);
        int oy = (int) Math.floor(-maxY * scale);
        int w = (int) Math.floor(maxX * scale) + 2 - ox;
        int h = (int) Math.floor(-minY * scale) + 2 - oy;
        Raster r = new Raster(w, h);
        int start = 0;
        for (int c = 0; c < o.ends.size(); c++) {
            contour(o, r, start, o.ends.get(c), scale, ox, oy);
            start = o.ends.get(c) + 1;
        }
        return new Glyph(r.mask(), w, h, ox, oy, advance, gid);
    }

    private static double px(Outline o, int i, double sc, int ox) { return o.xs.get(i) * sc - ox; }

    private static double py(Outline o, int i, double sc, int oy) { return -o.ys.get(i) * sc - oy; }

    private static void contour(Outline o, Raster r, int s, int e, double sc, int ox, int oy) {
        if (e - s < 1) return;
        int first = s;
        int last = e;
        double sx = (px(o, s, sc, ox) + px(o, e, sc, ox)) / 2;      // all off-curve: start between two of them
        double sy = (py(o, s, sc, oy) + py(o, e, sc, oy)) / 2;
        if (o.on.get(s)) { sx = px(o, s, sc, ox); sy = py(o, s, sc, oy); first = s + 1; }
        else if (o.on.get(e)) { sx = px(o, e, sc, ox); sy = py(o, e, sc, oy); last = e - 1; }
        double cx = sx;
        double cy = sy;
        double qx = 0;
        double qy = 0;
        bool ctrl = false;
        for (int i = first; i <= last; i++) {
            double x = px(o, i, sc, ox);
            double y = py(o, i, sc, oy);
            if (o.on.get(i)) {
                if (ctrl) r.quad(cx, cy, qx, qy, x, y); else r.line(cx, cy, x, y);
                cx = x;
                cy = y;
                ctrl = false;
            } else if (ctrl) {
                double mx = (qx + x) / 2;
                double my = (qy + y) / 2;
                r.quad(cx, cy, qx, qy, mx, my);
                cx = mx;
                cy = my;
                qx = x;
                qy = y;
            } else {
                qx = x;
                qy = y;
                ctrl = true;
            }
        }
        if (ctrl) r.quad(cx, cy, qx, qy, sx, sy); else r.line(cx, cy, sx, sy);
    }
}
