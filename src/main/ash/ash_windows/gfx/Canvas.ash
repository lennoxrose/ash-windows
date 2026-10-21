package ash_windows.gfx;

import ash_windows.sys.Raw;

/// A software framebuffer of 0x00RRGGBB pixels in raw memory, with a clip rectangle that every drawing call
/// respects. Shapes and text are drawn on it; the window uploads it with X11.putImage.
public final class Canvas {
    private final int width;
    private final int height;
    private final int pixels;
    private final Clip clip;

    public Canvas(int width, int height) {
        this.width = width;
        this.height = height;
        this.pixels = Raw.alloc(width * height * 4);
        this.clip = new Clip(width, height);
    }

    public int width() { return width; }
    public int height() { return height; }
    public int pixels() { return pixels; }
    public Clip clip() { return clip; }
    public void free() { Raw.free(pixels); }

    public void setClip(int x, int y, int w, int h) { clip.reset(width, height, x, y, w, h); }
    public bool visible(int x, int y, int w, int h) { return clip.intersects(x, y, w, h); }

    /// Fills a rectangle with an opaque colour.
    public void fill(int rgb, int x, int y, int w, int h) {
        int ax = Math.max(x, clip.left());
        int bx = Math.min(x + w, clip.right());
        for (int j = Math.max(y, clip.top()); j < Math.min(y + h, clip.bottom()); j++) {
            if (bx > ax) Raw.fill(pixels + (j * width + ax) * 4, rgb, bx - ax);
        }
    }

    /// Fills a rectangle with a colour at alpha 0..255.
    public void fillAlpha(int rgb, int x, int y, int w, int h, int alpha) {
        if (alpha >= 255) { fill(rgb, x, y, w, h); return; }
        for (int j = Math.max(y, clip.top()); j < Math.min(y + h, clip.bottom()); j++)
            for (int i = Math.max(x, clip.left()); i < Math.min(x + w, clip.right()); i++) blend(i, j, rgb, alpha);
    }

    /// Mixes one pixel towards a colour; alpha 0..255. Ignores pixels outside the clip.
    public void blend(int x, int y, int rgb, int alpha) {
        if (alpha <= 0 || x < clip.left() || x >= clip.right() || y < clip.top() || y >= clip.bottom()) return;
        int p = pixels + (y * width + x) * 4;
        int d = Raw.peek(p, 4);
        int ia = 255 - alpha;
        int r = ((rgb >> 16 & 255) * alpha + (d >> 16 & 255) * ia + 127) / 255;
        int g = ((rgb >> 8 & 255) * alpha + (d >> 8 & 255) * ia + 127) / 255;
        int b = ((rgb & 255) * alpha + (d & 255) * ia + 127) / 255;
        Raw.poke(p, 4, r << 16 | g << 8 | b);
    }

    /// Paints a colour through an 8-bit coverage mask of mw x mh bytes with its top-left at (x, y): glyphs.
    public void mask(int mask, int mw, int mh, int x, int y, int rgb) {
        if (!visible(x, y, mw, mh)) return;
        for (int j = Math.max(0, clip.top() - y); j < Math.min(mh, clip.bottom() - y); j++)
            for (int i = 0; i < mw; i++) {
                int a = Raw.peek(mask + j * mw + i, 1);
                if (a > 0) blend(x + i, y + j, rgb, a);
            }
    }
}
