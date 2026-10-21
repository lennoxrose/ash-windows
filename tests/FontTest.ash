package tests;

import ash_windows.gfx.Font;
import ash_windows.gfx.Fonts;

/// Kerning and measuring with the system UI font (needs a TrueType font, not an X server).
public class FontTest {
    public static void main(String[] args) {
        Font? f = Fonts.regular(48);
        if (f == null) { System.out.println("no TrueType font found"); return; }
        int failures = 0;
        if (f.measure("AV") >= f.measure("A") + f.measure("V")) { failures++; System.out.println("FAIL AV is not kerned"); }
        if (f.measure("To") >= f.measure("T") + f.measure("o")) { failures++; System.out.println("FAIL To is not kerned"); }
        if (f.measure("é") != f.measure("e")) { failures++; System.out.println("FAIL a two-byte character measures as two"); }
        System.out.println(failures == 0 ? "ok" : failures + " failure(s)");
    }
}
