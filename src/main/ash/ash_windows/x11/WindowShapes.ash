package ash_windows.x11;

import ash_windows.gfx.Image;

/// Ready-made WindowShapes. Any lambda `(x, y, w, h) -> ...` is one as well.
public final class WindowShapes {
    private WindowShapes() { }

    /// A rectangle with rounded corners of the given radius.
    public static WindowShape rounded(int radius) {
        return (x, y, w, h) -> {
            double dx = Math.max(0.0, Math.max(radius - x - 0.5, x + 0.5 - (w - radius)));
            double dy = Math.max(0.0, Math.max(radius - y - 0.5, y + 0.5 - (h - radius)));
            return dx * dx + dy * dy <= radius * radius;
        };
    }

    /// The ellipse that fills the window (a circle when it is square).
    public static WindowShape ellipse() {
        return (x, y, w, h) -> {
            double dx = (x + 0.5 - w / 2.0) / (w / 2.0);
            double dy = (y + 0.5 - h / 2.0) / (h / 2.0);
            return dx * dx + dy * dy <= 1.0;
        };
    }

    /// Whatever is opaque in a picture (alpha of at least half), stretched over the window.
    public static WindowShape fromImage(Image image) {
        return (x, y, w, h) -> (image.pixel(x * image.width() / w, y * image.height() / h) >> 24 & 255) >= 128;
    }
}
