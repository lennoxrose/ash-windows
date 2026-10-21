package ash_windows.x11;

/// A ClientMessage to the root window, which is how a client asks the window manager for something
/// (the EWMH way: minimise, maximize, ...).
public final class WmMessage {
    private WmMessage() { }

    public static void send(Wire w, int root, int window, int type, int a, int b, int c) {
        w.send(25, 0, 11);                        // SendEvent with SubstructureRedirect | SubstructureNotify
        w.p32(4, root);
        w.p32(8, 0x180000);
        for (int i = 12; i < 44; i++) w.p8(i, 0);
        w.p8(12, 33);
        w.p8(13, 32);
        w.p32(16, window);
        w.p32(20, type);
        w.p32(24, a);
        w.p32(28, b);
        w.p32(32, c);
        w.flush(44);
    }
}
