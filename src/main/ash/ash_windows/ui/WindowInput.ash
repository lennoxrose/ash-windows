package ash_windows.ui;

import ash_windows.x11.Cursors;
import ash_windows.x11.EventData;
import ash_windows.x11.Events;
import ash_windows.x11.X11;

/// Sends the window's pointer and key events where they belong: to the widget tree through the Router, to a
/// window drag in progress, or (for a window with no frame) to a resize from the window's edges.
public final class WindowInput {
    private final X11 win;
    private final Root root;
    private final Router router;
    private final Chrome chrome;
    private int border = 0;                      // width of the resize zone along the edges, 0: none

    public WindowInput(X11 win, Root root, Chrome chrome) {
        this.win = win;
        this.root = root;
        this.chrome = chrome;
        this.router = new Router(this.root);
    }

    public void setResizeBorder(int px) { border = px; }
    public bool wantsTick() { return router.wantsTick(); }
    public void tick(int nowMs) { router.tick(nowMs); }

    public void handle(int code) {
        EventData e = win.event();
        int px = e.x();
        int py = e.y();
        if (code == Events.MOTION && chrome.dragging()) chrome.drag();
        else if (code == Events.MOTION) { router.move(px, py); showCursor(px, py); }
        else if (code == Events.LEAVE) router.leave();
        else if (code == Events.BUTTON_PRESS && e.detail() == 1) press(px, py);
        else if (code == Events.BUTTON_PRESS && e.detail() >= 4 && e.detail() <= 5) router.scroll(px, py, e.detail() * 2 - 9);
        else if (code == Events.BUTTON_RELEASE && e.detail() == 1) { chrome.endDrag(); router.release(px, py); }
        else if (code == Events.KEY_PRESS) router.key(e.detail(), e.state());
    }

    private void press(int px, int py) {
        int edges = border > 0 ? Edges.at(px, py, win.width(), win.height(), border) : 0;
        if (edges != 0) chrome.beginResize(edges);
        else router.press(px, py);
    }

    // The cursor for what is under the pointer: a resize arrow at the edges, else what the widget asks for.
    private void showCursor(int px, int py) {
        int edges = border > 0 ? Edges.at(px, py, win.width(), win.height(), border) : 0;
        int glyph = edges != 0 ? Edges.cursor(edges) : Cursors.ARROW;
        Widget? at = edges != 0 ? null : root.hit(px, py);
        while (at != null) {
            if (at instanceof Control c) { glyph = c.cursor(); break; }
            at = at.parent();
        }
        chrome.setCursor(glyph);
    }
}
