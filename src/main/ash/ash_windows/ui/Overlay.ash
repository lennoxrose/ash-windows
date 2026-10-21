package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.x11.Keys;

/// A layer above the whole window: a dialog (dimmed, centred) or a popup menu (at a point, closes when you
/// click outside it). Escape closes either; Return runs the `enter` action.
public final class Overlay extends Control {
    private final Root owner;
    private final bool dim;
    private final int ax;
    private final int ay;
    private final Runnable enter;

    private Overlay(Root owner, Widget content, bool dim, int ax, int ay, Runnable enter) {
        this.dim = dim;
        this.ax = ax;
        this.ay = ay;
        this.enter = enter;
        this.owner = owner;
        add(content);
    }

    /// Shows `content` centred over a dimmed window.
    public static void dialog(Root root, Widget content, Runnable enter) {
        root.setOverlay(new Overlay(root, content, true, -1, -1, enter));
    }

    /// Shows `content` with its top-left corner at (x, y), kept inside the window.
    public static void popup(Root root, Widget content, int x, int y) {
        root.setOverlay(new Overlay(root, content, false, x, y, () -> { }));
    }

    public int prefW() { return w; }
    public int prefH() { return h; }
    public void close() { owner.setOverlay(null); }
    public Root? root() { return owner; }

    public void layout() {
        Widget k = children.get(0);
        int cw = Math.min(w, k.prefW());
        int ch = Math.min(h, k.prefH());
        k.setBounds(ax < 0 ? (w - cw) / 2 : Math.min(ax, w - cw), ay < 0 ? (h - ch) / 2 : Math.min(ay, h - ch), cw, ch);
        k.layout();
    }

    public void paint(Canvas c) { if (dim) c.fillAlpha(0, x, y, w, h, 110); }

    // A press that lands on the overlay itself (outside the content) closes a popup.
    public void onPress(int px, int py) {
        Widget k = children.get(0);
        bool inside = px >= k.x() && px < k.x() + k.w() && py >= k.y() && py < k.y() + k.h();
        if (!inside && !dim) close();
    }

    public bool onKey(int keysym, int state) {
        if (children.get(0) instanceof Control c && c.onKey(keysym, state)) return true;      // arrows in a menu
        if (keysym == Keys.ESCAPE) close();
        else if (keysym == Keys.RETURN) { enter.run(); close(); }
        else return false;
        return true;
    }
}
