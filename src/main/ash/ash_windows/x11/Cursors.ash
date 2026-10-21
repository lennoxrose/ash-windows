package ash_windows.x11;

import ash.util.HashMap;

/// Mouse cursors from the X "cursor" font. A window has no cursor of its own unless it asks for one (under
/// Xwayland the pointer vanishes over it), so every window sets at least the arrow.
public final class Cursors {
    public static final int ARROW = 68;
    public static final int HAND = 60;
    public static final int TEXT = 152;
    public static final int MOVE = 52;
    public static final int LEFT = 70;
    public static final int RIGHT = 96;
    public static final int TOP = 138;
    public static final int BOTTOM = 16;
    public static final int TOP_LEFT = 134;
    public static final int TOP_RIGHT = 136;
    public static final int BOTTOM_LEFT = 12;
    public static final int BOTTOM_RIGHT = 14;

    private final Wire wire;
    private final HashMap<Integer, Integer> made = new HashMap<>();
    private int font = 0;
    private int next = 0;
    private int step = 1;
    private int window = 0;
    private int current = -1;

    public Cursors(Wire wire) { this.wire = wire; }

    /// Opens the font and sets the arrow; `firstId` and `step` give the resource ids this may use.
    public void init(int window, int firstId, int step) {
        this.window = window;
        this.step = step;
        font = firstId;
        next = firstId + step;
        wire.send(45, 0, 5);                      // OpenFont "cursor"
        wire.p32(4, font);
        wire.p16(8, 6);
        wire.p16(10, 0);
        String name = "cursor";
        for (int i = 0; i < 8; i++) wire.p8(12 + i, i < 6 ? (int) name.charAt(i) : 0);
        wire.flush(20);
        set(ARROW);
    }

    /// Shows the glyph's cursor over the window (one of the constants above, or any glyph of the font).
    public void set(int glyph) {
        if (glyph == current || font == 0) return;
        current = glyph;
        Integer? known = made.get(glyph);
        int id = known == null ? 0 : known;
        if (known == null) {
            id = next;
            next = next + step;
            wire.send(94, 0, 8);                  // CreateGlyphCursor: black on white, the glyph and its mask
            wire.p32(4, id);
            wire.p32(8, font);
            wire.p32(12, font);
            wire.p16(16, glyph);
            wire.p16(18, glyph + 1);
            for (int i = 20; i < 26; i = i + 2) wire.p16(i, 0);
            for (int i = 26; i < 32; i = i + 2) wire.p16(i, 65535);
            wire.flush(32);
            made.put(glyph, id);
        }
        wire.send(2, 0, 4);                       // ChangeWindowAttributes: the cursor
        wire.p32(4, window);
        wire.p32(8, 16384);
        wire.p32(12, id);
        wire.flush(16);
    }
}
