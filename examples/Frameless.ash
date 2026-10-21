package examples;

import ash_windows.ui.*;
import ash_windows.x11.WindowShapes;

/// A window with no system frame: rounded corners, its own title bar, resizable from its edges.
///   Xephyr :9 -screen 800x600 &   then   DISPLAY=:9 ashvm run examples/Frameless.ash
public class Frameless {
    private final Label status = new Label("Drag the title bar. Resize from any edge.").dim();

    private Box build(App app) {
        Box page = Box.column().padding(20).gap(14);
        page.add(new Label("No system frame").title());
        page.add(new Label("The window manager draws nothing here: the title bar, the buttons and the").dim());
        page.add(new Label("rounded corners are all this program's own.").dim());
        page.add(new Slider(0.5, v -> status.setText("Slider " + (int) (v * 100))));
        page.add(new Spacer().grow(1));
        page.add(status);
        return page;
    }

    public static void main(String[] args) {
        Theme? theme = Theme.create(true);
        if (theme == null) { System.out.println("no TrueType font found"); return; }
        Theme.set(theme);
        App? app = App.openBorderless("Frameless", 520, 360);
        if (app == null) { System.out.println("no X server (set DISPLAY)"); return; }
        app.setShape(WindowShapes.rounded(14));
        app.setResizeBorder(6);
        app.root().add(new TitleBar("Frameless", true));
        app.root().add(new Frameless().build(app).grow(1));
        app.run();
    }
}
