package tests;

import ash_windows.gfx.Image;
import ash_windows.sys.Raw;
import ash_windows.ui.Edges;
import ash_windows.x11.Cursors;
import ash_windows.x11.WindowShape;
import ash_windows.x11.WindowShapes;

/// Window outlines and edge hit-testing: no window needed. Prints "ok" or the failures.
public class FrameTest {
    private static int failures = 0;

    private static void check(String what, bool ok) {
        if (ok) return;
        failures++;
        System.out.println("FAIL " + what);
    }

    public static void main(String[] args) {
        WindowShape round = WindowShapes.rounded(20);
        check("rounded: the centre is in", round.contains(100, 50, 200, 100));
        check("rounded: the middle of an edge is in", round.contains(100, 0, 200, 100) && round.contains(0, 50, 200, 100));
        check("rounded: the corner pixel is out", !round.contains(0, 0, 200, 100) && !round.contains(199, 99, 200, 100));
        check("rounded: just inside the curve is in", round.contains(6, 6, 200, 100));

        WindowShape oval = WindowShapes.ellipse();
        check("ellipse: the centre is in, the corners are out", oval.contains(100, 100, 200, 200) && !oval.contains(0, 0, 200, 200));
        check("ellipse: the middle of each side is in", oval.contains(100, 0, 200, 200) && oval.contains(0, 100, 200, 200));

        int px = Raw.alloc(16);                   // a 2 x 2 picture: opaque, clear / clear, opaque
        Raw.poke(px, 4, 0xff112233);
        Raw.poke(px + 4, 4, 0x00112233);
        Raw.poke(px + 8, 4, 0x00112233);
        Raw.poke(px + 12, 4, 0xff112233);
        WindowShape fromPicture = WindowShapes.fromImage(new Image(px, 2, 2));
        check("fromImage: follows the alpha, stretched over the window", fromPicture.contains(1, 1, 10, 10) && !fromPicture.contains(8, 1, 10, 10) && fromPicture.contains(8, 8, 10, 10));

        check("edges: the middle is no edge", Edges.at(100, 50, 200, 100, 6) == 0);
        check("edges: a corner is two edges", Edges.at(2, 2, 200, 100, 6) == (Edges.LEFT | Edges.TOP));
        check("edges: right and bottom", Edges.at(197, 50, 200, 100, 6) == Edges.RIGHT && Edges.at(100, 97, 200, 100, 6) == Edges.BOTTOM);
        check("edges: cursors", Edges.cursor(Edges.LEFT | Edges.TOP) == Cursors.TOP_LEFT && Edges.cursor(Edges.RIGHT) == Cursors.RIGHT && Edges.cursor(Edges.BOTTOM) == Cursors.BOTTOM);
        System.out.println(failures == 0 ? "ok" : failures + " failure(s)");
    }
}
