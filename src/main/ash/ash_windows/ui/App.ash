package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.x11.Events;
import ash_windows.x11.WindowShape;
import ash_windows.x11.X11;

/// A window with a widget tree: `App.open(...)`, fill `root()`, then `run()` until the window closes.
/// `App.openBorderless(...)` asks the window manager for no title bar or border: the application draws its
/// own frame (a TitleBar, any widgets) and can give the window any outline with `setShape`.
public final class App {
    private final X11 win;
    private final Root root = new Root();
    private final Chrome chrome;
    private final WindowInput input;
    private WindowShape? shape = null;
    private bool shapeDirty = false;
    private Canvas canvas;

    private App(X11 win) {
        this.canvas = new Canvas(win.width(), win.height());
        this.win = win;
        this.chrome = new Chrome(this.win);
        root.attach(this.chrome);
        this.input = new WindowInput(this.win, root, this.chrome);
    }

    /// Opens a window with the system's frame on $DISPLAY. Needs Theme.set(...) first. Null: no X server.
    public static App? open(String title, int width, int height) { return launch(title, width, height, true); }

    /// Like open, but with no system frame (title bar, border, buttons): you draw the frame yourself.
    public static App? openBorderless(String title, int width, int height) { return launch(title, width, height, false); }

    private static App? launch(String title, int width, int height, bool decorated) {
        X11? w = X11.open(-1, width, height, title, Theme.get().bg, decorated);
        return w == null ? null : new App(w);
    }

    public Root root() { return root; }

    /// Cuts the window to an outline (null: back to a rectangle). Anything outside it is not drawn and clicks
    /// go through. Edges are hard, there is no anti-aliasing. Follows the window when it is resized.
    public void setShape(WindowShape? s) {
        shape = s;
        shapeDirty = true;
    }

    /// Lets the user resize a window with no frame by dragging within `px` pixels of its edges (0: no).
    public void setResizeBorder(int px) { input.setResizeBorder(px); }

    /// Lays the tree out and handles events until the window is closed.
    public void run() {
        int ev = Events.EXPOSE;
        while (ev != Events.CLOSED) {
            if (ev == Events.EXPOSE) root.damage(0, 0, canvas.width(), canvas.height());
            else if (ev == Events.RESIZE) resize();
            else input.handle(ev);
            input.tick(win.nowMs());
            if (root.takeLayoutRequest()) relayout();
            if (shapeDirty && !win.hasPending()) {
                win.frame().shape(shape, win.width(), win.height());
                shapeDirty = false;
            }
            redraw();
            ev = chrome.closing() ? Events.CLOSED : win.waitEvent(input.wantsTick() ? 100 : -1);
        }
        win.close();
        canvas.free();
    }

    private void resize() {
        canvas.free();
        canvas = new Canvas(win.width(), win.height());
        shapeDirty = true;
        relayout();
    }

    private void relayout() {
        root.setBounds(0, 0, win.width(), win.height());
        root.layout();
    }

    // Repaints each damaged rectangle (uploaded as whole rows, which is what PutImage takes).
    private void redraw() {
        Damage d = root.damaged();
        for (int i = 0; i < d.count(); i++) {
            canvas.setClip(d.x(i), d.y(i), d.w(i), d.h(i));
            root.paintAll(canvas);
            win.putImage(canvas.pixels(), d.y(i), d.h(i));
        }
        d.clear();
    }
}
