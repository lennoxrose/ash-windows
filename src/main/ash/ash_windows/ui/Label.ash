package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Font;

/// One line of text.
public final class Label extends Widget {
    private String text;
    private int style = 0;                       // 0 body, 1 dim, 2 bold, 3 title

    public Label(String text) { this.text = text; }

    public Label dim() { style = 1; return this; }
    public Label bold() { style = 2; return this; }
    public Label title() { style = 3; return this; }
    public String text() { return text; }

    public void setText(String s) {
        text = s;
        invalidate();
    }

    public int prefW() { return font().measure(text); }
    public int prefH() { return font().lineHeight(); }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        font().draw(c, text, x, y + (h - font().lineHeight()) / 2, style == 1 ? t.dim : t.fg);
    }

    private Font font() {
        Theme t = Theme.get();
        return style == 2 ? t.bold : (style == 3 ? t.title : t.text);
    }
}
