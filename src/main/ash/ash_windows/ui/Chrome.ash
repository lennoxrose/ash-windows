package ash_windows.ui;

import ash_windows.x11.EventData;
import ash_windows.x11.X11;

/// The operating-system window as widgets see it: close, minimise, maximize, move and resize by dragging,
/// the clipboard, the cursor. Reach it from a Control with chrome(), or from the App with root().chrome().
public final class Chrome {
    public static final int MIN_W = 160;
    public static final int MIN_H = 100;
    private final X11 win;
    private bool closing = false;
    private int mode = 0;                        // 0 idle, 1 moving, 2 resizing
    private int edges = 0;                       // which edges a resize pulls: Edges.LEFT | RIGHT | TOP | BOTTOM
    private final int[] grab = new int[6];       // pointer and window at the start of a drag: x, y, then x, y, w, h

    public Chrome(X11 win) { this.win = win; }

    public void close() { closing = true; }
    public bool closing() { return closing; }
    public void minimize() { win.frame().iconify(); }
    public void toggleMaximize() { win.frame().toggleMaximize(win.event().originX(), win.event().originY(), win.width(), win.height()); }
    public void setTitle(String title) { win.setTitle(title); }
    public void setCursor(int glyph) { win.frame().cursor(glyph); }
    public int nowMs() { return win.nowMs(); }
    public void copy(String text) { win.copy(text); }
    public String? paste() { return win.paste(); }

    /// Starts moving the window with the pointer; call it from a press, the App does the rest until release.
    public void beginMove() { begin(1, 0); }

    /// Starts resizing from the given edges (Edges.LEFT | Edges.TOP ...).
    public void beginResize(int edgeMask) { begin(2, edgeMask); }

    public bool dragging() { return mode != 0; }
    public void endDrag() { mode = 0; }

    /// Follows the pointer during a drag (called for every motion event).
    public void drag() {
        if (mode == 0) return;
        EventData e = win.event();
        int dx = e.rootX() - grab[0];
        int dy = e.rootY() - grab[1];
        int nx = grab[2] + (mode == 1 ? dx : 0);
        int ny = grab[3] + (mode == 1 ? dy : 0);
        int nw = grab[4];
        int nh = grab[5];
        if ((edges & Edges.LEFT) != 0) { nw = Math.max(MIN_W, grab[4] - dx); nx = grab[2] + grab[4] - nw; }
        if ((edges & Edges.RIGHT) != 0) nw = Math.max(MIN_W, grab[4] + dx);
        if ((edges & Edges.TOP) != 0) { nh = Math.max(MIN_H, grab[5] - dy); ny = grab[3] + grab[5] - nh; }
        if ((edges & Edges.BOTTOM) != 0) nh = Math.max(MIN_H, grab[5] + dy);
        win.frame().moveResize(nx, ny, nw, nh);
    }

    private void begin(int kind, int edgeMask) {
        EventData e = win.event();
        mode = kind;
        edges = edgeMask;
        grab[0] = e.rootX();
        grab[1] = e.rootY();
        grab[2] = e.originX();
        grab[3] = e.originY();
        grab[4] = win.width();
        grab[5] = win.height();
    }
}
