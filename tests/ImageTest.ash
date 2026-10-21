package tests;

import ash_windows.gfx.Bmp;
import ash_windows.gfx.Image;
import ash_windows.gfx.Png;

/// Loads the files in tests/fixtures (run from the project root) and compares pixels with values worked out
/// independently. Prints "ok" or the failures.
public class ImageTest {
    private static int failures = 0;

    private static void check(String what, bool ok) {
        if (ok) return;
        failures++;
        System.out.println("FAIL " + what);
    }

    private static void pixel(String what, Image? im, int x, int y, long argb) {
        check(what, im != null && im.width() == 40 && im.height() == 30 && im.pixel(x, y) == argb);
    }

    public static void main(String[] args) {
        String d = "tests/fixtures/";
        pixel("rgba png (every filter type, split IDAT)", Png.load(d + "rgba.png"), 7, 3, 3693746197L);
        pixel("rgb png", Png.load(d + "rgb.png"), 39, 29, 4293531596L);
        pixel("grey png", Png.load(d + "gray.png"), 12, 17, 4285493103L);
        pixel("grey+alpha png", Png.load(d + "graya.png"), 0, 0, 3355443200L);
        pixel("palette png", Png.load(d + "pal.png"), 7, 3, 4288700274L);
        pixel("24-bit bmp, bottom-up", Bmp.load(d + "b24.bmp"), 39, 29, 4282706154L);
        pixel("32-bit bmp, top-down", Bmp.load(d + "b32.bmp"), 12, 17, 3189606472L);
        check("missing file", Png.load(d + "nope.png") == null);
        check("a bmp is not a png", Png.load(d + "b24.bmp") == null);
        check("a png is not a bmp", Bmp.load(d + "rgb.png") == null);
        System.out.println(failures == 0 ? "ok" : failures + " failure(s)");
    }
}
