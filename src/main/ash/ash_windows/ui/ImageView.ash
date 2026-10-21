package ash_windows.ui;

import ash_windows.gfx.Canvas;
import ash_windows.gfx.Image;

/// Shows an Image, scaled down to fit its space (never up) and centred.
public final class ImageView extends Widget {
    private final Image image;

    public ImageView(Image image) { this.image = image; }

    public int prefW() { return image.width(); }
    public int prefH() { return image.height(); }

    public void paint(Canvas c) {
        int s = Math.min(1000 * w / image.width(), Math.min(1000 * h / image.height(), 1000));
        int dw = Math.max(1, image.width() * s / 1000);
        int dh = Math.max(1, image.height() * s / 1000);
        image.draw(c, x + (w - dw) / 2, y + (h - dh) / 2, dw, dh);
    }
}
