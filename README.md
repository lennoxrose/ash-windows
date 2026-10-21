# ash-windows

Windows and a widget toolkit for Ash, on X11, written in Ash itself: it speaks the X protocol over a unix
socket with the `raw_*` builtins, draws into a software framebuffer (anti-aliased shapes, TrueType text) and
uploads it with `PutImage`. No native library, no C. Linux + a running X server (Xorg, Xwayland, Xephyr).

```sh
apm add github:lennoxrose/ash-windows
```

```ash
import ash_windows.ui.*;

public class Hello {
    public static void main(String[] args) {
        Theme? theme = Theme.create(true);              // true: dark, false: light; null: no TrueType font
        if (theme == null) return;
        Theme.set(theme);
        App? app = App.open("Hello", 360, 200);         // opens on $DISPLAY; null: no X server
        if (app == null) return;
        app.root().padding(20);
        Box col = Box.column().gap(12);
        col.add(new Label("Hello from Ash").title());
        col.add(new Button("Quit", () -> System.exit(0)).primary());
        app.root().add(col);
        app.run();
    }
}
```

## Layers (each file under 100 lines)

| Package | What |
| --- | --- |
| `ash_windows.x11` | `X11`: one window, `putImage`, `waitEvent(timeout)`, keyboard translation, clipboard (`copy` / `paste`). Its parts: `Wire`, `Setup`, `Auth`, `Keyboard`, `Props`, `Windows`, `Clipboard`, `Selection`; `Events` and `Keys` hold constants |
| `ash_windows.gfx` | `Canvas` (framebuffer + clip), `Shapes` (round rects, circles, lines, shadows, gradients), `Font` (TrueType loader and rasteriser with GPOS kerning; `Fonts` finds a system one), `Image` with `Png` and `Bmp` loaders (own DEFLATE in `Inflate`) |
| `ash_windows.ui` | `App` (window + event loop), `Root`, `Router`, `Focus`, `Theme`, and the widgets below |

Widgets: `Box` (row / column / card), `Label`, `Button`, `Checkbox`, `Slider`, `Progress`, `TextField` (selection,
Ctrl+A/C/X/V), `Select` (dropdown), `ListView`, `ScrollView` (wheel + draggable thumb), `ImageView`, `MenuBar`,
`Separator`, `Spacer`. `Menu.popup(...)` opens a context menu anywhere; `Dialogs.message` / `Dialogs.confirm` and
`Overlay` give modal dialogs. Widgets that react to input extend `Control`; the rest extend `Widget`.

## Window frames and shapes

By default the window manager draws the frame (title bar, border, buttons) and decides how it looks. To own it:

```ash
App? app = App.openBorderless("My app", 520, 360);   // asks the window manager to draw no frame at all
app.setShape(WindowShapes.rounded(14));              // cut the window to any outline
app.setResizeBorder(6);                              // resize by dragging within 6 px of the edges
app.root().add(new TitleBar("My app", true));        // or build your own frame from widgets
```

- `TitleBar(title, buttonsLeft)`: title, close / minimise / maximize buttons (round on the left, flat on the right),
  drag to move, double-click to maximize. `DragArea` is an invisible move handle; any widget can drive the window
  through `chrome()`: `close()`, `minimize()`, `toggleMaximize()`, `beginMove()`, `beginResize(edges)`, `setCursor(...)`.
- `WindowShape` is `(x, y, w, h) -> bool`: which pixels belong to the window. `WindowShapes.rounded(r)`, `.ellipse()`,
  `.fromImage(image)` (whatever is opaque), or your own lambda. The outline is recomputed when the window is resized.
  It is cut with the X Shape extension: edges are hard (one pixel in or out, no anti-aliasing), the cut-away parts
  are not drawn and clicks fall through them. `Orb.ash` is a circular window dragged by its body.
- `examples/Frameless.ash`: rounded corners, own title bar, resizable from its edges.
- Every window sets a cursor (the arrow; I-beam over text fields, a hand over buttons, resize arrows at the edges):
  under Xwayland a window with no cursor makes the pointer vanish.

Only the damaged rectangles are repainted and uploaded. A widget that changes calls `invalidate()` (the built-in
ones do); one that changes size calls `relayout()`. `add` / `remove` / `removeAll` relayout by themselves.

## Things to know

- **Native is the way to ship**: `kiln app.ash -o app`. `ashvm run app.ash` also works for small programs, but
  the bytecode VM stops a bigger one with `this function has more than 256 different constants` (examples/Gallery
  is over that line, examples/Demo is not).
- **Keep widgets you need later in fields**, not locals: with `memory-safety: on`, a local is moved into the tree
  by `add(...)` and cannot be used afterwards (`status.setText(...)` from a callback is fine on a field).
- Test on a nested server so a bug cannot touch your desktop: `Xephyr :9 -screen 800x600 &`, then
  `DISPLAY=:9 ./app`. `$DISPLAY` must be of the form `:n` (or `:n.s`); there is no TCP / `ssh -X` transport.
- Tested on Xephyr (no window manager) and, for window-manager behaviour, on GNOME / mutter under Xwayland (maximize,
  restore, move and resize were checked there; minimise, `_MOTIF_WM_HINTS` handling by other window managers and tiling
  window managers were not), with the US keyboard layout. Keysyms come from the server's own table, so other layouts should work;
  AltGr / dead keys are not handled.
- Clipboard is text only, up to 16 KB, no selection (middle-click) buffer. `Png` reads 8-bit non-interlaced images,
  `Bmp` 24/32-bit uncompressed; `ImageView` scales down, never up.
- Not there: smooth (anti-aliased / translucent) window edges (would need a 32-bit visual and a compositor), a
  native Wayland client, HiDPI scaling, IME / complex-script shaping, text wrapping in labels, tabs / trees / tables.

Tests (run from the project root, native or `ashvm run`): `tests/CoreTest.ash` (DEFLATE, UTF-8, text editing,
damage), `tests/ImageTest.ash` (PNG / BMP against known pixels), `tests/FontTest.ash` (kerning),
`tests/RouterTest.ash` (clicks, Tab, typing, slider through the real input router), `tests/FrameTest.ash` (window
shapes, edge hit-testing). Examples: `examples/Demo.ash`
(basic widgets), `examples/Gallery.ash` (menus, list, scroll, dropdown, dialogs), `examples/Frameless.ash` and `examples/Orb.ash` (own frames and shapes).
