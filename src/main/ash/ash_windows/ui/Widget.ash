package ash_windows.ui;

import ash.util.ArrayList;
import ash.util.List;
import ash_windows.gfx.Canvas;

/// Base of the retained widget tree: bounds, children, layout and painting. Positions are window coordinates,
/// set by the parent's layout(). Widgets that react to input extend Control.
public abstract class Widget {
    protected int x = 0;
    protected int y = 0;
    protected int w = 0;
    protected int h = 0;
    protected final List<Widget> children = new ArrayList<>();
    private Widget? parent = null;
    private bool visible = true;
    private int grow = 0;

    public int x() { return x; }
    public int y() { return y; }
    public int w() { return w; }
    public int h() { return h; }
    public bool visible() { return visible; }
    public int growWeight() { return grow; }
    public Widget? parent() { return parent; }
    public List<Widget> children() { return children; }

    public void setBounds(int x, int y, int w, int h) { this.x = x; this.y = y; this.w = w; this.h = h; }
    public Widget grow(int weight) { grow = weight; return this; }       // share of a Box's free space; chains
    public void setVisible(bool v) { visible = v; relayout(); }

    public void add(Widget child) {            // asks for a new layout, like remove() and removeAll()
        child.parent = this;
        children.add(child);
        relayout();
    }

    public void remove(Widget child) {
        for (int i = 0; i < children.size(); i++)
            if (children.get(i) == child) { children.remove(i); child.parent = null; relayout(); return; }
    }

    public void removeAll() {
        while (children.size() > 0) children.removeLast().parent = null;
        relayout();
    }

    public abstract int prefW();
    public abstract int prefH();

    /// Places the children inside this widget's bounds.
    public void layout() { }

    /// paint() draws this widget alone, the children follow, then paintOver(). clipsChildren() cuts the children
    /// off at this widget's bounds (scrolling containers).
    public void paint(Canvas c) { }
    public void paintOver(Canvas c) { }
    public bool clipsChildren() { return false; }

    public void paintTree(Canvas c) {
        if (!visible || !c.visible(x, y, w, h)) return;
        paint(&c);
        if (clipsChildren()) c.clip().push(x, y, w, h);
        for (Widget k : children) k.paintTree(&c);
        paintOver(&c);
        if (clipsChildren()) c.clip().pop();
    }

    /// The deepest visible widget at the point, null when it is outside this one.
    public Widget? hit(int px, int py) {
        if (!visible || px < x || py < y || px >= x + w || py >= y + h) return null;
        for (int i = children.size() - 1; i >= 0; i--) {
            Widget? k = children.get(i).hit(px, py);
            if (k != null) return k;
        }
        return this;
    }

    public Root? root() {
        Widget? p = parent;
        if (p != null) return p.root();
        if (this instanceof Root r) return r;
        return null;
    }

    /// Asks for this widget to be repainted (a little margin for focus rings).
    public void invalidate() { damage(x - 3, y - 3, w + 6, h + 6); }

    public void damage(int dx, int dy, int dw, int dh) {
        Widget? p = parent;
        if (p != null) p.damage(dx, dy, dw, dh);
    }

    /// Asks the window to lay the whole tree out again (a child was added, removed or changed size).
    public void relayout() {
        Widget? p = parent;
        if (p != null) p.relayout();
    }
}
