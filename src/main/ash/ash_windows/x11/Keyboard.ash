package ash_windows.x11;

import ash_windows.sys.Raw;

/// The server's keycode -> keysym table, for turning a key event into the key that was meant.
public final class Keyboard {
    private int table = 0;
    private int perKey = 0;                      // keysyms per keycode
    private int minKey = 8;

    public Keyboard(int minKey) { this.minKey = minKey; }

    /// GetKeyboardMapping for every keycode. Call before the window is mapped, so no event is in the way.
    public void load(Wire w) {
        w.send(101, 0, 2);
        w.p8(4, minKey);
        w.p8(5, 255 - minKey);
        w.p16(6, 0);
        w.flush(8);
        if (!w.readFull(32) || w.u8(0) != 1) return;
        int bytes = w.u32(4) * 4;
        int per = w.u8(1);
        int data = Raw.alloc(bytes + 4);
        if (!w.readInto(data, bytes)) { Raw.free(data); return; }
        table = data;
        perKey = per;
    }

    /// The keysym for a keycode under the modifier state (shift, caps lock for letters). Printable Latin-1
    /// keysyms equal their character code; 0 when unknown.
    public int keysym(int keycode, int state) {
        if (table == 0 || keycode < minKey) return 0;
        int row = (keycode - minKey) * perKey;
        int plain = Raw.peek(table + row * 4, 4);
        int shifted = perKey > 1 ? Raw.peek(table + (row + 1) * 4, 4) : 0;
        if (shifted == 0) shifted = plain;
        bool letter = plain >= 97 && plain <= 122;
        bool upper = ((state & Keys.SHIFT) != 0) != (letter && (state & 2) != 0);
        return upper ? shifted : plain;
    }

    public void free() {
        if (table != 0) Raw.free(table);
        table = 0;
    }
}
