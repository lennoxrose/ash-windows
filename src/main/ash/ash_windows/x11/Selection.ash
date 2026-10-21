package ash_windows.x11;

import ash_windows.sys.Raw;

/// The wire-level halves of the clipboard protocol: answering a request for our text, and fetching someone
/// else's.
public final class Selection {
    private Selection() { }

    /// Answers the SelectionRequest event that is in the wire buffer: the TARGETS list, or `text`.
    public static void answer(Wire wire, String text, int targets, int utf8) {
        int time = wire.u32(4);
        int requestor = wire.u32(12);
        int selection = wire.u32(16);
        int target = wire.u32(20);
        int property = wire.u32(24);
        if (target == targets) {
            wire.send(18, 0, 9);                  // ChangeProperty: TARGETS = [TARGETS, UTF8_STRING, STRING]
            header(wire, requestor, property, 4, 32, 3);
            wire.p32(24, targets);
            wire.p32(28, utf8);
            wire.p32(32, 31);
            wire.flush(36);
        } else if (target == utf8 || target == 31) {
            int words = 6 + (text.length() + 3) / 4;
            wire.send(18, 0, words);
            header(wire, requestor, property, target, 8, text.length());
            for (int i = 0; i < words * 4 - 24; i++) wire.p8(24 + i, i < text.length() ? (int) text.charAt(i) : 0);
            wire.flush(words * 4);
        } else property = 0;                      // a format we cannot give
        wire.send(25, 0, 11);                     // SendEvent: SelectionNotify to the requestor
        wire.p32(4, requestor);
        wire.p32(8, 0);
        for (int i = 12; i < 44; i++) wire.p8(i, 0);
        wire.p8(12, 31);
        wire.p32(16, time);
        wire.p32(20, requestor);
        wire.p32(24, selection);
        wire.p32(28, target);
        wire.p32(32, property);
        wire.flush(44);
    }

    /// GetProperty (deleting it) and its bytes as a String; at most `max` bytes.
    public static String? fetch(Wire wire, int window, int prop, int max) {
        wire.send(20, 1, 6);
        wire.p32(4, window);
        wire.p32(8, prop);
        wire.p32(12, 0);
        wire.p32(16, 0);
        wire.p32(20, max / 4);
        wire.flush(24);
        if (!wire.readFull(32) || wire.u8(0) != 1) return null;
        int n = wire.u32(16);
        if (n > max || !wire.readFullAt(32, wire.u32(4) * 4)) return null;
        String s = "";
        for (int at = 0; at < n; at = at + 128) {
            String chunk = "";
            for (int i = at; i < Math.min(n, at + 128); i++) chunk = chunk + Raw.chr(wire.u8(32 + i));
            s = s + chunk;
        }
        return s;
    }

    private static void header(Wire wire, int requestor, int property, int type, int format, int count) {
        wire.p32(4, requestor);
        wire.p32(8, property);
        wire.p32(12, type);
        wire.p8(16, format);
        wire.p32(20, count);
    }
}
