package ash_windows.x11;

/// The outline of a window: which of its pixels belong to it. The rest is cut away (the server stops drawing
/// there and clicks fall through). Edges are hard, one pixel in or out: there is no anti-aliasing.
public interface WindowShape {
    /// Whether pixel (x, y) of a w x h window is part of it.
    bool contains(int x, int y, int w, int h);
}
