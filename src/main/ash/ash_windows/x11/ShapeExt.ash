package ash_windows.x11;

/// The X Shape extension: gives a window a bounding outline made of rectangles (one per run of pixels).
public final class ShapeExt {
    private static final int CHUNK = 6000;       // rectangles per request, so one fits the wire buffer

    private ShapeExt() { }

    /// Cuts the window to the shape. The first request replaces the old outline, the rest add to it.
    public static void apply(Wire w, int op, int window, WindowShape shape, int width, int height) {
        int n = 0;
        int sent = 0;
        for (int y = 0; y < height; y++) {
            int x = 0;
            while (x < width) {
                if (!shape.contains(x, y, width, height)) { x++; continue; }
                int start = x;
                while (x < width && shape.contains(x, y, width, height)) x++;
                w.p16(16 + n * 8, start);
                w.p16(18 + n * 8, y);
                w.p16(20 + n * 8, x - start);
                w.p16(22 + n * 8, 1);
                n++;
                if (n == CHUNK) { send(w, op, window, n, sent == 0); sent++; n = 0; }
            }
        }
        if (n > 0) send(w, op, window, n, sent == 0);
    }

    /// Gives the window its plain rectangle back.
    public static void reset(Wire w, int op, int window) {
        w.send(op, 2, 5);                         // ShapeMask with no source: the default shape
        w.p8(4, 0);
        w.p8(5, 0);
        w.p16(6, 0);
        w.p32(8, window);
        w.p16(12, 0);
        w.p16(14, 0);
        w.p32(16, 0);
        w.flush(20);
    }

    // ShapeRectangles (Bounding, Set or Union) with the n rectangles already in the buffer from offset 16.
    private static void send(Wire w, int op, int window, int n, bool replace) {
        w.send(op, 1, 4 + 2 * n);
        w.p8(4, 0);
        w.p8(5, replace ? 0 : 1);
        w.p8(6, 0);
        w.p8(7, 0);
        w.p32(8, window);
        w.p16(12, 0);
        w.p16(14, 0);
        w.flush(16 + n * 8);
    }
}
