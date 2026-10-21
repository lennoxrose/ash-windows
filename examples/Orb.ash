package examples;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Colors;
import ash_windows.gfx.Shapes;
import ash_windows.ui.*;
import ash_windows.x11.WindowShapes;

/// The body of the orb: shaded rings, dragged to move the window, double-click to close it.
class OrbView extends Control {
    private int lastPress = -1000;

    public int prefW() { return 300; }
    public int prefH() { return 300; }

    public void paint(Canvas c) {
        Theme t = Theme.get();
        for (int i = 0; i < 45; i++)
            Shapes.roundRect(c, x + i * 3, y + i * 3, w - i * 6, h - i * 6, (w - i * 6) / 2, Colors.mix(0x1b2a6b, 0x7ad7ff, i * 255 / 44), 255);
        String text = "double-click to close";
        t.bold.draw(c, text, x + (w - t.bold.measure(text)) / 2, y + h / 2 - 8, 0x06122e);
    }

    public void onPress(int px, int py) {
        Chrome? ch = chrome();
        if (ch == null) return;
        if (ch.nowMs() - lastPress < 400) ch.close();
        else ch.beginMove();
        lastPress = ch.nowMs();
    }
}

/// A circular window with no frame, made with WindowShapes.ellipse().
public class Orb {
    public static void main(String[] args) {
        Theme? theme = Theme.create(true);
        if (theme == null) { System.out.println("no TrueType font found"); return; }
        Theme.set(theme);
        App? app = App.openBorderless("Orb", 300, 300);
        if (app == null) { System.out.println("no X server (set DISPLAY)"); return; }
        app.setShape(WindowShapes.ellipse());
        app.root().add(new OrbView().grow(1));
        app.run();
    }
}
