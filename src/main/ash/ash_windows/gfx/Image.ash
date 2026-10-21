package ash_windows.gfx;

import ash_windows.sys.Raw;

/// A picture: w x h pixels of 0xAARRGGBB in raw memory. Drawn scaled (bilinear), alpha-blended.
public final class Image {
    private final int pixels;
    private final int w;
    private final int h;

    public Image(int pixels, int w, int h) {
        this.pixels = pixels;
        this.w = w;
        this.h = h;
    }

    public int width() { return w; }
    public int height() { return h; }
    public int pixel(int x, int y) { return Raw.peek(pixels + (y * w + x) * 4, 4); }
    public void free() { Raw.free(pixels); }

    /// Draws the whole picture into the rectangle (dx, dy, dw, dh) of the canvas, within its clip.
    public void draw(Canvas c, int dx, int dy, int dw, int dh) {
        if (dw <= 0 || dh <= 0 || !c.visible(dx, dy, dw, dh)) return;
        for (int j = Math.max(0, c.clip().top() - dy); j < Math.min(dh, c.clip().bottom() - dy); j++) {
            int sy = j * (h - 1) * 256 / Math.max(1, dh - 1);
            int y0 = sy >> 8;
            int y1 = Math.min(h - 1, y0 + 1);
            for (int i = Math.max(0, c.clip().left() - dx); i < Math.min(dw, c.clip().right() - dx); i++) {
                int sx = i * (w - 1) * 256 / Math.max(1, dw - 1);
                int x0 = sx >> 8;
                int x1 = Math.min(w - 1, x0 + 1);
                int top = mix(pixel(x0, y0), pixel(x1, y0), sx & 255);
                int px = mix(top, mix(pixel(x0, y1), pixel(x1, y1), sx & 255), sy & 255);
                c.blend(dx + i, dy + j, px & 0xffffff, px >> 24 & 255);
            }
        }
    }

    // Each of the four channels of a moved towards b by t/256.
    private static int mix(int a, int b, int t) {
        int out = 0;
        for (int shift = 0; shift < 32; shift = shift + 8) out = out | (((a >> shift & 255) * (256 - t) + (b >> shift & 255) * t) >> 8) << shift;
        return out;
    }
}
