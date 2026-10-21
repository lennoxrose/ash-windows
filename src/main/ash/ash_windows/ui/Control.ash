package ash_windows.ui;

import ash_windows.x11.Cursors;

/// A widget that reacts to input: hover / press / focus state and the handlers the Router calls.
public abstract class Control extends Widget {
    protected bool hover = false;
    protected bool pressed = false;
    protected bool focused = false;

    /// The cursor glyph while the pointer is over this control (Cursors.HAND, Cursors.TEXT, ...).
    public int cursor() { return Cursors.ARROW; }

    /// The window around this widget, or null while it is not in one.
    protected Chrome? chrome() {
        Root? r = root();
        return r == null ? null : r.chrome();
    }

    public bool focusable() { return false; }
    public bool wantsTick() { return false; }
    public void tick(int nowMs) { }
    public void onPress(int px, int py) { }
    public void onRelease(int px, int py) { }
    public void onMove(int px, int py) { }

    /// A key press while focused; true when it was used.
    public bool onKey(int keysym, int state) { return false; }

    /// A wheel step under the pointer (dir -1 up, 1 down); true when it was used.
    public bool onScroll(int px, int py, int dir) { return false; }

    public void setHover(bool v) { if (hover != v) { hover = v; invalidate(); } }
    public void setPressed(bool v) { if (pressed != v) { pressed = v; invalidate(); } }
    public void setFocused(bool v) { if (focused != v) { focused = v; invalidate(); } }
}
