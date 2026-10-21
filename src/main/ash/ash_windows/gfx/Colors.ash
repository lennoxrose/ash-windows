package ash_windows.gfx;

/// Colour arithmetic on 0xRRGGBB values.
public final class Colors {
    private Colors() { }

    /// `a` moved towards `b` by t/255.
    public static int mix(int a, int b, int t) {
        int r = ((a >> 16 & 255) * (255 - t) + (b >> 16 & 255) * t + 127) / 255;
        int g = ((a >> 8 & 255) * (255 - t) + (b >> 8 & 255) * t + 127) / 255;
        int bl = ((a & 255) * (255 - t) + (b & 255) * t + 127) / 255;
        return r << 16 | g << 8 | bl;
    }
}
