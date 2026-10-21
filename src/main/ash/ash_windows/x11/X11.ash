package ash_windows.x11;

/// One X11 window: pixel upload and input events, over the wire protocol in Ash itself (no native library).
/// Linux + a running X server (Xorg, Xwayland, Xephyr) only.
public class X11 {
    private Wire wire = new Wire();
    private Keyboard keys = new Keyboard(8);
    private Clipboard clip = new Clipboard(wire);
    private Frame frame = new Frame(wire);
    private final EventData ev = new EventData();
    private int depth = 24;
    private int window = 0;
    private int gc = 0;
    private int deleteAtom = 0;
    private int width = 0;
    private int height = 0;

    public EventData event() { return ev; }
    public Frame frame() { return frame; }
    public int width() { return width; }
    public int height() { return height; }
    public int nowMs() { return wire.nowMs(); }
    public void setTitle(String title) { Props.setTitle(wire, window, title); }
    public bool hasPending() { return wire.readable(0); }

    private X11() { }

    /// Opens a window on display :n (n < 0: $DISPLAY) cleared to `background`. With `decorated` false the
    /// window manager is asked not to draw a title bar or border: the application draws its own frame.
    /// Null when no X server answers.
    public static X11? open(int display, int width, int height, String title, int background, bool decorated) {
        X11 x = new X11();
        x.width = width;
        x.height = height;
        Setup? s = Setup.connect(x.wire, display < 0 ? Auth.display() : display);
        if (s == null) { x.close(); return null; }
        x.depth = s.depth();
        int step = s.step();                       // resource ids: base + n * step
        x.window = s.base() | step;
        x.gc = s.base() | (step * 2);
        Windows.create(x.wire, x.window, s.root(), width, height, background);
        x.setTitle(title);
        x.deleteAtom = Props.setIdentity(x.wire, x.window);
        Hints.set(x.wire, x.window, width, height, 160, 100);
        x.frame.init(x.window, s.root(), s.screenW(), s.screenH(), decorated, s.base() | (step * 3), step);
        Keyboard k = new Keyboard(s.minKey());
        k.load(x.wire);
        x.keys = k;
        x.clip.init(x.window);
        Windows.createGc(x.wire, x.gc, x.window, 0);
        Windows.map(x.wire, x.window);
        return x;
    }

    /// Destroys the window and hangs up. Safe to call twice.
    public void close() {
        destroy();
        wire.close();
        keys.free();
    }

    /// Uploads `rows` rows starting at row `y` of a width()-wide 0x00RRGGBB image at `pixels`.
    public void putImage(int pixels, int y, int rows) { Windows.putImage(wire, window, gc, depth, width, pixels, y, rows); }
    /// Puts text on the clipboard / reads it (null: empty, or its owner did not answer). Up to 16 KB.
    public void copy(String text) { clip.set(text); }
    public String? paste() { return clip.get(); }

    /// Waits up to timeoutMs (negative: forever) for the next event the window cares about; returns its code,
    /// Events.NONE on timeout, Events.CLOSED when the window is gone. event() describes pointer and key events.
    public int waitEvent(int timeoutMs) {
        while (true) {
            if (!wire.isOpen()) return Events.CLOSED;
            if (timeoutMs >= 0 && !wire.readable(timeoutMs)) return Events.NONE;
            if (!wire.readFull(32)) return Events.CLOSED;
            int code = wire.u8(0) & 127;
            if (code == 0) { ev.error(wire.u8(1), wire.u8(10)); continue; }       // the server rejected a request
            if (code == 33 && wire.u32(12) == deleteAtom) { destroy(); return Events.CLOSED; }
            if (code == 22 && (wire.u16(20) != width || wire.u16(22) != height)) {
                width = wire.u16(20);
                height = wire.u16(22);
                return Events.RESIZE;
            }
            if (code == 29 || code == 30) { clip.handle(code); continue; }      // selection ownership events
            if (code == 12 && wire.u16(16) == 0) return Events.EXPOSE;      // the last Expose of a batch is enough
            if (code >= 2 && code <= 6 || code == 8) {
                int detail = wire.u8(1);
                if (code <= 3) detail = keys.keysym(detail, wire.u16(28));
                ev.set(detail, wire.i16(24), wire.i16(26), wire.u16(28), wire.i16(20), wire.i16(22));
                return code;
            }
        }
    }

    private void destroy() {
        if (window == 0 || !wire.isOpen()) return;
        Windows.destroy(wire, window);
        window = 0;
    }
}
