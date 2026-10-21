package ash_windows.gfx;

/// Finds a UI font among the ones Linux desktops usually ship.
public final class Fonts {
    private Fonts() { }

    public static Font? regular(int size) {
        return find(size, "/usr/share/fonts/noto/NotoSans-Regular.ttf", "/usr/share/fonts/TTF/DejaVuSans.ttf",
                "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/dejavu/DejaVuSans.ttf",
                "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf", "/usr/share/fonts/liberation/LiberationSans-Regular.ttf");
    }

    public static Font? bold(int size) {
        return find(size, "/usr/share/fonts/noto/NotoSans-Bold.ttf", "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
                "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
                "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf", "/usr/share/fonts/liberation/LiberationSans-Bold.ttf");
    }

    private static Font? find(int size, String a, String b, String c, String d, String e, String f) {
        String[] paths = {a, b, c, d, e, f};
        for (String p : paths) {
            Font? font = Font.load(p, size);
            if (font != null) return font;
        }
        return null;
    }
}
