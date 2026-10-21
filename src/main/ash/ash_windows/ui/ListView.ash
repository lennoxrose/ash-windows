package ash_windows.ui;

import ash.util.ArrayList;
import ash.util.List;
import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Keys;

/// A scrolling list of text rows with one selected row. Click, Up/Down, Return and the wheel work;
/// `onSelect` gets the row index. `menu()` drops the frame so it can sit inside a popup.
public final class ListView extends Control {
    private static final int ROW = 30;
    private final List<String> items = new ArrayList<>();
    private final Consumer<Integer> onSelect;
    private int selected = -1;
    private int offset = 0;
    private int row = -1;                        // the row under the pointer
    private bool framed = true;

    public ListView(Consumer<Integer> onSelect) { this.onSelect = onSelect; }

    public ListView menu() { framed = false; return this; }
    public int selected() { return selected; }
    public bool focusable() { return true; }
    public int prefH() { return Math.min(300, items.size() * ROW + 4); }

    public int prefW() {
        int widest = 0;
        for (String s : items) widest = Math.max(widest, Theme.get().text.measure(s));
        return widest + 28;
    }

    public void addItem(String text) {
        items.add(text);
        relayout();
    }

    public void clear() {
        while (items.size() > 0) items.removeLast();
        selected = -1;
        offset = 0;
        relayout();
    }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        if (framed) Shapes.roundRectBorder(c, x, y, w, h, t.radius, t.surface, focused ? t.accent : t.border);
        c.clip().push(x + 1, y + 1, w - 2, h - 2);
        for (int i = Math.max(0, offset / ROW); i < Math.min(items.size(), (offset + h) / ROW + 1); i++) {
            int ry = y + 2 + i * ROW - offset;
            if (i == selected) Shapes.roundRect(c, x + 4, ry, w - 8, ROW - 2, 6, t.accent, 255);
            else if (i == row) Shapes.roundRect(c, x + 4, ry, w - 8, ROW - 2, 6, t.surfaceHi, 255);
            t.text.draw(c, items.get(i), x + 14, ry + (ROW - 2 - t.text.lineHeight()) / 2, i == selected ? t.onAccent : t.fg);
        }
        c.clip().pop();
        Scrollbar.draw(c, x, y, w, h, items.size() * ROW + 4, offset, hover);
    }

    public void onMove(int px, int py) { rowAt(py); }
    public void onPress(int px, int py) { choose(rowAt(py)); }
    public void setHover(bool v) { super.setHover(v); if (!v) row = -1; }

    public bool onScroll(int px, int py, int dir) {
        int before = offset;
        offset = Math.min(Math.max(0, items.size() * ROW + 4 - h), Math.max(0, offset + dir * ROW * 2));
        if (offset != before) invalidate();
        return offset != before;
    }

    public bool onKey(int keysym, int state) {
        if (keysym == Keys.UP) choose(Math.max(0, selected - 1));
        else if (keysym == Keys.DOWN) choose(Math.min(items.size() - 1, selected + 1));
        else if (keysym == Keys.RETURN && selected >= 0) onSelect.accept(selected);
        else return false;
        return true;
    }

    private int rowAt(int py) {
        int at = (py - y - 2 + offset) / ROW;
        row = at >= 0 && at < items.size() ? at : -1;
        invalidate();
        return row;
    }

    private void choose(int i) {
        if (i < 0 || i >= items.size()) return;
        selected = i;
        if (i * ROW < offset) offset = i * ROW;
        if ((i + 1) * ROW + 4 > offset + h) offset = (i + 1) * ROW + 4 - h;
        invalidate();
        onSelect.accept(i);
    }
}
