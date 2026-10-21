package ash_windows.ui;

import ash.util.List;
import ash_windows.gfx.Canvas;

/// A row of menu titles along the top of a window.
public final class MenuBar extends Box {
    public MenuBar() {
        super(false);
        padding(4).gap(2);
    }

    /// Adds a title whose menu lists `items`; `pick` gets the row chosen.
    public void addMenu(String title, List<String> items, Consumer<Integer> pick) { add(new MenuTitle(title, items, pick)); }

    public void paint(Canvas c) { c.fill(Theme.get().border, x, y + h - 1, w, 1); }
}
