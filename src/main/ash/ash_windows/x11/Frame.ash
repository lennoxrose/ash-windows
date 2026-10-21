package ash_windows.x11;

/// The window as the window manager and the screen see it: decorations on or off, cursor, position and size,
/// maximize, iconify, and its outline (Shape extension).
public final class Frame {
    private final Wire wire;
    private final Cursors cursors;
    private int window = 0;
    private int root = 0;
    private int screenW = 0;
    private int screenH = 0;
    private int change = 0;                      // WM_CHANGE_STATE
    private int state = 0;                       // _NET_WM_STATE and its two maximized flags
    private int maxH = 0;
    private int maxV = 0;
    private int shapeOp = 0;                     // major opcode of the Shape extension, 0 when absent
    private bool wm = false;                     // a window manager is running
    private bool maximized = false;              // only tracked when there is none
    private int[] restore = new int[4];

    public Frame(Wire wire) {
        this.wire = wire;
        this.cursors = new Cursors(this.wire);
    }

    public bool hasShape() { return shapeOp != 0; }
    public void cursor(int glyph) { cursors.set(glyph); }

    /// Sets up what needs replies, so call it before the window is mapped. With `decorated` false the window
    /// manager is asked (via _MOTIF_WM_HINTS) to draw no title bar or border. Resource ids from `firstId` on
    /// (every `step`) are used for cursors.
    public void init(int window, int root, int screenW, int screenH, bool decorated, int firstId, int step) {
        this.window = window;
        this.root = root;
        this.screenW = screenW;
        this.screenH = screenH;
        change = Props.intern(wire, "WM_CHANGE_STATE");
        state = Props.intern(wire, "_NET_WM_STATE");
        maxH = Props.intern(wire, "_NET_WM_STATE_MAXIMIZED_HORZ");
        maxV = Props.intern(wire, "_NET_WM_STATE_MAXIMIZED_VERT");
        shapeOp = Query.extension(wire, "SHAPE");
        wm = Query.hasProperty(wire, root, Props.intern(wire, "_NET_SUPPORTING_WM_CHECK"));
        cursors.init(window, firstId, step);
        if (decorated) return;
        int motif = Props.intern(wire, "_MOTIF_WM_HINTS");
        wire.send(18, 0, 11);                     // ChangeProperty: flags = decorations, decorations = none
        wire.p32(4, window);
        wire.p32(8, motif);
        wire.p32(12, motif);
        wire.p8(16, 32);
        wire.p32(20, 5);
        wire.p32(24, 2);
        for (int i = 28; i < 44; i = i + 4) wire.p32(i, 0);
        wire.flush(44);
    }

    public void moveResize(int x, int y, int w, int h) {
        wire.send(12, 0, 7);                      // ConfigureWindow: x, y, width, height
        wire.p32(4, window);
        wire.p16(8, 15);
        wire.p16(10, 0);
        wire.p32(12, x);
        wire.p32(16, y);
        wire.p32(20, w);
        wire.p32(24, h);
        wire.flush(28);
    }

    /// Maximizes, or restores. With a window manager it is asked to (so it can animate and remember); without
    /// one the window fills the screen itself. (x, y, w, h) is where the window is now.
    public void toggleMaximize(int x, int y, int w, int h) {
        if (wm) { WmMessage.send(wire, root, window, state, 2, maxH, maxV); return; }
        if (maximized) moveResize(restore[0], restore[1], restore[2], restore[3]);
        else { restore[0] = x; restore[1] = y; restore[2] = w; restore[3] = h; moveResize(0, 0, screenW, screenH); }
        maximized = !maximized;
    }

    /// Asks the window manager to minimise the window (nothing happens without one).
    public void iconify() { WmMessage.send(wire, root, window, change, 3, 0, 0); }

    /// Cuts the window to the shape (null: the plain rectangle again). No effect when the server has no Shape.
    public void shape(WindowShape? s, int w, int h) {
        if (shapeOp == 0) return;
        if (s == null) ShapeExt.reset(wire, shapeOp, window);
        else ShapeExt.apply(wire, shapeOp, window, s, w, h);
    }
}
