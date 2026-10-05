#!/bin/bash

set -e

SRC="$(cd "$(dirname "$0")" && pwd)"

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

if [ "$EUID" -ne 0 ]; then
    echo "[!] Ejecuta el instalador con:"
    echo "    sudo ./install.sh"
    exit 1
fi

if [ -z "$REAL_HOME" ]; then
    echo "[!] No se pudo detectar el home del usuario."
    exit 1
fi

echo "[+] Instalando dependencias..."

"$SRC/dependencies.sh"

echo "[+] Usuario detectado: $REAL_USER"
echo "[+] Home detectado: $REAL_HOME"

# ---------------------------------------------------
# Backup usuario
# ---------------------------------------------------

USER_BACKUP="$REAL_HOME/.setup-kali-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$USER_BACKUP"

echo "[+] Creando backup del usuario en:"
echo "    $USER_BACKUP"

for item in \
    "$REAL_HOME/.config" \
    "$REAL_HOME/.local" \
    "$REAL_HOME/Conf_desktop" \
    "$REAL_HOME/.zshrc" \
    "$REAL_HOME/.p10k.zsh" \
    "$REAL_HOME/.zprofile" \
    "$REAL_HOME/.zshenv" \
    "$REAL_HOME/.fzf.bash" \
    "$REAL_HOME/.fzf.zsh" \
    "$REAL_HOME/.fehbg"
do
    if [ -e "$item" ]; then
        cp -a "$item" "$USER_BACKUP/" 2>/dev/null || true
    fi
done

# ---------------------------------------------------
# Instalar configuración usuario
# ---------------------------------------------------

echo "[+] Instalando configuración del usuario..."

cp -a "$SRC/user/." "$REAL_HOME/"

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config" 2>/dev/null || true
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local" 2>/dev/null || true
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/Conf_desktop" 2>/dev/null || true
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.fzf" 2>/dev/null || true

for file in \
    .zshrc \
    .p10k.zsh \
    .zprofile \
    .zshenv \
    .fzf.bash \
    .fzf.zsh \
    .fehbg
do
    if [ -e "$REAL_HOME/$file" ]; then
        chown "$REAL_USER:$REAL_USER" "$REAL_HOME/$file"
    fi
done

# Permisos de ejecución
chmod +x "$REAL_HOME/.fzf/bin/fzf" 2>/dev/null || true
chmod +x "$REAL_HOME/.config/bspwm/bspwmrc" 2>/dev/null || true
chmod +x "$REAL_HOME/.config/polybar/launch.sh" 2>/dev/null || true
chmod +x "$REAL_HOME/.config/eww/scripts/"*.sh 2>/dev/null || true
chmod +x "$REAL_HOME/.local/bin/"* 2>/dev/null || true
chmod +x "$REAL_HOME/.config/polybar/scripts/"* 2>/dev/null || true


# Evitar error si Cargo no existe
if [ -f "$REAL_HOME/.zshenv" ]; then
    sed -i \
    's#^.*\.cargo/env.*$#[ -f "$HOME/.cargo/env" ] \&\& source "$HOME/.cargo/env"#' \
    "$REAL_HOME/.zshenv"
fi

# Evitar error si sudo_zsh no está instalado
if [ -f "$REAL_HOME/.zshrc" ]; then
    sed -i \
    's#^source /usr/share/sudo_zsh/sudo.plugin.zsh$#[ -f /usr/share/sudo_zsh/sudo.plugin.zsh ] \&\& source /usr/share/sudo_zsh/sudo.plugin.zsh#' \
    "$REAL_HOME/.zshrc"
fi

# ---------------------------------------------------
# Backup root
# ---------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo
    echo "[+] Se necesitan permisos root para instalar la configuración de /root"
    exec sudo REAL_USER="$REAL_USER" REAL_HOME="$REAL_HOME" "$0"
fi

ROOT_BACKUP="/root/.setup-kali-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$ROOT_BACKUP"

echo "[+] Creando backup de root en:"
echo "    $ROOT_BACKUP"

for item in \
    /root/.zshrc \
    /root/.p10k.zsh \
    /root/.zprofile \
    /root/.zshenv \
    /root/.fzf.bash \
    /root/.fzf.zsh \
    /root/.fzf \
    /root/powerlevel10k \
    /root/zsh-autocomplete \
    /root/.config/kitty \
    /root/.config/nvim
do
    if [ -e "$item" ]; then
        cp -a "$item" "$ROOT_BACKUP/" 2>/dev/null || true
    fi
done

# ---------------------------------------------------
# Instalar configuración root
# ---------------------------------------------------

echo "[+] Instalando configuración de root..."

cp -a "$SRC/root/." /root/

chown -R root:root /root/.zshrc 2>/dev/null || true
chown -R root:root /root/.p10k.zsh 2>/dev/null || true
chown -R root:root /root/.zprofile 2>/dev/null || true
chown -R root:root /root/.zshenv 2>/dev/null || true
chown -R root:root /root/.fzf* 2>/dev/null || true
chown -R root:root /root/powerlevel10k 2>/dev/null || true
chown -R root:root /root/zsh-autocomplete 2>/dev/null || true
chown -R root:root /root/.config 2>/dev/null || true

# ---------------------------------------------------
# Corregir referencias de root hacia el usuario normal
# ---------------------------------------------------

if [ -f /root/.zshrc ]; then
    sed -i "s#/home/USUARIO#$REAL_HOME#g" /root/.zshrc
fi

# ---------------------------------------------------
# Bspwm por defecto
# ---------------------------------------------------

cat > "$REAL_HOME/.dmrc" <<'EOF'
[Desktop]
Session=bspwm
EOF

chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.dmrc"
chmod 644 "$REAL_HOME/.dmrc"


# ---------------------------------------------------
# Permisos finales
# ---------------------------------------------------

chmod +x /root/.fzf/bin/fzf 2>/dev/null || true

echo
echo "[+] Instalación completada."
echo
echo "Usuario:"
echo "  $REAL_USER"
echo "  $REAL_HOME"
echo
echo "Backup usuario:"
echo "  $USER_BACKUP"
echo
echo "Backup root:"
echo "  $ROOT_BACKUP"
echo
echo "[!] Cierra sesión y vuelve a entrar para cargar toda la configuración."
