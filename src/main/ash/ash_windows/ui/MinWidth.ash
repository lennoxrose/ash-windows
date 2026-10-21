package ash_windows.ui;

/// Wraps one widget and asks for at least a given width.
public final class MinWidth extends Box {
    private final int min;

    public MinWidth(int min, Widget child) {
        super(true);
        this.min = min;
        add(child);
    }

    public int prefW() { return Math.max(min, super.prefW()); }
}
