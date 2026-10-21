package ash_windows.gfx;

/// The two small structures OpenType layout tables share: Coverage (which glyphs a subtable handles) and
/// ClassDef (which class a glyph is in).
public final class OtLayout {
    private OtLayout() { }

    /// The index of the glyph in the Coverage table at file offset `cov`, -1 when it is not covered.
    public static int coverage(TrueType f, int cov, int gid) {
        int n = f.u16(cov + 2);
        if (f.u16(cov) == 1) {                    // a sorted list of glyphs
            int lo = 0;
            int hi = n - 1;
            while (lo <= hi) {
                int mid = (lo + hi) / 2;
                int g = f.u16(cov + 4 + mid * 2);
                if (g == gid) return mid;
                if (g < gid) lo = mid + 1; else hi = mid - 1;
            }
            return -1;
        }
        for (int i = 0; i < n; i++) {             // ranges: start, end, index of the first
            int at = cov + 4 + i * 6;
            if (gid >= f.u16(at) && gid <= f.u16(at + 2)) return f.u16(at + 4) + gid - f.u16(at);
        }
        return -1;
    }

    /// The class of the glyph in the ClassDef table at `cd` (0 when it is not listed).
    public static int classOf(TrueType f, int cd, int gid) {
        if (f.u16(cd) == 1) {
            int start = f.u16(cd + 2);
            return gid >= start && gid < start + f.u16(cd + 4) ? f.u16(cd + 6 + (gid - start) * 2) : 0;
        }
        for (int i = 0; i < f.u16(cd + 2); i++) {
            int at = cd + 4 + i * 6;
            if (gid >= f.u16(at) && gid <= f.u16(at + 2)) return f.u16(at + 4);
        }
        return 0;
    }
}
