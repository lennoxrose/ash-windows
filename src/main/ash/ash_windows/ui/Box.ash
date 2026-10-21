package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Shapes;

/// Lays its children out in a column or a row. Children with a grow weight share the free space; the others
/// take their preferred size. A column stretches children across; a row centres them vertically.
public class Box extends Widget {
    private final bool vertical;
    private int pad = 0;
    private int gap = 0;
    private bool card = false;

    protected Box(bool vertical) { this.vertical = vertical; }

    public static Box column() { return new Box(true); }
    public static Box row() { return new Box(false); }

    public Box padding(int p) { pad = p; return this; }
    public Box gap(int g) { gap = g; return this; }
    /// Draws a raised, bordered surface behind the children.
    public Box card() { card = true; return this; }

    public int prefW() { return extent(false); }
    public int prefH() { return extent(true); }

    public void paint(Canvas c) {
        if (!card) return;
        Theme t = Theme.get();
        Shapes.shadow(c, x, y + 2, w, h, t.radius + 4, 8, 70);
        Shapes.roundRectBorder(c, x, y, w, h, t.radius + 4, t.surface, t.border);
    }

    public void layout() {
        int total = 0;
        int fixed = 0;
        int shown = 0;
        for (Widget k : children) {
            if (!k.visible()) continue;
            shown++;
            total = total + k.growWeight();
            fixed = fixed + (k.growWeight() > 0 ? 0 : (vertical ? k.prefH() : k.prefW()));
        }
        int free = Math.max(0, (vertical ? h : w) - 2 * pad - fixed - gap * Math.max(0, shown - 1));
        int at = (vertical ? y : x) + pad;
        for (Widget k : children) {
            if (!k.visible()) continue;
            int size = k.growWeight() > 0 ? free * k.growWeight() / total : (vertical ? k.prefH() : k.prefW());
            int across = vertical || k.growWeight() > 0 ? (vertical ? w : h) - 2 * pad : Math.min(h - 2 * pad, k.prefH());
            if (vertical) k.setBounds(x + pad, at, across, size);
            else k.setBounds(at, y + (h - across) / 2, size, across);
            k.layout();
            at = at + size + gap;
        }
    }


    // Preferred size along the main axis (sum) or across it (largest).
    private int extent(bool heightWanted) {
        bool along = vertical == heightWanted;
        int sum = 0;
        int most = 0;
        int shown = 0;
        for (Widget k : children) {
            if (!k.visible()) continue;
            int s = heightWanted ? k.prefH() : k.prefW();
            sum = sum + s;
            most = Math.max(most, s);
            shown++;
        }
        return 2 * pad + (along ? sum + gap * Math.max(0, shown - 1) : most);
    }
}
