package ash_windows.ui;

import ash_windows.x11.Keys;

/// Turns raw pointer and key input into Control calls: hover, press (a press owns the pointer until its
/// release), wheel, keyboard focus and Tab order. Input goes to the overlay while one is open.
public final class Router {
    private final Root root;
    private final Focus focus = new Focus();
    private Control? hovered = null;
    private Control? pressed = null;
    private int seen = 0;                        // the overlay version the state below belongs to

    public Router(Root root) { this.root = root; }

    public void move(int px, int py) {
        sync();
        Control? owner = pressed;
        if (owner != null) { owner.onMove(px, py); return; }
        Control? now = control(root.hit(px, py));
        Control? before = hovered;
        if (before != null && before != now) before.setHover(false);
        if (now != null && now != before) now.setHover(true);
        if (now != null) now.onMove(px, py);
        hovered = now;
    }

    public void press(int px, int py) {
        sync();
        pressed = control(root.hit(px, py));
        Control? target = pressed;                // reads of a field are fresh references
        if (target == null) return;
        focus.set(target.focusable() ? control(root.hit(px, py)) : null);
        target.onPress(px, py);
    }

    public void release(int px, int py) {
        sync();
        Control? owner = pressed;
        pressed = null;
        if (owner != null) owner.onRelease(px, py);
        move(px, py);
    }

    /// A wheel step: the first control at or above the pointer that uses it.
    public void scroll(int px, int py, int dir) {
        sync();
        Widget? at = root.hit(px, py);
        while (at != null) {
            if (at instanceof Control c && c.onScroll(px, py, dir)) return;
            at = at.parent();
        }
    }

    public void leave() {
        Control? before = hovered;
        if (before != null) before.setHover(false);
        hovered = null;
    }

    /// A key press: the focused control gets it first, then the overlay; Tab / Shift+Tab move the focus.
    public void key(int keysym, int state) {
        sync();
        if (focus.key(keysym, state)) return;
        Overlay? o = root.overlay();
        if (o != null && o.onKey(keysym, state)) return;
        if (keysym == Keys.TAB) focus.step(root.top(), 1);
        else if (keysym == Keys.BACKTAB) focus.step(root.top(), -1);
    }

    public bool wantsTick() { return focus.wantsTick(); }
    public void tick(int nowMs) { focus.tick(nowMs); }

    // The first Control at or above the widget.
    private Control? control(Widget? w) {
        Widget? at = w;
        while (at != null) {
            if (at instanceof Control c) return c;
            at = at.parent();
        }
        return null;
    }

    // An overlay opened or closed: what was hovered, pressed or focused belongs to the old layer.
    private void sync() {
        if (root.overlayVersion() == seen) return;
        seen = root.overlayVersion();
        Control? h = hovered;
        if (h != null) h.setHover(false);
        Control? p = pressed;
        if (p != null) p.setPressed(false);
        hovered = null;
        pressed = null;
        focus.set(null);
    }
}
