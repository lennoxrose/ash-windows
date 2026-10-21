package ash_windows.x11;

/// Requests that create, map, draw into and destroy a window.
public final class Windows {
    private Windows() { }

    public static void create(Wire w, int window, int root, int width, int height, int background) {
        w.send(1, 0, 10);                         // CreateWindow, depth copied from the parent
        w.p32(4, window);
        w.p32(8, root);
        w.p16(12, 0);
        w.p16(14, 0);
        w.p16(16, width);
        w.p16(18, height);
        w.p16(20, 0);
        w.p16(22, 1);                             // InputOutput
        w.p32(24, 0);                             // visual: copy the parent's
        w.p32(28, 2 | 2048);                      // BackPixel | EventMask
        w.p32(32, background);
        // KeyPress KeyRelease ButtonPress ButtonRelease LeaveWindow PointerMotion Exposure StructureNotify
        w.p32(36, 1 | 2 | 4 | 8 | 32 | 64 | 32768 | 131072);
        w.flush(40);
    }

    public static void createGc(Wire w, int gc, int window, int foreground) {
        w.send(55, 0, 5);                         // CreateGC with a foreground
        w.p32(4, gc);
        w.p32(8, window);
        w.p32(12, 4);
        w.p32(16, foreground);
        w.flush(20);
    }

    public static void map(Wire w, int window) {
        w.send(8, 0, 2);                          // MapWindow
        w.p32(4, window);
        w.flush(8);
    }

    public static void destroy(Wire w, int window) {
        w.send(4, 0, 2);                          // DestroyWindow
        w.p32(4, window);
        w.flush(8);
    }

    /// Uploads `rows` rows from row `y` of a `width`-wide 0x00RRGGBB image at `pixels`.
    public static void putImage(Wire w, int window, int gc, int depth, int width, int pixels, int y, int rows) {
        int rowBytes = width * 4;
        int perRequest = (262140 - 24) / rowBytes;       // the largest request without BIG-REQUESTS
        while (rows > 0 && perRequest > 0 && w.isOpen()) {
            int n = rows < perRequest ? rows : perRequest;
            w.send(72, 2, 6 + n * width);         // PutImage, ZPixmap
            w.p32(4, window);
            w.p32(8, gc);
            w.p16(12, width);
            w.p16(14, n);
            w.p16(16, 0);
            w.p16(18, y);
            w.p8(20, 0);
            w.p8(21, depth);
            w.flush(24);
            w.writeAll(pixels + y * rowBytes, n * rowBytes);
            y = y + n;
            rows = rows - n;
        }
    }
}
