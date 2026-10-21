package ash_windows;

/// Entry point of ash-windows. The library itself is ash_windows.ui.App (windows), ash_windows.gfx (drawing)
/// and ash_windows.x11 (the protocol); see README.md.
public final class AshWindows {
    private AshWindows() { }

    public static String name() {
        return "ash-windows";
    }
}
