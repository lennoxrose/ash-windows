package ash_windows.ui;

import ash.util.List;
import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Cursors;
import ash_windows.x11.Keys;

/// A dropdown: shows the chosen option and opens a menu of all of them. `onChange` gets the new index.
public final class Select extends Control {
    private final List<String> options;
    private final Consumer<Integer> onChange;
    private int index;

    public Select(List<String> options, int index, Consumer<Integer> onChange) {
        this.index = index;
        this.onChange = onChange;
        this.options = options;
    }

    public int index() { return index; }
    public int prefW() { return 180; }
    public int prefH() { return 36; }
    public int cursor() { return Cursors.HAND; }
    public bool focusable() { return true; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        Shapes.roundRectBorder(c, x, y, w, h, t.radius, pressed ? t.border : (hover ? t.surfaceHi : t.surface), focused ? t.accent : t.border);
        t.text.draw(c, options.get(index), x + 12, y + (h - t.text.lineHeight()) / 2, t.fg);
        int cx = x + w - 18;
        Shapes.line(c, cx - 4, y + h / 2 - 2, cx, y + h / 2 + 2, 1.8, t.dim);
        Shapes.line(c, cx, y + h / 2 + 2, cx + 4, y + h / 2 - 2, 1.8, t.dim);
    }

    public void onPress(int px, int py) { setPressed(true); }

    public void onRelease(int px, int py) {
        setPressed(false);
        if (px >= x && px < x + w && py >= y && py < y + h) open();
    }

    public bool onKey(int keysym, int state) {
        if (keysym != Keys.RETURN && keysym != 32 && keysym != Keys.DOWN) return false;
        open();
        return true;
    }

    private void open() {
        Root? r = root();
        if (r != null) Menu.popup(r, x, y + h + 2, w, options, i -> { index = i; invalidate(); onChange.accept(i); });
    }
}
