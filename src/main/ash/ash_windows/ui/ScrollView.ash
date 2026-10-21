package ash_windows.ui;

import ash_windows.gfx.Canvas;

/// Shows a taller child through a window: the wheel scrolls it, the thumb at the right edge can be dragged.
/// The child is laid out at its preferred height; give the view a grow weight (or a fixed place) to size it.
public final class ScrollView extends Control {
    private int offset = 0;
    private bool dragging = false;

    public int prefW() { return children.size() == 0 ? 0 : children.get(0).prefW() + 12; }
    public int prefH() { return 120; }
    public bool clipsChildren() { return true; }

    private int content() { return children.size() == 0 ? 0 : children.get(0).prefH(); }

    public void layout() {
        if (children.size() == 0) return;
        offset = Math.min(offset, Math.max(0, content() - h));
        Widget k = children.get(0);
        k.setBounds(x, y - offset, w - (content() > h ? 12 : 0), Math.max(content(), h));
        k.layout();
    }

    public bool onScroll(int px, int py, int dir) {
        int before = offset;
        offset = Math.min(Math.max(0, content() - h), Math.max(0, offset + dir * 48));
        if (offset == before) return false;
        layout();
        invalidate();
        return true;
    }

    public void paintOver(Canvas c) { Scrollbar.draw(c, x, y, w, h, content(), offset, hover || dragging); }

    public void onPress(int px, int py) {
        dragging = px >= x + w - 12 && content() > h;
        if (dragging) drag(py);
    }

    public void onMove(int px, int py) { if (dragging) drag(py); }
    public void onRelease(int px, int py) { dragging = false; invalidate(); }

    private void drag(int py) {
        offset = Scrollbar.offsetAt(py - y, h, content());
        layout();
        invalidate();
    }
}
