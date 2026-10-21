package ash_windows.x11;

import ash_windows.sys.Raw;

/// Questions to the X server that have a reply. Ask them only while no event can be in flight (before the
/// window is mapped), or the reply may be read as an event and the other way round.
public final class Query {
    private Query() { }

    /// The major opcode of an X extension, 0 when the server does not have it.
    public static int extension(Wire w, String name) {
        int n = name.length();
        int words = 2 + (n + 3) / 4;
        w.send(98, 0, words);                     // QueryExtension
        w.p16(4, n);
        w.p16(6, 0);
        for (int i = 0; i < words * 4 - 8; i++) w.p8(8 + i, i < n ? Raw.charAt(name, i) : 0);
        w.flush(words * 4);
        if (!w.readFull(32) || w.u8(0) != 1 || w.u8(8) == 0) return 0;
        return w.u8(9);
    }

    /// Whether a window has the property (GetProperty has a reply, like intern()).
    public static bool hasProperty(Wire w, int window, int property) {
        w.send(20, 0, 6);
        w.p32(4, window);
        w.p32(8, property);
        w.p32(12, 0);
        w.p32(16, 0);
        w.p32(20, 1);
        w.flush(24);
        if (!w.readFull(32) || w.u8(0) != 1) return false;
        bool has = w.u32(16) > 0;
        int extra = w.u32(4) * 4;
        return (extra == 0 || w.readFullAt(32, extra)) && has;
    }
}
