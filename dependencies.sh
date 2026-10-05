#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
    echo "[!] Ejecuta este script como root."
    exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

BUILD_DIR="/tmp/setup-kali-build"

echo "[+] Usuario: $REAL_USER"
echo "[+] Home: $REAL_HOME"

# ----------------------------------------------------------
# PAQUETES BASE
# ----------------------------------------------------------

echo "[+] Actualizando repositorios..."

apt update

echo "[+] Instalando dependencias base..."

apt install -y \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    zip \
    jq \
    ca-certificates \
    pkg-config \
    meson \
    ninja-build \
    cmake \
    zsh \
    feh \
    polybar \
    rofi \
    dunst \
    imagemagick \
    playerctl \
    pulseaudio-utils \
    open-vm-tools \
    open-vm-tools-desktop \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    pipx \
    fonts-font-awesome \
    libxcb1-dev \
    libxcb-util0-dev \
    libxcb-ewmh-dev \
    libxcb-randr0-dev \
    libxcb-icccm4-dev \
    libxcb-keysyms1-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxcb-render0-dev \
    libxcb-render-util0-dev \
    libxcb-image0-dev \
    libxcb-present-dev \
    libxcb-composite0-dev \
    libxkbcommon-x11-dev \
    libx11-xcb-dev \
    libxcb-damage0-dev \
    libxcb-glx0-dev \
    libxcb-sync-dev \
    libpixman-1-dev \
    libdbus-1-dev \
    libconfig-dev \
    libgl1-mesa-dev \
    libpcre2-dev \
    libev-dev \
    libepoxy-dev \
    uthash-dev \
    libgtk-3-dev \
    libcairo2-dev \
    libglib2.0-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-dev \
    librsvg2-dev \
    libdbusmenu-gtk3-dev \
    rustc \
    cargo

# ----------------------------------------------------------
# DIRECTORIO TEMPORAL
# ----------------------------------------------------------

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ----------------------------------------------------------
# BSPWM
# ----------------------------------------------------------

echo "[+] Instalando bspwm..."

cd "$BUILD_DIR"

git clone --depth=1 https://github.com/baskerville/bspwm.git

cd bspwm

make
make install

# ----------------------------------------------------------
# SXHKD
# ----------------------------------------------------------

echo "[+] Instalando sxhkd..."

cd "$BUILD_DIR"

git clone --depth=1 https://github.com/baskerville/sxhkd.git

cd sxhkd

make
make install

# ----------------------------------------------------------
# PICOM
# ----------------------------------------------------------

echo "[+] Instalando picom..."

cd "$BUILD_DIR"

git clone --depth=1 https://github.com/yshui/picom.git

cd picom

meson setup --buildtype=release build
ninja -C build
ninja -C build install

# ----------------------------------------------------------
# KITTY - GITHUB RELEASE
# ----------------------------------------------------------

echo "[+] Instalando Kitty desde GitHub..."

cd "$BUILD_DIR"

KITTY_VERSION="$(
    curl -fsSL https://api.github.com/repos/kovidgoyal/kitty/releases/latest \
    | jq -r '.tag_name' \
    | sed 's/^v//'
)"

echo "[+] Kitty $KITTY_VERSION"

KITTY_URL="$(
    curl -fsSL "https://api.github.com/repos/kovidgoyal/kitty/releases/tags/v${KITTY_VERSION}" \
    | jq -r '.assets[].browser_download_url' \
    | grep 'x86_64.txz$' \
    | grep -v kitten \
    | head -1
)"

if [ -z "$KITTY_URL" ]; then
    echo "[!] No se encontró el bundle x86_64 de Kitty."
    exit 1
fi

wget -O kitty.txz "$KITTY_URL"

rm -rf /opt/kitty
mkdir -p /opt/kitty

tar -xf kitty.txz -C /opt/kitty

ln -sf /opt/kitty/bin/kitty /usr/local/bin/kitty
ln -sf /opt/kitty/bin/kitten /usr/local/bin/kitten

# ----------------------------------------------------------
# EWW
# ----------------------------------------------------------

echo "[+] Instalando Eww..."

cd "$BUILD_DIR"

git clone --depth=1 https://github.com/elkowar/eww.git

chown -R "$REAL_USER:$REAL_USER" "$BUILD_DIR/eww"

cd "$BUILD_DIR/eww"

sudo -u "$REAL_USER" cargo build \
    --release \
    --no-default-features \
    --features x11

install -Dm755 target/release/eww /usr/local/bin/eww

# ----------------------------------------------------------
# PYWAL16
# ----------------------------------------------------------

echo "[+] Instalando pywal16..."

sudo -u "$REAL_USER" pipx install pywal16 || \
sudo -u "$REAL_USER" pipx upgrade pywal16

# ----------------------------------------------------------
# BAT - RELEASE DE GITHUB
# ----------------------------------------------------------

echo "[+] Instalando bat..."

cd "$BUILD_DIR"

BAT_URL="$(
    curl -fsSL https://api.github.com/repos/sharkdp/bat/releases/latest \
    | jq -r '.assets[].browser_download_url' \
    | grep '_amd64.deb$' \
    | grep -v musl \
    | head -1
)"

if [ -n "$BAT_URL" ]; then
    wget -O bat.deb "$BAT_URL"
    apt install -y ./bat.deb
else
    echo "[!] No se encontró release .deb de bat."
fi

# ----------------------------------------------------------
# LSD - RELEASE DE GITHUB
# ----------------------------------------------------------

echo "[+] Instalando lsd..."

cd "$BUILD_DIR"

LSD_URL="$(
    curl -fsSL https://api.github.com/repos/lsd-rs/lsd/releases/latest \
    | jq -r '.assets[].browser_download_url' \
    | grep '_amd64.deb$' \
    | grep -v musl \
    | head -1
)"

if [ -n "$LSD_URL" ]; then
    wget -O lsd.deb "$LSD_URL"
    apt install -y ./lsd.deb
else
    echo "[!] No se encontró release .deb de lsd."
fi

# ----------------------------------------------------------
# NEOVIM - RELEASE DE GITHUB
# ----------------------------------------------------------

echo "[+] Instalando Neovim..."

cd "$BUILD_DIR"

NVIM_URL="$(
    curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
    | jq -r '.assets[].browser_download_url' \
    | grep 'nvim-linux-x86_64.tar.gz$' \
    | head -1
)"

if [ -z "$NVIM_URL" ]; then
    echo "[!] No se encontró Neovim x86_64."
    exit 1
fi

wget -O nvim.tar.gz "$NVIM_URL"

rm -rf /opt/nvim
mkdir -p /opt/nvim

tar -xzf nvim.tar.gz \
    --strip-components=1 \
    -C /opt/nvim

ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# ----------------------------------------------------------
# HACK NERD FONTS
# ----------------------------------------------------------

echo "[+] Instalando Hack Nerd Font..."

cd "$BUILD_DIR"

FONT_URL="$(
    curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | jq -r '.assets[].browser_download_url' \
    | grep '/Hack.zip$' \
    | head -1
)"

if [ -n "$FONT_URL" ]; then
    wget -O Hack.zip "$FONT_URL"

    rm -rf /usr/local/share/fonts/HackNerdFont
    mkdir -p /usr/local/share/fonts/HackNerdFont

    unzip -o Hack.zip \
        -d /usr/local/share/fonts/HackNerdFont >/dev/null

    fc-cache -f
else
    echo "[!] No se pudo localizar Hack Nerd Font."
fi


# ----------------------------------------------------------
# ZSH
# ----------------------------------------------------------

echo "[+] Configurando Zsh..."

usermod --shell /usr/bin/zsh "$REAL_USER"
usermod --shell /usr/bin/zsh root

# ----------------------------------------------------------
# VMWARE TOOLS
# ----------------------------------------------------------

systemctl enable --now open-vm-tools 2>/dev/null || true



# ----------------------------------------------------------
# VMWARE TOOLS
# ----------------------------------------------------------

echo "[+] Creando sesión bspwm..."

cat > /usr/share/xsessions/bspwm.desktop <<'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=bspwm
Type=Application
DesktopNames=bspwm
EOF

# ----------------------------------------------------------
# LIMPIEZA
# ----------------------------------------------------------

rm -rf "$BUILD_DIR"

echo
echo "[+] Dependencias instaladas."
