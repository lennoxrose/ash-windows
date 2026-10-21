package tests;

import ash_windows.gfx.Bits;
import ash_windows.gfx.Inflate;
import ash_windows.gfx.Utf8;
import ash_windows.sys.Raw;
import ash_windows.ui.Damage;
import ash_windows.ui.TextEdit;

/// Logic that needs neither a font nor an X server: DEFLATE, UTF-8, text editing and damage merging.
/// Prints "ok" or the failures.
public class CoreTest {
    private static final int[] FIXED = {203, 72, 205, 201, 201, 87, 200, 64, 34, 203, 243, 139, 114, 82, 0};
    private static final int[] DYNAMIC = {221, 203, 193, 17, 128, 32, 16, 67, 209, 86, 82, 129, 61, 129, 130, 174, 2, 11, 8, 34, 84, 239, 142, 61, 120, 241, 152, 249, 47, 101, 51, 72, 149, 230, 3, 58, 115, 11, 176, 124, 99, 175, 62, 158, 224, 203, 100, 20, 201, 78, 141, 142, 133, 215, 233, 93, 191, 198, 81, 137, 243, 29, 90, 80, 163, 178, 193, 210, 101, 36, 13, 19, 224, 40, 85, 206, 242, 93, 207, 47, 224, 3};
    private static int failures = 0;

    private static void check(String what, bool ok) {
        if (ok) return;
        failures++;
        System.out.println("FAIL " + what);
    }

    // Inflates the stream; returns the output size, and leaves the sum of its bytes in sums[0].
    private static int inflate(int[] stream, int[] sums) {
        int in = Raw.alloc(stream.length);
        for (int i = 0; i < stream.length; i++) Raw.poke(in + i, 1, stream[i]);
        int out = Raw.alloc(1024);
        int n = Inflate.run(new Bits(in, stream.length), out, 1024);
        sums[0] = 0;
        for (int i = 0; i < n; i++) sums[0] = sums[0] + Raw.peek(out + i, 1);
        return n;
    }

    public static void main(String[] args) {
        int[] sums = new int[1];
        check("inflate fixed block", inflate(FIXED, sums) == 23 && sums[0] == 2244);
        check("inflate dynamic block", inflate(DYNAMIC, sums) == 393 && sums[0] == 36399);

        String e = Utf8.encode(233);
        check("utf-8 encode", e.length() == 2 && Utf8.decode(e, 0) == 233 && Utf8.length(e, 0) == 2);
        check("utf-8 previous", Utf8.previous("a" + e, 3) == 1);

        TextEdit t = new TextEdit();
        t.insert("ab");
        t.insert(e);
        check("insert", t.text().length() == 4 && t.cursor() == 4);
        t.backspace();
        check("backspace removes a whole character", t.text() == "ab");
        t.left(true);
        t.left(true);
        check("shift+left selects", t.selected() == "ab");
        t.insert("x");
        check("typing replaces the selection", t.text() == "x");
        t.selectAll();
        t.right(false);
        check("right collapses the selection at its end", !t.hasSelection() && t.cursor() == 1);
        t.moveTo(0, false);
        t.delete();
        check("delete", t.text() == "");

        Damage d = new Damage();
        d.add(0, 0, 10, 10);
        d.add(50, 50, 10, 10);
        check("disjoint rectangles stay apart", d.count() == 2);
        d.add(5, 5, 50, 50);
        check("a bridging rectangle merges them", d.count() == 1 && d.w(0) == 60 && d.h(0) == 60);
        d.clear();
        check("clear", d.count() == 0);

        System.out.println(failures == 0 ? "ok" : failures + " failure(s)");
    }
}
