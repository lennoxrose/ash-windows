package ash_windows.ui;

import ash_windows.gfx.Canvas;

/// A thin line across a column.
public final class Separator extends Widget {
    public int prefW() { return 1; }
    public int prefH() { return 1; }

    public void paint(Canvas c) { c.fill(Theme.get().border, x, y, w, 1); }
}
