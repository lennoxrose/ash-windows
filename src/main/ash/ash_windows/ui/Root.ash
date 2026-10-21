package ash_windows.ui;

import ash_windows.gfx.Canvas;

/// The top of a window's widget tree: a column filling the window, plus the overlay layer above it, the
/// damage to repaint and whether the tree must be laid out again.
public final class Root extends Box {
    private final Damage damage = new Damage();
    private Overlay? overlay = null;
    private int version = 0;                     // bumped whenever the overlay opens or closes
    private bool layoutNeeded = true;
    private Chrome? chrome = null;

    public Root() { super(true); }

    public Damage damaged() { return damage; }
    public Overlay? overlay() { return overlay; }
    public int overlayVersion() { return version; }

    /// The operating-system window behind this tree.
    public void attach(Chrome c) { chrome = c; }
    public Chrome? chrome() { return chrome; }

    /// Opens (or, with null, closes) the overlay.
    public void setOverlay(Overlay? o) {
        overlay = o;
        version++;
        relayout();
    }

    /// The layer input goes to: the overlay when one is open, else the tree itself.
    public Widget top() {
        Overlay? o = overlay;
        if (o != null) return o;
        return this;
    }

    /// True once after a layout was asked for; the window then lays the tree out and repaints it all.
    public bool takeLayoutRequest() {
        bool was = layoutNeeded;
        layoutNeeded = false;
        return was;
    }

    public void relayout() {
        layoutNeeded = true;
        damage(0, 0, w, h);
    }

    public void layout() {
        super.layout();
        Overlay? o = overlay;
        if (o == null) return;
        o.setBounds(0, 0, w, h);
        o.layout();
    }

    public Widget? hit(int px, int py) {
        Overlay? o = overlay;
        if (o == null) return super.hit(px, py);
        Widget? k = o.hit(px, py);
        return k == null ? o : k;
    }

    public void paint(Canvas c) { c.fill(Theme.get().bg, x, y, w, h); }

    /// Paints the tree, then the overlay, wherever the canvas clip reaches.
    public void paintAll(Canvas c) {
        paintTree(&c);
        Overlay? o = overlay;
        if (o != null) o.paintTree(&c);
    }

    /// Marks the rectangle (clamped to the window) for repainting.
    public void damage(int rx, int ry, int rw, int rh) {
        int x0 = Math.max(0, rx);
        int y0 = Math.max(0, ry);
        damage.add(x0, y0, Math.min(w, rx + rw) - x0, Math.min(h, ry + rh) - y0);
    }
}
