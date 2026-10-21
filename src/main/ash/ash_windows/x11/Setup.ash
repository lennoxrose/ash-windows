package ash_windows.x11;

import ash_windows.sys.Raw;

/// The connection handshake: authenticates and keeps what the server tells about itself (resource-id base and
/// step between ids, root window and its depth, lowest keycode, screen size).
public record Setup(int base, int step, int root, int depth, int minKey, int screenW, int screenH) {

    /// Connects to display :n and logs in. Returns null when no X server answers or it refuses us.
    public static Setup? connect(Wire w, int display) {
        if (!w.connect("/tmp/.X11-unix/X" + Raw.text(display))) return null;
        String name = "MIT-MAGIC-COOKIE-1";
        int cookie = Raw.alloc(64);
        int cookieLen = Auth.cookie(cookie);
        int nameLen = cookieLen > 0 ? name.length() : 0;
        w.p8(0, 108);                             // 'l': little-endian
        w.p16(2, 11);
        w.p16(4, 0);
        w.p16(6, nameLen);
        w.p16(8, cookieLen);
        w.p16(10, 0);
        for (int i = 0; i < nameLen; i++) w.p8(12 + i, Raw.charAt(name, i));
        int at = 12 + (nameLen + 3) / 4 * 4;
        for (int i = 0; i < cookieLen; i++) w.p8(at + i, Raw.peek(cookie + i, 1));
        w.flush(at + (cookieLen + 3) / 4 * 4);
        Raw.free(cookie);

        if (!w.readFull(8) || w.u8(0) != 1) return null;     // 1 = Success
        int extra = w.u16(6) * 4;
        if (extra > Wire.SIZE - 8 || !w.readFullAt(8, extra)) return null;
        int screen = 40 + (w.u16(24) + 3) / 4 * 4 + w.u8(29) * 8;
        int mask = w.u32(16);
        return new Setup(w.u32(12), mask & -mask, w.u32(screen), w.u8(screen + 38), w.u8(34), w.u16(screen + 20), w.u16(screen + 22));
    }
}
