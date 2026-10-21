package ash_windows.x11;

/// What the last pointer or key event said. Coordinates are signed (a pressed button keeps sending motion
/// outside the window), x / y relative to the window and rootX / rootY on the screen.
public final class EventData {
    private int detail = 0;
    private int x = 0;
    private int y = 0;
    private int state = 0;
    private int rootX = 0;
    private int rootY = 0;
    private int errors = 0;
    private int lastError = 0;

    /// Key press / release: the keysym; button: its number (4 and 5 are the wheel).
    public int detail() { return detail; }
    public int x() { return x; }
    public int y() { return y; }
    public int state() { return state; }
    public int rootX() { return rootX; }
    public int rootY() { return rootY; }

    /// Where the window's top-left corner is on the screen, as of this event.
    public int originX() { return rootX - x; }
    public int originY() { return rootY - y; }

    /// How many requests the server rejected, and the last one (error code * 1000 + the request's opcode).
    public int errors() { return errors; }
    public int lastError() { return lastError; }

    public void error(int code, int opcode) {
        errors++;
        lastError = code * 1000 + opcode;
    }

    public void set(int detail, int x, int y, int state, int rootX, int rootY) {
        this.detail = detail;
        this.x = x;
        this.y = y;
        this.state = state;
        this.rootX = rootX;
        this.rootY = rootY;
    }
}
