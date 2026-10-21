package ash_windows.ui;

import ash.util.ArrayList;
import ash.util.List;

/// Which Control has the keyboard focus, and the Tab order.
public final class Focus {
    private Control? current = null;

    public void set(Control? next) {
        Control? before = current;
        if (before != null) before.setFocused(false);
        if (next != null) next.setFocused(true);
        current = next;
    }

    public bool key(int keysym, int state) {
        Control? f = current;
        return f != null && f.onKey(keysym, state);
    }

    public bool wantsTick() {
        Control? f = current;
        return f != null && f.wantsTick();
    }

    public void tick(int nowMs) {
        Control? f = current;
        if (f != null) f.tick(nowMs);
    }

    /// Moves the focus to the next (dir 1) or previous (dir -1) focusable control under `top`, wrapping around.
    public void step(Widget top, int dir) {
        List<Control> order = new ArrayList<>();
        List<Widget> stack = new ArrayList<>();
        stack.add(top);
        while (stack.size() > 0) {
            Widget k = stack.removeLast();
            if (!k.visible()) continue;
            if (k instanceof Control c && c.focusable()) order.add(c);
            List<Widget> kids = k.children();
            for (int i = kids.size() - 1; i >= 0; i--) stack.add(kids.get(i));
        }
        if (order.size() == 0) return;
        int at = dir > 0 ? -1 : 0;
        for (int i = 0; i < order.size(); i++) if (order.get(i) == current) at = i;
        set(order.get((at + dir + order.size()) % order.size()));
    }
}
