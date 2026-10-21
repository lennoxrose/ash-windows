package ash_windows.gfx;

/// One rasterised glyph: an 8-bit coverage mask of w x h bytes, the offset of its top-left corner from the pen
/// position on the baseline (top is negative above the baseline), the pen's advance in pixels, and its glyph index.
public record Glyph(int mask, int w, int h, int left, int top, double advance, int gid) { }
