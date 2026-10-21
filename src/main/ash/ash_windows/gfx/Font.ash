package ash_windows.gfx;

import ash.util.HashMap;

/// A TrueType font at one pixel size. Glyphs are rasterised on first use and cached.
public final class Font {
    private final TrueType tt;
    private final int size;
    private final double scale;
    private final Gpos kerning;
    private final HashMap<Integer, Glyph> cache = new HashMap<>();

    private Font(TrueType tt, int size) {
        this.size = size;
        this.scale = (double) size / tt.unitsPerEm();
        this.tt = tt;
        this.kerning = new Gpos(this.tt);
    }

    /// Loads a .ttf at the given pixel size; null when it cannot be read.
    public static Font? load(String path, int size) {
        TrueType? f = TrueType.load(path);
        return f == null ? null : new Font(f, size);
    }

    /// The same font at another pixel size (shares the loaded file).
    public Font sized(int px) { return new Font(tt, px); }

    public int size() { return size; }
    public int ascent() { return (int) Math.floor(tt.ascent() * scale + 0.5); }
    public int lineHeight() { return (int) Math.floor((tt.ascent() - tt.descent() + tt.lineGap()) * scale + 0.5); }

    /// Width in pixels of the text on one line.
    public int measure(String s) {
        double pen = 0;
        int prev = -1;
        for (int i = 0; i < s.length(); i = i + Utf8.length(s, i)) {
            Glyph g = glyph(Utf8.decode(s, i));
            pen = pen + g.advance() + (prev < 0 ? 0 : kerning.pair(prev, g.gid()) * scale);
            prev = g.gid();
        }
        return (int) Math.floor(pen + 0.5);
    }

    /// Draws the text with the top of its line at y.
    public void draw(Canvas c, String s, int x, int y, int rgb) {
        double pen = x;
        int prev = -1;
        for (int i = 0; i < s.length(); i = i + Utf8.length(s, i)) {
            Glyph g = glyph(Utf8.decode(s, i));
            if (prev >= 0) pen = pen + kerning.pair(prev, g.gid()) * scale;
            c.mask(g.mask(), g.w(), g.h(), (int) Math.floor(pen + 0.5) + g.left(), y + ascent() + g.top(), rgb);
            pen = pen + g.advance();
            prev = g.gid();
        }
    }

    private Glyph glyph(int cp) {
        Glyph? hit = cache.get(cp);
        if (hit != null) return hit;
        int gid = tt.glyphIndex(cp);
        Glyph made = Tracer.render(new Outline(tt, gid), scale, tt.advance(gid) * scale, gid);
        cache.put(cp, made);
        return made;
    }
}
