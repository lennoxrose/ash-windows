package ash_windows.ui;

/// Ready-made modal dialogs. Each lines the message up one label per line (\n separates lines).
public final class Dialogs {
    private Dialogs() { }

    /// A message with an OK button.
    public static void message(Root root, String title, String text) {
        Box card = body(title, text);
        Box buttons = Box.row().gap(10);
        buttons.add(new Spacer().grow(1));
        buttons.add(new Button("OK", () -> root.setOverlay(null)).primary());
        card.add(buttons);
        Overlay.dialog(root, card, () -> { });
    }

    /// A question with Cancel and an OK button (labelled `ok`) that runs `onOk`. Return confirms, Escape cancels.
    public static void confirm(Root root, String title, String text, String ok, Runnable onOk) {
        Box card = body(title, text);
        Box buttons = Box.row().gap(10);
        buttons.add(new Spacer().grow(1));
        buttons.add(new Button("Cancel", () -> root.setOverlay(null)));
        buttons.add(new Button(ok, () -> { root.setOverlay(null); onOk.run(); }).primary());
        card.add(buttons);
        Overlay.dialog(root, card, onOk);
    }

    private static Box body(String title, String text) {
        Box card = Box.column().padding(20).gap(12).card();
        card.add(new Label(title).bold());
        for (String line : text.split("\n")) card.add(new Label(line).dim());
        return card;
    }
}
