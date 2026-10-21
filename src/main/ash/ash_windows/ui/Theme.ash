package ash_windows.ui;

import ash_windows.gfx.Font;
import ash_windows.gfx.Fonts;

/// Colours, fonts and shape of the whole UI. `Theme.create(true)` is dark, `Theme.create(false)` light.
public final class Theme {
    public final Font text;
    public final Font bold;
    public final Font title;
    public final int bg;
    public final int surface;
    public final int surfaceHi;
    public final int border;
    public final int fg;
    public final int dim;
    public final int accent;
    public final int accentHi;
    public final int accentLo;
    public final int onAccent = 0xffffff;
    public final int danger;
    public final int radius = 8;
    private static Theme? current = null;

    private Theme(bool dark, Font text, Font bold, Font title) {
        this.bg = dark ? 0x16171d : 0xf1f2f6;
        this.surface = dark ? 0x1f2128 : 0xffffff;
        this.surfaceHi = dark ? 0x2b2e39 : 0xe9ebf2;
        this.border = dark ? 0x353948 : 0xd3d7e2;
        this.fg = dark ? 0xe9ebf1 : 0x1c1f2e;
        this.dim = dark ? 0x9399ac : 0x676d82;
        this.accent = dark ? 0x6c8cff : 0x4766f5;
        this.accentHi = dark ? 0x849fff : 0x6580ff;
        this.accentLo = dark ? 0x5472f0 : 0x3553d6;
        this.danger = dark ? 0xff6b7a : 0xdb3a4d;
        this.text = text;
        this.bold = bold;
        this.title = title;
    }

    /// The theme every widget draws with. Set it once, before the first window opens.
    public static void set(Theme theme) { current = theme; }

    public static Theme get() {
        Theme? c = current;
        if (c == null) throw new RuntimeException("no Theme: call Theme.set(Theme.create(true)) first");
        return c;
    }

    /// The theme with the system's UI font; null when no usable font is installed.
    public static Theme? create(bool dark) {
        Font? regular = Fonts.regular(14);
        Font? heavy = Fonts.bold(14);
        if (regular == null || heavy == null) return null;
        Font big = heavy.sized(22);
        return new Theme(dark, regular, heavy, big);
    }
}
