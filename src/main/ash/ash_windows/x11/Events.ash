package ash_windows.x11;

/// The codes X11.waitEvent() returns.
public final class Events {
    private Events() { }

    public static final int NONE = -1;           // nothing happened within the timeout
    public static final int CLOSED = 0;          // the server hung up, or the window manager asked us to close
    public static final int KEY_PRESS = 2;
    public static final int KEY_RELEASE = 3;
    public static final int BUTTON_PRESS = 4;
    public static final int BUTTON_RELEASE = 5;
    public static final int MOTION = 6;
    public static final int LEAVE = 8;
    public static final int EXPOSE = 12;
    public static final int RESIZE = 22;
}
