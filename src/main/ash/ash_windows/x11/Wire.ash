package ash_windows.x11;

import ash_windows.sys.Raw;

/// The socket to the X server and the one scratch buffer in which requests are built (then written in a
/// single syscall) and replies and events are read.
public final class Wire {
    public static final int SIZE = 65536;
    private static final int SCRATCH = SIZE - 64;       // 64 bytes at the end for poll / clock

    private int fd = -1;
    private int buf = 0;

    public Wire() { buf = Raw.alloc(SIZE); }

    public void p8(int off, int v) { Raw.poke(buf + off, 1, v); }
    public void p16(int off, int v) { Raw.poke(buf + off, 2, v); }
    public void p32(int off, int v) { Raw.poke(buf + off, 4, v); }
    public int u8(int off) { return Raw.peek(buf + off, 1); }
    public int u16(int off) { return Raw.peek(buf + off, 2); }
    public int i16(int off) { int v = u16(off); return v >= 32768 ? v - 65536 : v; }
    public int u32(int off) { return Raw.peek(buf + off, 4); }
    public bool isOpen() { return fd >= 0; }

    /// Request header: opcode, one data byte, length in 4-byte words.
    public void send(int opcode, int data, int words) {
        p8(0, opcode);
        p8(1, data);
        p16(2, words);
    }

    /// Writes the first `bytes` bytes of the buffer.
    public void flush(int bytes) { writeAll(buf, bytes); }

    public bool connect(String path) {
        fd = Raw.sys(41, 1, 1, 0, 0);             // socket(AF_UNIX, SOCK_STREAM)
        if (fd < 0) return false;
        for (int i = 0; i < 110; i++) p8(i, 0);
        p16(0, 1);                                // sockaddr_un.sun_family = AF_UNIX
        for (int i = 0; i < path.length(); i++) p8(2 + i, Raw.charAt(path, i));
        return Raw.sys(42, fd, buf, 110, 0) == 0;
    }

    public void close() {
        if (fd >= 0) Raw.sys(3, fd, 0, 0, 0);
        fd = -1;
        if (buf != 0) Raw.free(buf);
        buf = 0;
    }

    /// Milliseconds on a monotonic clock.
    public int nowMs() { return Raw.nowMs(buf + SCRATCH); }

    /// poll(fd, POLLIN) for up to ms milliseconds; true when a read would not block.
    public bool readable(int ms) {
        int p = buf + SCRATCH + 16;
        Raw.poke(p, 4, fd);
        Raw.poke(p + 4, 2, 1);
        Raw.poke(p + 6, 2, 0);
        return Raw.sys(7, p, 1, ms, 0) > 0;
    }

    public void writeAll(int p, int n) {
        int done = 0;
        while (done < n) {
            int w = Raw.sys(1, fd, p + done, n - done, 0);
            if (w <= 0) return;
            done = done + w;
        }
    }

    public bool readFull(int n) { return readFullAt(0, n); }

    public bool readFullAt(int off, int n) { return readInto(buf + off, n); }

    public bool readInto(int p, int n) {
        int got = 0;
        while (got < n) {
            int r = Raw.sys(0, fd, p + got, n - got, 0);
            if (r <= 0) return false;
            got = got + r;
        }
        return true;
    }
}
