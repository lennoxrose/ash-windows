package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Cursors;
import ash_windows.x11.Keys;

/// A labelled box that is on or off; `onChange` gets the new state.
public final class Checkbox extends Control {
    private final String label;
    private final Consumer<Boolean> onChange;
    private bool checked;

    public Checkbox(String label, bool checked, Consumer<Boolean> onChange) {
        this.label = label;
        this.checked = checked;
        this.onChange = onChange;
    }

    public bool checked() { return checked; }
    public int prefW() { return 28 + Theme.get().text.measure(label); }
    public int prefH() { return 28; }
    public int cursor() { return Cursors.HAND; }
    public bool focusable() { return true; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        int by = y + (h - 18) / 2;
        int edge = focused || hover || checked ? t.accent : t.border;
        Shapes.roundRectBorder(c, x, by, 18, 18, 5, checked ? t.accent : t.surface, edge);
        if (checked) {
            Shapes.line(c, x + 4, by + 9, x + 8, by + 13, 2.2, t.onAccent);
            Shapes.line(c, x + 8, by + 13, x + 14, by + 5, 2.2, t.onAccent);
        }
        t.text.draw(c, label, x + 28, y + (h - t.text.lineHeight()) / 2, t.fg);
    }

    public void onPress(int px, int py) { setPressed(true); }

    public void onRelease(int px, int py) {
        setPressed(false);
        if (px >= x && px < x + w && py >= y && py < y + h) toggle();
    }

    public bool onKey(int keysym, int state) {
        if (keysym != 32 && keysym != Keys.RETURN) return false;
        toggle();
        return true;
    }

    private void toggle() {
        checked = !checked;
        invalidate();
        onChange.accept(checked);
    }
}
