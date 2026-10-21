package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;

/// A bar showing a value from 0 to 1.
public final class Progress extends Widget {
    private double value = 0;

    public Progress(double value) { this.value = value; }

    public void setValue(double v) {
        value = Math.min(1.0, Math.max(0.0, v));
        invalidate();
    }

    public int prefW() { return 120; }
    public int prefH() { return 8; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        Shapes.roundRect(c, x, y, w, h, h / 2, t.surfaceHi, 255);
        int filled = (int) (w * value);
        if (filled > 0) Shapes.roundRect(c, x, y, Math.max(filled, h), h, h / 2, t.accent, 255);
    }
}
