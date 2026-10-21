package ash_windows.ui;

/// Ctrl+A (select all), C (copy), X (cut) and V (paste) on a TextEdit, through the window's clipboard.
public final class TextShortcuts {
    private TextShortcuts() { }

    /// 0: not one of these keys, 1: handled, 2: handled and the text changed.
    public static int run(TextEdit ed, Chrome? chrome, int keysym) {
        if (keysym == 97) { ed.selectAll(); return 1; }
        if (chrome == null) return 0;
        if (keysym == 99 || keysym == 120) {
            if (ed.hasSelection()) chrome.copy(ed.selected());
            if (keysym == 99 || !ed.hasSelection()) return 1;
            ed.insert("");
            return 2;
        }
        if (keysym != 118) return 0;
        String? clip = chrome.paste();
        if (clip == null) return 1;
        ed.insert(clip.replace("\n", " "));
        return 2;
    }
}
