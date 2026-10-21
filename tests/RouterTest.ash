package tests;

import ash_windows.ui.*;
import ash_windows.x11.Keys;

/// Drives widgets through the Router the way App does, without a window. Prints "ok" or the failures.
/// Needs a TrueType font (the theme measures text), not an X server.
public class RouterTest {
    private static int clicks = 0;
    private static String typed = "";
    private static double slid = -1;
    private static bool box = false;
    private static int failures = 0;

    private static void check(String what, bool ok) {
        if (ok) return;
        failures++;
        System.out.println("FAIL " + what);
    }

    public static void main(String[] args) {
        Theme? theme = Theme.create(true);
        if (theme == null) { System.out.println("no TrueType font found"); return; }
        Theme.set(theme);
        Root root = new Root();
        root.add(new Button("Go", () -> clicks++));                       // y 0..36
        root.add(new TextField("name", s -> typed = s, s -> typed = "!" + s));   // y 36..72
        root.add(new Slider(0.0, v -> slid = v));                         // y 72..96
        root.add(new Checkbox("on", false, b -> box = b));                // y 96..124
        root.setBounds(0, 0, 300, 200);
        root.layout();
        Router r = new Router(root);

        r.press(10, 10);
        r.release(10, 10);
        check("click runs the action", clicks == 1);
        r.press(10, 10);
        r.release(10, 150);
        check("release outside does not click", clicks == 1);

        r.key(Keys.RETURN, 0);
        check("return activates the focused button", clicks == 2);
        Router fresh = new Router(root);
        fresh.key(Keys.TAB, 0);
        fresh.key(Keys.RETURN, 0);
        check("tab focuses the first widget", clicks == 3);

        r.press(20, 50);
        r.release(20, 50);
        r.key(97, 0);
        r.key(98, 0);
        check("typing", typed == "ab");
        r.key(Keys.BACKSPACE, 0);
        check("backspace", typed == "a");
        r.key(233, 0);
        check("latin-1 is stored as utf-8", typed.length() == 3);
        r.key(Keys.BACKSPACE, 0);
        check("backspace removes a whole character", typed == "a");
        r.key(Keys.RETURN, 0);
        check("return submits", typed == "!a");

        r.press(150, 84);
        r.move(60, 84);
        r.release(60, 84);
        check("slider drag follows the pointer", slid > 0.15 && slid < 0.25);

        r.press(5, 110);
        r.release(5, 110);
        check("checkbox toggles", box);
        r.key(32, 0);
        check("space toggles the focused checkbox", !box);

        System.out.println(failures == 0 ? "ok" : failures + " failure(s)");
    }
}
