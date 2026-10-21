package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;
import ash_windows.gfx.Utf8;
import ash_windows.x11.Cursors;
import ash_windows.x11.Keys;

/// A single-line text input with selection (shift+arrows, drag, Ctrl+A) and clipboard (Ctrl+C / X / V).
/// `onChange` hears every edit, `onSubmit` hears Return.
public final class TextField extends Control {
    private final String hint;
    private final Consumer<String> onChange;
    private final Consumer<String> onSubmit;
    private final TextEdit ed = new TextEdit();
    private bool caret = true;
    private int lastBlink = 0;

    public TextField(String hint, Consumer<String> onChange, Consumer<String> onSubmit) {
        this.hint = hint;
        this.onChange = onChange;
        this.onSubmit = onSubmit;
    }

    public String text() { return ed.text(); }
    public int prefW() { return 220; }
    public int prefH() { return 36; }
    public bool focusable() { return true; }
    public bool wantsTick() { return true; }
    public int cursor() { return Cursors.TEXT; }

    public void setText(String s) {
        ed.set(s);
        invalidate();
    }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        Shapes.roundRectBorder(c, x, y, w, h, t.radius, t.surface, focused ? t.accent : (hover ? t.dim : t.border));
        int ty = y + (h - t.text.lineHeight()) / 2;
        c.clip().push(x + 6, y + 2, w - 12, h - 4);
        int x0 = x + 12 + t.text.measure(ed.before(ed.selStart()));
        int x1 = x + 12 + t.text.measure(ed.before(ed.selEnd()));
        if (ed.hasSelection()) Shapes.roundRect(c, x0, y + 6, x1 - x0, h - 12, 3, t.accent, 110);
        if (ed.text().length() == 0) t.text.draw(c, hint, x + 12, ty, t.dim);
        else t.text.draw(c, ed.text(), x + 12, ty, t.fg);
        if (focused && caret) c.fill(t.fg, x + 12 + t.text.measure(ed.before(ed.cursor())), y + 8, 1, h - 16);
        c.clip().pop();
    }

    public void tick(int nowMs) {
        if (nowMs - lastBlink < 530) return;
        lastBlink = nowMs;
        caret = !caret;
        invalidate();
    }

    public void onPress(int px, int py) {
        setPressed(true);
        ed.moveTo(ed.indexAt(px - x - 12), false);
        showCaret();
    }

    public void onMove(int px, int py) {
        if (!pressed) return;
        ed.moveTo(ed.indexAt(px - x - 12), true);
        showCaret();
    }

    public void onRelease(int px, int py) { setPressed(false); }

    public bool onKey(int keysym, int state) {
        bool shift = (state & Keys.SHIFT) != 0;
        if ((state & Keys.CONTROL) != 0) {
            int done = TextShortcuts.run(ed, chrome(), keysym);
            if (done == 2) changed();
            if (done > 0) showCaret();
            return done > 0;
        }
        if (keysym == Keys.RETURN) { onSubmit.accept(ed.text()); return true; }
        if (keysym == Keys.LEFT) ed.left(shift);
        else if (keysym == Keys.RIGHT) ed.right(shift);
        else if (keysym == Keys.HOME) ed.moveTo(0, shift);
        else if (keysym == Keys.END) ed.moveTo(ed.text().length(), shift);
        else if (keysym == Keys.BACKSPACE) { ed.backspace(); changed(); }
        else if (keysym == Keys.DELETE) { ed.delete(); changed(); }
        else if ((keysym >= 32 && keysym < 127) || (keysym >= 160 && keysym < 256)) { ed.insert(Utf8.encode(keysym)); changed(); }
        else return false;
        showCaret();
        return true;
    }

    private void changed() { onChange.accept(ed.text()); }

    private void showCaret() {
        caret = true;
        invalidate();
    }
}
