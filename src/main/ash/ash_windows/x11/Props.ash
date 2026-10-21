package ash_windows.x11;

import ash_windows.sys.Raw;

/// Window properties the window manager reads: title, class, and the close protocol.
public final class Props {
    private Props() { }

    public static void setTitle(Wire w, int window, String title) {
        int n = title.length();
        int words = 6 + (n + 3) / 4;
        w.send(18, 0, words);                     // ChangeProperty (replace)
        w.p32(4, window);
        w.p32(8, 39);                             // WM_NAME
        w.p32(12, 31);                            // STRING
        w.p8(16, 8);
        w.p32(20, n);
        for (int i = 0; i < words * 4 - 24; i++) w.p8(24 + i, i < n ? Raw.charAt(title, i) : 0);
        w.flush(words * 4);
    }

    /// Sets WM_CLASS and WM_PROTOCOLS = [WM_DELETE_WINDOW] (so the window manager asks us to close instead of
    /// cutting the connection). Returns the WM_DELETE_WINDOW atom.
    public static int setIdentity(Wire w, int window) {
        String cls = "ash";
        w.send(18, 0, 8);                         // WM_CLASS = "ash\0ash\0" (instance, class)
        w.p32(4, window);
        w.p32(8, 67);
        w.p32(12, 31);
        w.p8(16, 8);
        w.p32(20, 8);
        for (int i = 0; i < 8; i++) w.p8(24 + i, i % 4 < 3 ? Raw.charAt(cls, i % 4) : 0);
        w.flush(32);
        int deleteAtom = intern(w, "WM_DELETE_WINDOW");
        int protocols = intern(w, "WM_PROTOCOLS");   // before the request below: both share the buffer
        w.send(18, 0, 7);
        w.p32(4, window);
        w.p32(8, protocols);
        w.p32(12, 4);                             // ATOM
        w.p8(16, 32);
        w.p32(20, 1);
        w.p32(24, deleteAtom);
        w.flush(28);
        return deleteAtom;
    }

    /// InternAtom has a reply, so call it only while no other event can be in flight (before the window is mapped).
    public static int intern(Wire w, String name) {
        int n = name.length();
        int words = 2 + (n + 3) / 4;
        w.send(16, 0, words);
        w.p16(4, n);
        w.p16(6, 0);
        for (int i = 0; i < words * 4 - 8; i++) w.p8(8 + i, i < n ? Raw.charAt(name, i) : 0);
        w.flush(words * 4);
        if (!w.readFull(32) || w.u8(0) != 1) return 0;
        return w.u32(8);
    }
}
