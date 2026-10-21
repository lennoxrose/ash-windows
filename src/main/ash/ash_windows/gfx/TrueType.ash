package ash_windows.gfx;

import ash_windows.sys.Raw;

/// A TrueType (glyf outline) font file held in memory: its tables, character map and metrics.
public final class TrueType {
    private int data = 0;
    private int unitsPerEm = 1000;
    private int locaFormat = 0;
    private int numHM = 0;                       // number of full entries in hmtx
    private int ascent = 0;
    private int descent = 0;
    private int lineGap = 0;
    private int hmtx = 0;
    private int loca = 0;
    private int glyf = 0;
    private int cmap = 0;                        // offset of a format 4 character map subtable

    private TrueType() { }
    public int u8(int o) { return Raw.peek(data + o, 1); }
    public int u16(int o) { return u8(o) * 256 + u8(o + 1); }
    public int i16(int o) { int v = u16(o); return v >= 32768 ? v - 65536 : v; }
    public int u32(int o) { return u16(o) * 65536 + u16(o + 2); }
    public int unitsPerEm() { return unitsPerEm; }
    public int ascent() { return ascent; }
    public int descent() { return descent; }
    public int lineGap() { return lineGap; }
    /// Loads a .ttf; null when it is missing or has no glyf outlines (CFF/.otf, collections).
    public static TrueType? load(String path) {
        int sizeOut = Raw.alloc(8);
        int data = Raw.readFile(path, sizeOut);
        int size = Raw.peek(sizeOut, 8);
        Raw.free(sizeOut);
        if (data == 0) return null;
        TrueType f = new TrueType();
        f.data = data;
        if (size < 12 || !f.parse()) { Raw.free(data); return null; }
        return f;
    }

    /// The glyph for a Unicode code point (0, the missing-glyph box, when the font has none).
    public int glyphIndex(int cp) {
        if (cp > 65535 || cmap == 0) return 0;
        int segs = u16(cmap + 6) / 2;
        int end = cmap + 14;
        for (int i = 0; i < segs; i++) {
            if (u16(end + i * 2) < cp) continue;
            int start = u16(end + 2 + segs * 2 + i * 2);
            if (start > cp) return 0;
            int delta = u16(end + 2 + segs * 4 + i * 2);
            int rangeAt = end + 2 + segs * 6 + i * 2;
            int range = u16(rangeAt);
            if (range == 0) return (cp + delta) & 65535;
            int g = u16(rangeAt + range + (cp - start) * 2);
            return g == 0 ? 0 : (g + delta) & 65535;
        }
        return 0;
    }

    /// Horizontal advance in font units.
    public int advance(int gid) { return u16(hmtx + 4 * Math.min(gid, numHM - 1)); }

    /// File offset of the glyph's outline data, -1 for a glyph with no outline (a space).
    public int glyph(int gid) {
        int a = locaFormat == 0 ? u16(loca + gid * 2) * 2 : u32(loca + gid * 4);
        int b = locaFormat == 0 ? u16(loca + gid * 2 + 2) * 2 : u32(loca + gid * 4 + 4);
        return a == b ? -1 : glyf + a;
    }

    /// File offset of the table with this tag (4 ASCII bytes as an int, e.g. 0x68656164 for head), 0 if absent.
    public int table(int tag) {
        for (int i = 0; i < u16(4); i++) if (u32(12 + i * 16) == tag) return u32(12 + i * 16 + 8);
        return 0;
    }

    private bool parse() {
        int head = table(0x68656164);
        int hhea = table(0x68686561);
        hmtx = table(0x686d7478);
        loca = table(0x6c6f6361);
        glyf = table(0x676c7966);
        cmap = table(0x636d6170);
        if (head == 0 || hhea == 0 || hmtx == 0 || loca == 0 || glyf == 0 || cmap == 0) return false;
        unitsPerEm = u16(head + 18);
        locaFormat = i16(head + 50);
        ascent = i16(hhea + 4);
        descent = i16(hhea + 6);
        lineGap = i16(hhea + 8);
        numHM = u16(hhea + 34);
        int tables = cmap;
        cmap = 0;
        for (int i = 0; i < u16(tables + 2); i++) {      // the Unicode BMP subtable, format 4
            int at = tables + u32(tables + 4 + i * 8 + 4);
            int platform = u16(tables + 4 + i * 8);
            if (cmap == 0 && (platform == 0 || platform == 3) && u16(at) == 4) cmap = at;
        }
        return cmap != 0 && unitsPerEm > 0;
    }
}
