package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Keys;

/// A knob on a track: a value from 0 to 1 that `onChange` hears about while it is dragged.
public final class Slider extends Control {
    private final Consumer<Double> onChange;
    private double value;

    public Slider(double value, Consumer<Double> onChange) {
        this.value = value;
        this.onChange = onChange;
    }

    public double value() { return value; }
    public int prefW() { return 180; }
    public int prefH() { return 24; }
    public bool focusable() { return true; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        int cy = y + h / 2;
        int cx = x + 10 + (int) ((w - 20) * value);
        Shapes.roundRect(c, x + 10, cy - 2, w - 20, 4, 2, t.surfaceHi, 255);
        Shapes.roundRect(c, x + 10, cy - 2, cx - x - 10, 4, 2, t.accent, 255);
        Shapes.circle(c, cx, cy, focused || pressed || hover ? 10 : 9, t.accent);
        Shapes.circle(c, cx, cy, 6, t.onAccent);
    }

    public void onPress(int px, int py) {
        setPressed(true);
        move(px);
    }

    public void onMove(int px, int py) { if (pressed) move(px); }
    public void onRelease(int px, int py) { setPressed(false); }

    public bool onKey(int keysym, int state) {
        if (keysym == Keys.LEFT) set(value - 0.05);
        else if (keysym == Keys.RIGHT) set(value + 0.05);
        else if (keysym == Keys.HOME) set(0.0);
        else if (keysym == Keys.END) set(1.0);
        else return false;
        return true;
    }

    private void move(int px) { set((double) (px - x - 10) / Math.max(1, w - 20)); }

    private void set(double v) {
        value = Math.min(1.0, Math.max(0.0, v));
        invalidate();
        onChange.accept(value);
    }
}
