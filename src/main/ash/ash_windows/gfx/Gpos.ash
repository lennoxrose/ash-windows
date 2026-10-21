package ash_windows.gfx;

import ash.util.ArrayList;
import ash.util.HashMap;
import ash.util.List;

/// Kerning from the font's GPOS table: the pair-adjustment lookups of the 'kern' feature (formats 1 and 2).
public final class Gpos {
    private final TrueType f;
    private final List<Integer> subs = new ArrayList<>();       // file offsets of PairPos subtables
    private final HashMap<Integer, Integer> cache = new HashMap<>();

    public Gpos(TrueType font) {
        int base = font.table(0x47504f53);
        int features = base + font.u16(base + 6);
        int lookups = base + font.u16(base + 8);
        int count = base == 0 ? 0 : font.u16(features);
        for (int i = 0; i < count; i++) {
            if (font.u32(features + 2 + i * 6) != 0x6b65726e) continue;           // 'kern'
            int ft = features + font.u16(features + 2 + i * 6 + 4);
            for (int j = 0; j < font.u16(ft + 2); j++) addLookup(font, lookups + font.u16(lookups + 2 + font.u16(ft + 4 + j * 2) * 2));
        }
        this.f = font;
    }

    /// The horizontal adjustment, in font units, between two glyphs (usually negative: closer together).
    public int pair(int left, int right) {
        int key = left * 65536 + right;
        Integer? hit = cache.get(key);
        if (hit != null) return hit;
        int found = 0;
        for (int i = 0; i < subs.size() && found == 0; i++) found = adjust(subs.get(i), left, right);
        cache.put(key, found);
        return found;
    }

    private void addLookup(TrueType font, int table) {
        int type = font.u16(table);
        for (int k = 0; k < font.u16(table + 4); k++) {
            int sub = table + font.u16(table + 6 + k * 2);
            int t = type;
            if (t == 9) { t = font.u16(sub + 2); sub = sub + font.u32(sub + 4); }      // extension: the real subtable follows
            if (t == 2) subs.add(sub);
        }
    }

    private int adjust(int sub, int left, int right) {
        int cov = OtLayout.coverage(f, sub + f.u16(sub + 2), left);
        int vf1 = f.u16(sub + 4);
        if (cov < 0 || (vf1 & 4) == 0) return 0;
        int slot = (vf1 & 1) + (vf1 >> 1 & 1);                // XAdvance comes after XPlacement and YPlacement
        int rec = (bits(vf1) + bits(f.u16(sub + 6))) * 2;
        if (f.u16(sub) == 1) {
            int set = sub + f.u16(sub + 10 + cov * 2);
            for (int i = 0; i < f.u16(set); i++)
                if (f.u16(set + 2 + i * (rec + 2)) == right) return f.i16(set + 4 + i * (rec + 2) + slot * 2);
            return 0;
        }
        int c1 = OtLayout.classOf(f, sub + f.u16(sub + 8), left);
        int c2 = OtLayout.classOf(f, sub + f.u16(sub + 10), right);
        return f.i16(sub + 16 + (c1 * f.u16(sub + 14) + c2) * rec + slot * 2);
    }

    private static int bits(int v) {
        int n = 0;
        for (int i = 0; i < 8; i++) n = n + (v >> i & 1);
        return n;
    }
}
