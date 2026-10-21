package ash_windows.x11;

/// Modifier bits of X11.eventState() and the keysyms of the keys that are not printable characters.
public final class Keys {
    private Keys() { }

    public static final int SHIFT = 1;
    public static final int CONTROL = 4;
    public static final int ALT = 8;

    public static final int BACKSPACE = 0xff08;
    public static final int TAB = 0xff09;
    public static final int BACKTAB = 0xfe20;     // shift+tab
    public static final int RETURN = 0xff0d;
    public static final int ESCAPE = 0xff1b;
    public static final int HOME = 0xff50;
    public static final int LEFT = 0xff51;
    public static final int UP = 0xff52;
    public static final int RIGHT = 0xff53;
    public static final int DOWN = 0xff54;
    public static final int END = 0xff57;
    public static final int DELETE = 0xffff;
}
