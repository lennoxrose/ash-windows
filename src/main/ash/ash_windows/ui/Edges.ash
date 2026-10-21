package ash_windows.ui;

import ash_windows.x11.Cursors;

/// The edges of a window, for resizing a window that has no frame of its own.
public final class Edges {
    public static final int LEFT = 1;
    public static final int RIGHT = 2;
    public static final int TOP = 4;
    public static final int BOTTOM = 8;

    private Edges() { }

    /// The edges within `border` pixels of the point (0 when it is in the middle of the window).
    public static int at(int px, int py, int w, int h, int border) {
        return (px < border ? LEFT : 0) | (px >= w - border ? RIGHT : 0) | (py < border ? TOP : 0) | (py >= h - border ? BOTTOM : 0);
    }

    /// The cursor glyph that shows a resize from these edges.
    public static int cursor(int edges) {
        if (edges == (LEFT | TOP)) return Cursors.TOP_LEFT;
        if (edges == (RIGHT | TOP)) return Cursors.TOP_RIGHT;
        if (edges == (LEFT | BOTTOM)) return Cursors.BOTTOM_LEFT;
        if (edges == (RIGHT | BOTTOM)) return Cursors.BOTTOM_RIGHT;
        if (edges == LEFT) return Cursors.LEFT;
        if (edges == RIGHT) return Cursors.RIGHT;
        return edges == TOP ? Cursors.TOP : Cursors.BOTTOM;
    }
}
