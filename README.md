
# kali-setup

Custom Kali Linux environment setup.

This repository contains my personal Kali Linux configuration, including:

- bspwm
- sxhkd
- Polybar
- Kitty
- Picom
- Rofi
- Eww
- Zsh + Powerlevel10k
- FZF
- Neovim / NvChad
- pywal16
- Custom scripts and keybindings
- Hack Nerd Font
- bspwm session configuration

## Installation

Clone the repository:

```bash
git clone https://github.com/davidjimsalc-jpg/kali-setup.git
cd kali-setup
chmod +x install.sh dependencies.sh
sudo ./install.sh
```

The installer will:
- Install the required dependencies
- Configure bspwm
- Install and configure the required fonts
- Copy the user configuration
- Copy the root configuration
- Fix required permissions
- Set bspwm as the default session
After the installation finishes, log out and log back in.
Notes
This setup was created and tested on Kali Linux running inside VMware.
Some parts of the configuration, especially Picom and VMware integration, are adjusted for virtualized environments.

## Keyboard Shortcuts

Main shortcuts included in the setup:

| Shortcut | Action |
|---|---|
| `Super + Enter` | Open Kitty terminal |
| `Super + Ctrl + Alt + Enter` | Preselect south and open Kitty |
| `Super + D` | Open Rofi launcher |
| `Super + Escape` | Reload sxhkd configuration |
| `Super + Ctrl + Alt + 1` | Send floating window below |
| `Super + Ctrl + Alt + 2` | Bring floating window above |
| `Super + Ctrl + Alt + 3` | Return floating window to normal level |
| `Super + Q` | Close/kill focused window using custom script |
| `Super + Shift + Q` | Quit bspwm |
| `Super + Shift + R` | Restart bspwm |
| `Super + M` | Toggle tiled / monocle layout |
| `Super + G` | Swap focused window with the biggest window |
| `Super + T` | Set window to tiled |
| `Super + Shift + T` | Set window to pseudo-tiled |
| `Super + S` | Set window to floating |
| `Super + F` | Set window to fullscreen |
| `Super + Ctrl + M` | Toggle marked flag |
| `Super + Ctrl + X` | Toggle locked flag |
| `Super + Ctrl + Y` | Toggle sticky flag |
| `Super + Ctrl + Z` | Toggle private flag |
| `Super + Arrow Keys` | Focus window in that direction |
| `Super + Shift + Arrow Keys` | Swap/move window in that direction |
| `Super + C` | Focus next window |
| `Super + Shift + C` | Focus previous window |
| `Super + [` | Previous desktop |
| `Super + ]` | Next desktop |
| `Super + Tab` | Focus last desktop |
| `Super + 1-0` | Switch to workspace 1-10 |
| `Super + Shift + 1-0` | Send focused window to workspace 1-10 |
| `Super + Ctrl + Alt + Arrow Keys` | Preselect split direction |
| `Super + Ctrl + 1-9` | Set preselection ratio |
| `Super + Ctrl + Alt + Space` | Cancel focused-node preselection |
| `Super + Ctrl + Shift + Space` | Cancel desktop preselection |
| `Super + Alt + Arrow Keys` | Resize focused window |
| `Super + Shift + F` | Open Firefox |
| `Super + K` | Minimize/shrink terminal |
| `Super + Shift + X` | Lock screen with i3lock-fancy |
| `Super + Alt + F` | Open wallpaper carousel / selector |


## Screenshots

<img width="1431" height="684" alt="image" src="https://github.com/user-attachments/assets/210fc07e-f3ec-40b9-93c0-684474590590" />

<img width="1435" height="686" alt="image" src="https://github.com/user-attachments/assets/c8c24ce3-4002-4009-82f6-d7a6262d9940" />

<img width="1432" height="681" alt="image" src="https://github.com/user-attachments/assets/2a6ce857-6aaf-4871-a7d5-c23b9f087f15" />

<img width="1425" height="691" alt="image" src="https://github.com/user-attachments/assets/28f9fd47-2230-4f2b-95c2-cac6d87282d7" />

<img width="1431" height="684" alt="image" src="https://github.com/user-attachments/assets/d519a198-b4f8-4032-82f2-c3c97b75c776" />

<img width="1423" height="690" alt="image" src="https://github.com/user-attachments/assets/5ee25f3f-2709-4e56-be8d-e010a3363430" />


## Credits

This setup is based on concepts learned from the Hack4u Linux Customization course, which I later adapted and expanded to fit my own workflow.


```text
Kali Environment Setup



