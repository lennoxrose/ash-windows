package ash_windows.ui;

import ash_windows.gfx.Utf8;

/// The text of a single-line input with its cursor and selection (anchor to cursor): all positions are byte
/// indexes that sit on character boundaries.
public final class TextEdit {
    private String text = "";
    private int cursor = 0;
    private int anchor = 0;

    public String text() { return text; }
    public int cursor() { return cursor; }
    public bool hasSelection() { return cursor != anchor; }
    public int selStart() { return Math.min(cursor, anchor); }
    public int selEnd() { return Math.max(cursor, anchor); }
    public String selected() { return text.substring(selStart(), selEnd()); }
    public String before(int at) { return text.substring(0, at); }
    public void selectAll() { anchor = 0; cursor = text.length(); }

    public void set(String s) {
        cursor = s.length();
        anchor = cursor;
        text = s;
    }

    /// Moves the cursor (keeping the anchor when `extend`, which grows the selection).
    public void moveTo(int at, bool extend) {
        cursor = Math.max(0, Math.min(text.length(), at));
        if (!extend) anchor = cursor;
    }

    public void left(bool extend) {
        if (hasSelection() && !extend) moveTo(selStart(), false);
        else moveTo(Utf8.previous(text, cursor), extend);
    }

    public void right(bool extend) {
        if (hasSelection() && !extend) moveTo(selEnd(), false);
        else if (cursor < text.length()) moveTo(cursor + Utf8.length(text, cursor), extend);
    }

    /// Replaces the selection (or inserts at the cursor) and puts the cursor after the new text.
    public void insert(String s) {
        int start = selStart();
        text = text.substring(0, start) + s + text.substring(selEnd());
        cursor = start + s.length();
        anchor = cursor;
    }

    public void backspace() {
        if (!hasSelection() && cursor > 0) anchor = Utf8.previous(text, cursor);
        insert("");
    }

    public void delete() {
        if (!hasSelection() && cursor < text.length()) anchor = cursor + Utf8.length(text, cursor);
        insert("");
    }

    /// The character boundary nearest to the pixel offset `px` from the start of the text.
    public int indexAt(int px) {
        int at = 0;
        while (at < text.length()) {
            int next = at + Utf8.length(text, at);
            int mid = (Theme.get().text.measure(text.substring(0, at)) + Theme.get().text.measure(text.substring(0, next))) / 2;
            if (px < mid) break;
            at = next;
        }
        return at;
    }
}
