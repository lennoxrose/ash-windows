package ash_windows.x11;

import ash_windows.sys.Raw;

/// What the connection needs from the environment: the display number and the MIT-MAGIC-COOKIE-1.
public final class Auth {
    private Auth() { }

    /// The value of NAME= in this process's environment, or null.
    public static String? env(String key) {
        int sizeOut = Raw.alloc(8);
        int data = Raw.readFile("/proc/self/environ", sizeOut);
        int len = Raw.peek(sizeOut, 8);
        Raw.free(sizeOut);
        if (data == 0) return null;
        String? found = null;
        int at = 0;
        while (found == null && at < len) {
            int end = at;
            while (end < len && Raw.peek(data + end, 1) != 0) end++;
            bool match = end - at >= key.length();
            for (int i = 0; match && i < key.length(); i++) match = Raw.peek(data + at + i, 1) == Raw.charAt(key, i);
            if (match) {
                String v = "";
                for (int i = at + key.length(); i < end; i++) v = v + Raw.chr(Raw.peek(data + i, 1));
                found = v;
            }
            at = end + 1;
        }
        Raw.free(data);
        return found;
    }

    /// The n of $DISPLAY=":n" or ":n.s"; 0 when unset or not of that form.
    public static int display() {
        String? d = env("DISPLAY=");
        if (d == null || d.length() < 2 || Raw.charAt(d, 0) != 58) return 0;
        int n = 0;
        for (int i = 1; i < d.length(); i++) {
            int c = Raw.charAt(d, i);
            if (c < 48 || c > 57) break;
            n = n * 10 + c - 48;
        }
        return n;
    }

    /// Copies a MIT-MAGIC-COOKIE-1 from $XAUTHORITY or $HOME/.Xauthority to out (64 bytes) and returns its
    /// length; 0 when there is none (the server may still accept us without one).
    public static int cookie(int out) {
        String? path = env("XAUTHORITY=");
        if (path == null) {
            String? home = env("HOME=");
            if (home == null) return 0;
            path = home + "/.Xauthority";
        }
        int sizeOut = Raw.alloc(8);
        int data = Raw.readFile(path, sizeOut);
        int len = Raw.peek(sizeOut, 8);
        Raw.free(sizeOut);
        int result = 0;
        int at = 0;
        while (data != 0 && result == 0 && at + 4 <= len) {   // entries: family, address, number, name, data
            int numAt = at + 4 + be16(data, at + 2);
            int nameAt = numAt + 2 + be16(data, numAt);
            int nameLen = be16(data, nameAt);
            int dataAt = nameAt + 2 + nameLen;
            int dataLen = be16(data, dataAt);
            if (dataAt + 2 + dataLen > len) break;
            if (nameLen == 18 && dataLen <= 64) {
                for (int i = 0; i < dataLen; i++) Raw.poke(out + i, 1, Raw.peek(data + dataAt + 2 + i, 1));
                result = dataLen;
            }
            at = dataAt + 2 + dataLen;
        }
        if (data != 0) Raw.free(data);
        return result;
    }

    private static int be16(int data, int off) { return Raw.peek(data + off, 1) * 256 + Raw.peek(data + off + 1, 1); }
}
