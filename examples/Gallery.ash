package examples;

import ash.util.ArrayList;
import ash.util.List;
import ash_windows.ui.*;

/// Menus, a list, a scrolling pane, a dropdown and dialogs in one window.
///   Xephyr :9 -screen 800x600 &   then   DISPLAY=:9 ashvm run examples/Gallery.ash
public class Gallery {
    private final Label status = new Label("Pick something").dim();
    private Root root;

    private Gallery(Root root) { this.root = root; }

    private Box build() {
        Box page = Box.column().gap(10);
        MenuBar bar = new MenuBar();
        List<String> file = new ArrayList<>();
        file.add("New");
        file.add("Open...");
        file.add("Quit");
        bar.addMenu("File", file, i -> pickFile(i));
        List<String> help = new ArrayList<>();
        help.add("About");
        bar.addMenu("Help", help, i -> Dialogs.message(root, "About", "ash-windows\nPure Ash, on X11"));
        page.add(bar);
        Box middle = Box.row().gap(12).padding(12);
        ListView list = new ListView(i -> status.setText("Row " + i));
        for (int i = 0; i < 30; i++) list.addItem("Item number " + i);
        middle.add(list.grow(1));
        Box lines = Box.column().gap(6);
        for (int i = 0; i < 40; i++) lines.add(new Label("Scrolling line " + i).dim());
        ScrollView scroll = new ScrollView();
        scroll.add(lines);
        middle.add(scroll.grow(1));
        page.add(middle.grow(1));
        Box foot = Box.row().gap(12).padding(12);
        List<String> sizes = new ArrayList<>();
        sizes.add("Small");
        sizes.add("Medium");
        sizes.add("Large");
        foot.add(new Select(sizes, 1, i -> status.setText("Size " + i)));
        foot.add(status);
        page.add(foot);
        return page;
    }

    private void pickFile(int i) {
        if (i == 2) Dialogs.confirm(root, "Quit?", "Unsaved work is lost.", "Quit", () -> System.exit(0));
        else status.setText(i == 0 ? "New file" : "Open file");
    }

    public static void main(String[] args) {
        Theme? theme = Theme.create(true);
        if (theme == null) { System.out.println("no TrueType font found"); return; }
        Theme.set(theme);
        App? app = App.open("Gallery", 640, 480);
        if (app == null) { System.out.println("no X server (set DISPLAY)"); return; }
        app.root().add(new Gallery(app.root()).build().grow(1));
        app.run();
    }
}
