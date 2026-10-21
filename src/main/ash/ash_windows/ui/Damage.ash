package ash_windows.ui;

import ash.util.ArrayList;
import ash.util.List;

/// The rectangles of a window that need repainting. Rectangles that touch are merged into one.
public final class Damage {
    private final List<Integer> rects = new ArrayList<>();      // x, y, w, h of each, flat

    public int count() { return rects.size() / 4; }
    public int x(int i) { return rects.get(i * 4); }
    public int y(int i) { return rects.get(i * 4 + 1); }
    public int w(int i) { return rects.get(i * 4 + 2); }
    public int h(int i) { return rects.get(i * 4 + 3); }

    public void clear() {
        while (rects.size() > 0) rects.removeLast();
    }

    public void add(int x, int y, int w, int h) {
        if (w <= 0 || h <= 0) return;
        int x1 = x + w;
        int y1 = y + h;
        bool merged = true;
        while (merged) {
            merged = false;
            for (int i = 0; i < count() && !merged; i++) {
                int ox = x(i);
                int oy = y(i);
                if (ox > x1 || ox + w(i) < x || oy > y1 || oy + h(i) < y) continue;
                x1 = Math.max(x1, ox + w(i));
                y1 = Math.max(y1, oy + h(i));
                x = Math.min(x, ox);
                y = Math.min(y, oy);
                for (int k = 0; k < 4; k++) rects.remove(i * 4);
                merged = true;
            }
        }
        rects.add(x);
        rects.add(y);
        rects.add(x1 - x);
        rects.add(y1 - y);
    }
}
