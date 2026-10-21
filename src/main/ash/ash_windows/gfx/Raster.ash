package ash_windows.gfx;

import ash_windows.sys.Raw;

/// Exact-area coverage rasteriser: lines (and flattened curves) add signed area to a buffer, and a running
/// sum along each row turns that into per-pixel coverage.
public final class Raster {
    private final int w;
    private final int h;
    private final double[] acc;

    public Raster(int w, int h) {
        this.w = w;
        this.h = h;
        this.acc = new double[w * h + 4];
    }

    /// A line in bitmap coordinates (y down).
    public void line(double ax, double ay, double bx, double by) {
        if (ay == by) return;
        double dir = ay < by ? 1.0 : -1.0;
        double x0 = ay < by ? ax : bx;
        double y0 = Math.min(ay, by);
        double y1 = Math.max(ay, by);
        double dxdy = (ay < by ? bx - ax : ax - bx) / (y1 - y0);
        double x = x0;
        if (y0 < 0) x = x - y0 * dxdy;
        for (int y = Math.max(0, (int) y0); y < Math.min(h, (int) Math.ceil(y1)); y++) {
            double dy = Math.min(y + 1.0, y1) - Math.max((double) y, y0);
            double xn = x + dxdy * dy;
            cell(y * w, Math.min(x, xn), Math.max(x, xn), dy * dir);
            x = xn;
        }
    }

    /// A quadratic curve from (ax, ay) via control (qx, qy) to (bx, by), as short lines.
    public void quad(double ax, double ay, double qx, double qy, double bx, double by) {
        double dev = Math.abs(ax - 2 * qx + bx) + Math.abs(ay - 2 * qy + by);
        int n = Math.min(12, 2 + (int) Math.sqrt(dev * 5));
        double px = ax;
        double py = ay;
        for (int i = 1; i <= n; i++) {
            double t = (double) i / n;
            double u = 1 - t;
            double x = u * u * ax + 2 * u * t * qx + t * t * bx;
            double y = u * u * ay + 2 * u * t * qy + t * t * by;
            line(px, py, x, y);
            px = x;
            py = y;
        }
    }

    /// The coverage as w * h bytes in newly allocated memory (the caller frees it).
    public int mask() {
        int m = Raw.alloc(w * h);
        double sum = 0;
        for (int i = 0; i < w * h; i++) {
            sum = sum + acc[i];
            Raw.poke(m + i, 1, (int) (Math.min(1.0, Math.abs(sum)) * 255 + 0.5));
        }
        return m;
    }

    // Spreads signed area d of one scanline segment that spans x0..x1 over the pixels it crosses.
    private void cell(int row, double x0, double x1, double d) {
        double x0f = Math.floor(x0);
        int i0 = (int) x0f;
        int i1 = (int) Math.ceil(x1);
        if (i1 <= i0 + 1) {
            double xm = 0.5 * (x0 + x1) - x0f;
            acc[row + i0] = acc[row + i0] + d - d * xm;
            acc[row + i0 + 1] = acc[row + i0 + 1] + d * xm;
            return;
        }
        double s = 1.0 / (x1 - x0);
        double f0 = x0 - x0f;
        double a0 = 0.5 * s * (1 - f0) * (1 - f0);
        double f1 = x1 - i1 + 1;
        double am = 0.5 * s * f1 * f1;
        acc[row + i0] = acc[row + i0] + d * a0;
        if (i1 == i0 + 2) {
            acc[row + i0 + 1] = acc[row + i0 + 1] + d * (1 - a0 - am);
        } else {
            double a1 = s * (1.5 - f0);
            acc[row + i0 + 1] = acc[row + i0 + 1] + d * (a1 - a0);
            for (int i = i0 + 2; i < i1 - 1; i++) acc[row + i] = acc[row + i] + d * s;
            double a2 = a1 + (i1 - i0 - 3) * s;
            acc[row + i1 - 1] = acc[row + i1 - 1] + d * (1 - a2 - am);
        }
        acc[row + i1] = acc[row + i1] + d * am;
    }
}
