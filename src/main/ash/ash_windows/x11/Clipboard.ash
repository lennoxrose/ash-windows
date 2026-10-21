package ash_windows.x11;

/// The CLIPBOARD selection: this window owns it after set() and answers other clients' requests for it;
/// get() asks the current owner. Text only (UTF8_STRING), up to 16 KB.
public final class Clipboard {
    private static final int MAX = 16000;
    private final Wire wire;
    private int window = 0;
    private int clip = 0;
    private int utf8 = 0;
    private int targets = 0;
    private int prop = 0;
    private String text = "";
    private bool owned = false;

    public Clipboard(Wire wire) { this.wire = wire; }

    /// Interns the atoms; call before the window is mapped.
    public void init(int window) {
        this.window = window;
        clip = Props.intern(wire, "CLIPBOARD");
        utf8 = Props.intern(wire, "UTF8_STRING");
        targets = Props.intern(wire, "TARGETS");
        prop = Props.intern(wire, "ASH_CLIPBOARD");
    }

    /// SelectionClear (29: someone else took the clipboard) or SelectionRequest (30: they want our text).
    public void handle(int code) {
        if (code == 29) owned = false;
        else Selection.answer(wire, text, targets, utf8);
    }

    public void set(String s) {
        text = s.length() > MAX ? s.substring(0, MAX) : s;
        owned = true;
        wire.send(22, 0, 4);                      // SetSelectionOwner
        wire.p32(4, window);
        wire.p32(8, clip);
        wire.p32(12, 0);
        wire.flush(16);
    }

    /// The clipboard's text, null when it is empty or its owner does not answer in time.
    public String? get() {
        if (owned) return text;
        wire.send(24, 0, 6);                      // ConvertSelection into our property
        wire.p32(4, window);
        wire.p32(8, clip);
        wire.p32(12, utf8);
        wire.p32(16, prop);
        wire.p32(20, 0);
        wire.flush(24);
        for (int tries = 0; tries < 4 && wire.readable(250); tries++) {
            if (!wire.readFull(32)) return null;
            int code = wire.u8(0) & 127;
            if (code == 30) Selection.answer(wire, text, targets, utf8);      // asked for our own selection meanwhile
            if (code == 31) return wire.u32(20) == 0 ? null : Selection.fetch(wire, window, prop, MAX);
        }
        return null;
    }
}
