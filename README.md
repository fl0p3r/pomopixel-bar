# Pomopixel Bar 🍅

Native retro pixel-art Pomodoro bar widget with ticking timer, 32×32 animated mascots, and popout panel for **Omarchy** (Arch Linux + Hyprland + Quickshell).

![Pomopixel Bar](preview.png)

## Features

- **Animated Mascot in Bar**: Your active mascot sits directly in the Omarchy status bar with lightweight, zero-GPU spritesheet animation.
- **Live Status Bar Ticker**: Always see remaining focus time and session status in the bar.
- **Multi-Monitor Synchronization**: Absolute timestamp sync (`Date.now()`) with peer `broadcast()` across all connected displays.
- **Drop-Down Retro Popout Panel**: Click the bar icon to slide out the full pixel-art dashboard with large timer, segmented progress bar, controls, and animated mascots.
- **32×32 Animated Mascots**:
  - 🥟 **Dumpling Blob**: Bouncing and sleeping blob from the retro aesthetic.
  - 🐧 **Linux Tux**: Tux typing on a pixel laptop while focusing, snoozing on break.
  - 👾 **Claude Critter**: Retro purple pet critter.
  - 👻 **Pac-Man Ghost**: Blinky in action.
- **Omarchy Theme Synchronization**: Synchronizes live with `~/.local/state/omarchy/current/theme/colors.toml`.
- **Keyboard Shortcuts in Panel**:
  - `Space`: Start / Pause
  - `R`: Reset current session
  - `S`: Skip to next session
  - `M`: Cycle mascot
  - `1`: Focus Mode (25m)
  - `2`: Short Break (5m)
  - `3`: Long Break (15m)
  - `Esc`: Close popout panel
- **Quick Bar Controls**:
  - `Left Click`: Toggle Popout Panel
  - `Right Click`: Quick Start / Pause without opening panel
  - `Middle Click`: Quick Reset
- **Smooth Audio & Desktop Notifications**: Synthesized soft chimes for focus start/finish, with native `notify-send` integration.

## Installation

Install directly via the Omarchy Plugin Manager:

```bash
omarchy plugin add https://github.com/fl0p3r/pomopixel-bar --enable
```

Or manually clone and enable:

```bash
git clone https://github.com/fl0p3r/pomopixel-bar ~/.config/omarchy/plugins/pomopixel-bar
omarchy plugin enable pomopixel-bar centerEnd
```

## Removal

To disable and remove the plugin:

```bash
omarchy plugin disable pomopixel-bar
rm -rf ~/.config/omarchy/plugins/pomopixel-bar
```

## Configuration

Settings are saved in `~/.config/pomopixel/config.json`:

```json
{
  "focusDuration": 25,
  "shortBreakDuration": 5,
  "longBreakDuration": 15,
  "longBreakInterval": 4,
  "soundEnabled": true,
  "volume": 1.0,
  "notificationsEnabled": true,
  "mascot": "tux",
  "customAccent": ""
}
```

## License

MIT License.
