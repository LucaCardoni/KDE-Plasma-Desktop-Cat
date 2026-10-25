# Desktop Cat

A cute desktop cat plasmoid for KDE Plasma 6. Click it for a speech bubble, feed it, pet it, and watch its needs change over time. Lives in your panel or on your desktop.

![Desktop Cat screenshot](./screenshot.png)

## Features

- Animated cat sprite with idle, walking, running, sleeping, and more animations
- Needs system: hunger, energy, happiness, cleanliness
- Interactions: feed, pet, poke, groom, laser, catnip, sleep/wake
- Fully configurable: pet name, size, animation speed, decay rates, and more
- Can act as a panel spacer to push other widgets to the edges

## Installation

### From KDE Store (recommended)

Search for **"Desktop Cat"** in Plasma's "Add Widgets" dialog or download from [store.kde.org](https://store.kde.org).

### Manual install

```bash
# Clone or download this repo
git clone https://github.com/luca/desktop-cat.git
cd desktop-cat

# Install the plasmoid for your user
plasmapkg2 --install com.luca.desktopcat/
# or, without plasmapkg2:
mkdir -p ~/.local/share/plasma/plasmoids/com.luca.desktopcat
cp -r com.luca.desktopcat/* ~/.local/share/plasma/plasmoids/com.luca.desktopcat/

# Reload Plasma Shell (or log out and back in)
kquitapp5 plasmashell && kstart5 plasmashell
```

Then add "Desktop Cat" from the "Add Widgets" panel menu.

### Uninstall

```bash
plasmapkg2 --remove com.luca.desktopcat
# or manually:
rm -rf ~/.local/share/plasma/plasmoids/com.luca.desktopcat
```

## Configuration

Right-click the cat → **Configure Desktop Cat** to adjust:

- Pet name and size
- Animation speed and idle intervals
- Hunger / energy / happiness decay rates
- Feeding and play amounts
- Wandering and roaming behavior
- Panel spacer mode

## Building the `.plasmoid` package

For KDE Store submission or sharing:

```bash
zip -r desktop-cat.plasmoid com.luca.desktopcat/
```

Upload `desktop-cat.plasmoid` to [store.kde.org](https://store.kde.org).

## Development

No build system required — it's pure QML + JavaScript. Edit files in `com.luca.desktopcat/contents/` and reload the plasmoid to test.

## License

[GPL-3.0](LICENSE)

---

**Note:** Update `metadata.json` with your real email address and project website before publishing.