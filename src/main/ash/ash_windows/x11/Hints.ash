package ash_windows.x11;

/// Hints for the window manager about what the window is and may do.
public final class Hints {
    private Hints() { }

    /// WM_NORMAL_HINTS (initial and minimum size; no maximum, so the window stays resizable and maximizable)
    /// and WM_HINTS (it takes keyboard input).
    public static void set(Wire w, int window, int width, int height, int minW, int minH) {
        w.send(18, 0, 24);
        w.p32(4, window);
        w.p32(8, 40);                             // WM_NORMAL_HINTS
        w.p32(12, 41);                            // WM_SIZE_HINTS
        w.p8(16, 32);
        w.p32(20, 18);
        for (int i = 24; i < 96; i = i + 4) w.p32(i, 0);
        w.p32(24, 8 | 16);                        // PSize | PMinSize
        w.p32(36, width);
        w.p32(40, height);
        w.p32(44, minW);
        w.p32(48, minH);
        w.flush(96);
        w.send(18, 0, 15);
        w.p32(4, window);
        w.p32(8, 35);                             // WM_HINTS
        w.p32(12, 35);
        w.p8(16, 32);
        w.p32(20, 9);
        for (int i = 24; i < 60; i = i + 4) w.p32(i, 0);
        w.p32(24, 1);                             // InputHint
        w.p32(28, 1);
        w.flush(60);
    }
}
