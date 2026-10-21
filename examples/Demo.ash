package examples;

import ash_windows.ui.*;

/// A small settings-style window that uses every widget. Run on the nested server:
///   Xephyr :9 -screen 800x600 &   then   DISPLAY=:9 ashvm run examples/Demo.ash
public class Demo {
    private final Label status = new Label("Nothing yet").dim();
    private final Progress bar = new Progress(0.4);
    private int clicks = 0;

    private Box build() {
        Box form = Box.column().padding(20).gap(14).card();
        form.add(new Label("Ash windows").title());
        form.add(new Label("Pure Ash on X11: no native library, no toolkit.").dim());
        form.add(new Separator());
        form.add(new TextField("Your name", s -> status.setText("Hello, " + s), s -> status.setText("Submitted " + s)));
        form.add(new Checkbox("Enable notifications", true, on -> status.setText(on ? "Notifications on" : "Notifications off")));
        form.add(new Slider(0.4, v -> bar.setValue(v)));
        form.add(bar);
        Box buttons = Box.row().gap(10);
        buttons.add(new Spacer().grow(1));
        buttons.add(new Button("Click me", () -> status.setText("Clicked " + (++clicks) + " times")));
        buttons.add(new Button("Save", () -> status.setText("Saved")).primary());
        form.add(buttons);
        form.add(status);
        return form;
    }

    public static void main(String[] args) {
        Theme? theme = Theme.create(true);
        if (theme == null) { System.out.println("no TrueType font found"); return; }
        Theme.set(theme);
        App? app = App.open("Ash windows", 460, 440);
        if (app == null) { System.out.println("no X server (set DISPLAY)"); return; }
        Root root = app.root();
        root.padding(20);
        root.add(new Demo().build().grow(1));
        app.run();
    }
}
