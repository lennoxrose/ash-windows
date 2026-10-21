package ash_windows.ui;

import ash.util.List;

/// Popup menus: a list of choices that opens at a point and closes on a pick, Escape or an outside click.
public final class Menu {
    private Menu() { }

    /// Opens a menu with its top-left corner at (x, y), at least minW wide. `pick` gets the chosen row.
    public static void popup(Root root, int x, int y, int minW, List<String> items, Consumer<Integer> pick) {
        ListView rows = new ListView(i -> { root.setOverlay(null); pick.accept(i); }).menu();
        for (String s : items) rows.addItem(s);
        Box card = Box.column().padding(4).card();
        card.add(new MinWidth(minW, rows));
        Overlay.popup(root, card, x, y);
    }
}
