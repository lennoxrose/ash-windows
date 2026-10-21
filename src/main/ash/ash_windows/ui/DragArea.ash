package ash_windows.ui;

/// An invisible handle: pressing it and dragging moves the whole window. Put it where a title bar would be, or
/// make it the whole window (give it a grow weight) for a shaped window that is dragged by its body.
public final class DragArea extends Control {
    public int prefW() { return 0; }
    public int prefH() { return 0; }

    public void onPress(int px, int py) {
        Chrome? c = chrome();
        if (c != null) c.beginMove();
    }
}
