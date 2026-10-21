package ash_windows.gfx;

import ash_windows.sys.Raw;

/// Strings are bytes; this reads and writes them as UTF-8.
public final class Utf8 {
    private Utf8() { }

    /// Bytes taken by the character that starts at index i.
    public static int length(String s, int i) {
        int b = (int) s.charAt(i);
        int n = b < 0xC0 ? 1 : (b < 0xE0 ? 2 : (b < 0xF0 ? 3 : 4));
        return Math.min(n, s.length() - i);
    }

    /// The code point of the character that starts at index i.
    public static int decode(String s, int i) {
        int n = length(s, i);
        int b = (int) s.charAt(i);
        if (n == 1) return b;
        int cp = b & (0xFF >> (n + 1));
        for (int k = 1; k < n; k++) cp = cp << 6 | ((int) s.charAt(i + k) & 63);
        return cp;
    }

    /// Start of the character that ends just before index i (i itself at 0).
    public static int previous(String s, int i) {
        int p = Math.max(0, i - 1);
        while (p > 0 && ((int) s.charAt(p) & 0xC0) == 0x80) p--;
        return p;
    }

    /// The characters of code point cp, as a String (Latin-1 and the BMP).
    public static String encode(int cp) {
        if (cp < 0x80) return Raw.chr(cp);
        if (cp < 0x800) return Raw.chr(0xC0 | cp >> 6) + Raw.chr(0x80 | cp & 63);
        return Raw.chr(0xE0 | cp >> 12) + Raw.chr(0x80 | cp >> 6 & 63) + Raw.chr(0x80 | cp & 63);
    }
}
