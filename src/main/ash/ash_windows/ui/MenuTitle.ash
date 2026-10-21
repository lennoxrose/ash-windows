package ash_windows.ui;

import ash.util.List;
import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Cursors;

/// One title in a MenuBar: opens its menu under itself when clicked.
public final class MenuTitle extends Control {
    private final String title;
    private final List<String> items;
    private final Consumer<Integer> pick;

    public MenuTitle(String title, List<String> items, Consumer<Integer> pick) {
        this.title = title;
        this.items = items;
        this.pick = pick;
    }

    public int prefW() { return Theme.get().text.measure(title) + 20; }
    public int prefH() { return 30; }
    public int cursor() { return Cursors.HAND; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        if (hover || pressed) Shapes.roundRect(c, x, y, w, h, 6, t.surfaceHi, 255);
        t.text.draw(c, title, x + 10, y + (h - t.text.lineHeight()) / 2, t.fg);
    }

    public void onPress(int px, int py) { setPressed(true); }

    public void onRelease(int px, int py) {
        setPressed(false);
        Root? r = root();
        if (r != null && px >= x && px < x + w && py >= y && py < y + h) Menu.popup(r, x, y + h, 160, items, pick);
    }
}
