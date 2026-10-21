package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;

/// The thumb drawn at the right edge of a scrolling view, and the maths between thumb and offset.
public final class Scrollbar {
    private Scrollbar() { }

    /// Draws the thumb for a view `h` tall showing `content` pixels of which `offset` are scrolled off.
    public static void draw(Canvas c, int x, int y, int w, int h, int content, int offset, bool hot) {
        if (content <= h) return;
        Theme t = Theme.get();
        Shapes.roundRect(c, x + w - 8, y + thumbY(h, content, offset), 5, thumbH(h, content), 2, hot ? t.dim : t.border, 255);
    }

    public static int thumbH(int h, int content) { return Math.max(24, h * h / content); }

    public static int thumbY(int h, int content, int offset) {
        return (h - thumbH(h, content)) * offset / Math.max(1, content - h);
    }

    /// The offset that puts the middle of the thumb at pointer position `py` (relative to the view's top).
    public static int offsetAt(int py, int h, int content) {
        int travel = Math.max(1, h - thumbH(h, content));
        return Math.min(content - h, Math.max(0, (py - thumbH(h, content) / 2) * (content - h) / travel));
    }
}
