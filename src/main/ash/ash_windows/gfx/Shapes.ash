package ash_windows.gfx;

/// Anti-aliased shapes on a Canvas. Edges are coverage-blended against what is already there.
public final class Shapes {
    private Shapes() { }

    /// A rounded rectangle; radius r is clamped to half the shorter side. alpha 0..255.
    public static void roundRect(Canvas c, int x, int y, int w, int h, int r, int rgb, int alpha) {
        if (w <= 0 || h <= 0 || alpha <= 0 || !c.visible(x, y, w, h)) return;
        r = Math.min(r, Math.min(w, h) / 2);
        for (int j = Math.max(0, c.clip().top() - y); j < Math.min(h, c.clip().bottom() - y); j++) {
            double dy = j < r ? r - j - 0.5 : (j >= h - r ? j - (h - r) + 0.5 : -1.0);
            if (dy < 0) { c.fillAlpha(rgb, x, y + j, w, 1, alpha); continue; }
            // Pixels with the centre inside radius r - 0.5 are fully covered, outside r + 0.5 not at all: only the
            // few in between need the distance maths, the rest of the row is one fill.
            double outer = Math.sqrt(Math.max(0.0, (r + 0.5) * (r + 0.5) - dy * dy));
            double inner = Math.sqrt(Math.max(0.0, (r - 0.5) * (r - 0.5) - dy * dy));
            int full = Math.min(r, (int) Math.floor(r - 0.5 - inner) + 1);
            for (int i = Math.max(0, (int) Math.floor(r - 0.5 - outer) + 1); i < full; i++) {
                double dx = r - i - 0.5;
                int a = (int) (coverage(Math.sqrt(dx * dx + dy * dy) - r) * alpha);
                c.blend(x + i, y + j, rgb, a);
                c.blend(x + w - 1 - i, y + j, rgb, a);
            }
            c.fillAlpha(rgb, x + full, y + j, w - 2 * full, 1, alpha);
        }
    }

    /// A rounded rectangle with a 1px border drawn inside its edge.
    public static void roundRectBorder(Canvas c, int x, int y, int w, int h, int r, int fill, int border) {
        roundRect(c, x, y, w, h, r, border, 255);
        roundRect(c, x + 1, y + 1, w - 2, h - 2, Math.max(0, r - 1), fill, 255);
    }

    public static void circle(Canvas c, int cx, int cy, int radius, int rgb) {
        roundRect(c, cx - radius, cy - radius, radius * 2, radius * 2, radius, rgb, 255);
    }

    /// A line of the given thickness with round ends, between pixel positions.
    public static void line(Canvas c, int ax, int ay, int bx, int by, double thickness, int rgb) {
        double dx = bx - ax;
        double dy = by - ay;
        double len2 = Math.max(dx * dx + dy * dy, 0.0001);
        int pad = (int) thickness + 1;
        for (int y = Math.min(ay, by) - pad; y <= Math.max(ay, by) + pad; y++)
            for (int x = Math.min(ax, bx) - pad; x <= Math.max(ax, bx) + pad; x++) {
                double t = Math.min(1.0, Math.max(0.0, ((x + 0.5 - ax) * dx + (y + 0.5 - ay) * dy) / len2));
                double ex = ax + t * dx - x - 0.5;
                double ey = ay + t * dy - y - 0.5;
                c.blend(x, y, rgb, (int) (coverage(Math.sqrt(ex * ex + ey * ey) - thickness / 2) * 255));
            }
    }

    /// A soft drop shadow under a rounded rectangle: `blur` stacked layers, darkest at the box itself. Only the
    /// four strips around the box are drawn (the box is painted over it anyway).
    public static void shadow(Canvas c, int x, int y, int w, int h, int r, int blur, int alpha) {
        int[] sx = {x - blur, x - blur, x - blur, x + w};
        int[] sy = {y - blur, y + h, y, y};
        int[] sw = {w + 2 * blur, w + 2 * blur, blur, blur};
        int[] sh = {blur, blur, h, h};
        for (int k = 0; k < 4; k++) {
            c.clip().push(sx[k], sy[k], sw[k], sh[k]);
            for (int i = blur; i >= 1; i--) roundRect(c, x - i, y - i, w + 2 * i, h + 2 * i, r + i, 0, alpha / blur);
            c.clip().pop();
        }
    }

    /// A vertical gradient from `top` to `bottom`.
    public static void gradient(Canvas c, int x, int y, int w, int h, int top, int bottom) {
        for (int j = 0; j < h; j++) c.fill(Colors.mix(top, bottom, j * 255 / Math.max(1, h - 1)), x, y + j, w, 1);
    }

    // Pixel coverage from the signed distance (pixels) between its centre and the shape's edge.
    private static double coverage(double distance) {
        return Math.min(1.0, Math.max(0.0, 0.5 - distance));
    }
}
