package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Cursors;
import ash_windows.x11.Keys;

/// A push button; `action` runs when it is clicked or activated with Return / Space.
public final class Button extends Control {
    private final String label;
    private final Runnable action;
    private bool primary = false;

    public Button(String label, Runnable action) {
        this.label = label;
        this.action = action;
    }

    /// Draws it in the accent colour: the main action of a screen.
    public Button primary() { primary = true; return this; }

    public int prefW() { return Theme.get().bold.measure(label) + 36; }
    public int prefH() { return 36; }
    public int cursor() { return Cursors.HAND; }
    public bool focusable() { return true; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        int fill = primary ? (pressed ? t.accentLo : (hover ? t.accentHi : t.accent))
                : (pressed ? t.border : (hover ? t.surfaceHi : t.surface));
        Shapes.roundRectBorder(c, x, y, w, h, t.radius, fill, focused ? t.accent : (primary ? fill : t.border));
        t.bold.draw(c, label, x + (w - t.bold.measure(label)) / 2, y + (h - t.bold.lineHeight()) / 2,
                primary ? t.onAccent : t.fg);
    }

    public void onPress(int px, int py) { setPressed(true); }

    public void onRelease(int px, int py) {
        setPressed(false);
        if (px >= x && px < x + w && py >= y && py < y + h) action.run();
    }

    public bool onKey(int keysym, int state) {
        if (keysym != Keys.RETURN && keysym != 32) return false;
        action.run();
        return true;
    }
}
