package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.x11.Cursors;

/// A title bar for a window with no frame of its own: the title, close / minimise / maximize buttons, drag to
/// move the window, double-click to maximize. `new TitleBar(title, true)` puts round buttons on the left
/// (centred title), `false` puts flat ones on the right. Compose your own from DragArea and Buttons for any look.
public final class TitleBar extends Control {
    private static final int CLOSE = 1;
    private static final int MINIMIZE = 2;
    private static final int MAXIMIZE = 3;
    private final String title;
    private final bool left;
    private final int[] order;                   // which button is in each of the three places
    private int hot = 0;                         // the button under the pointer
    private int lastPress = -1000;

    public TitleBar(String title, bool buttonsLeft) {
        this.title = title;
        this.left = buttonsLeft;
        this.order = buttonsLeft ? new int[] {CLOSE, MINIMIZE, MAXIMIZE} : new int[] {MINIMIZE, MAXIMIZE, CLOSE};
    }

    public int prefW() { return 200; }
    public int prefH() { return 38; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        c.fill(t.surface, x, y, w, h);
        c.fill(t.border, x, y + h - 1, w, 1);
        int tw = t.bold.measure(title);
        t.bold.draw(c, title, left ? x + (w - tw) / 2 : x + 16, y + (h - t.bold.lineHeight()) / 2, t.fg);
        for (int i = 0; i < 3; i++) {
            int kind = order[i];
            bool on = hot == kind;
            int cx = left ? bx(i) + 7 : bx(i) + 22;
            int cy = left ? by() + 7 : by() + h / 2;
            int mark = left ? 0x4a2c00 : (on && kind == CLOSE ? 0xffffff : t.fg);
            if (left) Shapes.roundRect(c, bx(i), by(), 14, 14, 7, kind == CLOSE ? 0xff5f57 : (kind == MINIMIZE ? 0xffbd2e : 0x28c840), 255);
            else if (on) c.fill(kind == CLOSE ? 0xe5484d : t.surfaceHi, bx(i), by(), 44, h - 1);
            if (left && !on) continue;            // the round buttons show their symbol on hover only
            if (kind == MINIMIZE) Shapes.line(c, cx - 4, cy, cx + 4, cy, 1.6, mark);
            else if (kind == MAXIMIZE) Shapes.roundRectBorder(c, cx - 4, cy - 4, 9, 9, 1, left ? 0x28c840 : t.surface, mark);
            else { Shapes.line(c, cx - 4, cy - 4, cx + 4, cy + 4, 1.6, mark); Shapes.line(c, cx - 4, cy + 4, cx + 4, cy - 4, 1.6, mark); }
        }
    }

    public void onMove(int px, int py) {
        int now = at(px, py);
        if (now == hot) return;
        hot = now;
        invalidate();
    }

    public void setHover(bool v) {
        super.setHover(v);
        if (!v) hot = 0;
    }

    public void onPress(int px, int py) {
        Chrome? ch = chrome();
        if (ch == null || at(px, py) != 0) return;
        if (ch.nowMs() - lastPress < 400) ch.toggleMaximize();
        else ch.beginMove();
        lastPress = ch.nowMs();
    }

    public void onRelease(int px, int py) {
        Chrome? ch = chrome();
        int kind = at(px, py);
        if (ch == null || kind == 0) return;
        if (kind == CLOSE) ch.close();
        else if (kind == MINIMIZE) ch.minimize();
        else ch.toggleMaximize();
    }

    public int cursor() { return hot == 0 ? Cursors.ARROW : Cursors.HAND; }

    private int bx(int i) { return left ? x + 16 + i * 24 : x + w - 132 + i * 44; }
    private int by() { return left ? y + h / 2 - 7 : y; }

    // The button at the point (0 for none).
    private int at(int px, int py) {
        for (int i = 0; i < 3; i++)
            if (px >= bx(i) && px < bx(i) + (left ? 14 : 44) && py >= by() && py < by() + (left ? 14 : h)) return order[i];
        return 0;
    }
}
