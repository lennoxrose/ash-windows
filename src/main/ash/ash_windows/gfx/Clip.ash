package ash_windows.gfx;

import ash.util.ArrayList;
import ash.util.List;

/// A clip rectangle (x0..x1, y0..y1, exclusive at the far end) that can be narrowed and restored.
public final class Clip {
    private int x0 = 0;
    private int y0 = 0;
    private int x1;
    private int y1;
    private final List<Integer> saved = new ArrayList<>();

    public Clip(int width, int height) {
        x1 = width;
        y1 = height;
    }

    public int left() { return x0; }
    public int top() { return y0; }
    public int right() { return x1; }
    public int bottom() { return y1; }

    /// Narrows the clip to its overlap with the rectangle until the matching pop().
    public void push(int x, int y, int w, int h) {
        saved.add(x0);
        saved.add(y0);
        saved.add(x1);
        saved.add(y1);
        x0 = Math.max(x0, x);
        y0 = Math.max(y0, y);
        x1 = Math.min(x1, x + w);
        y1 = Math.min(y1, y + h);
    }

    public void pop() {
        y1 = saved.removeLast();
        x1 = saved.removeLast();
        y0 = saved.removeLast();
        x0 = saved.removeLast();
    }

    /// Forgets all pushes; the clip becomes the rectangle, limited to the width x height area.
    public void reset(int width, int height, int x, int y, int w, int h) {
        while (saved.size() > 0) saved.removeLast();
        x0 = Math.max(0, x);
        y0 = Math.max(0, y);
        x1 = Math.min(width, x + w);
        y1 = Math.min(height, y + h);
    }

    public bool intersects(int x, int y, int w, int h) { return x < x1 && x + w > x0 && y < y1 && y + h > y0; }
}
