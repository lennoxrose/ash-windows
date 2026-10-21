package ash_windows.ui;

/// Empty space; give it a grow weight to push its neighbours apart.
public final class Spacer extends Widget {
    public int prefW() { return 0; }
    public int prefH() { return 0; }
}
