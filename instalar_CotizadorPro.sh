#!/bin/bash
# ============================================================
#   CotizadorPro — Instalador de Acceso Directo en Escritorio
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_FILE="$SCRIPT_DIR/CotizadorPro.html"
DESKTOP_DIR="$HOME/Desktop"
LINUX_DESKTOP="$DESKTOP_DIR/CotizadorPro.desktop"
MACOS_SCRIPT="$DESKTOP_DIR/CotizadorPro.command"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║       CotizadorPro — Instalador              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Check file exists
if [ ! -f "$APP_FILE" ]; then
  echo "❌ Error: No se encontró CotizadorPro.html en $SCRIPT_DIR"
  echo "   Asegúrate de que ambos archivos estén en la misma carpeta."
  exit 1
fi

# Detect OS
OS_TYPE="$(uname -s)"

if [[ "$OS_TYPE" == "Darwin" ]]; then
  # ── macOS ──
  echo "🍎 macOS detectado"
  mkdir -p "$DESKTOP_DIR"

  cat > "$MACOS_SCRIPT" << APPLESCRIPT
#!/bin/bash
open "$APP_FILE"
APPLESCRIPT

  chmod +x "$MACOS_SCRIPT"
  echo "✅ Acceso directo creado en el Escritorio: CotizadorPro.command"
  echo ""
  echo "   ▶ Doble clic en 'CotizadorPro.command' para abrir la app."
  echo "   📌 La app se abrirá en tu navegador predeterminado."
  echo ""
  open "$DESKTOP_DIR"

elif [[ "$OS_TYPE" == "Linux" ]]; then
  # ── Linux ──
  echo "🐧 Linux detectado"

  # Try to find desktop directory
  if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Escritorio")
    LINUX_DESKTOP="$DESKTOP_DIR/CotizadorPro.desktop"
  fi

  mkdir -p "$DESKTOP_DIR"

  # Find browser
  BROWSER=""
  for b in xdg-open google-chrome chromium-browser firefox brave-browser; do
    if command -v "$b" &>/dev/null; then
      BROWSER="$b"
      break
    fi
  done

  cat > "$LINUX_DESKTOP" << DESKTOP
[Desktop Entry]
Version=1.0
Type=Application
Name=CotizadorPro
Comment=Generador de Cotizaciones Profesionales
Exec=xdg-open "$APP_FILE"
Icon=text-html
Terminal=false
Categories=Office;Finance;
StartupNotify=true
DESKTOP

  chmod +x "$LINUX_DESKTOP"

  # Try to trust the desktop file (GNOME)
  gio trust "$LINUX_DESKTOP" 2>/dev/null || true

  echo "✅ Acceso directo creado: $LINUX_DESKTOP"
  echo ""
  echo "   ▶ Doble clic en 'CotizadorPro' en el Escritorio para abrir la app."
  echo ""

else
  echo "⚠️  Sistema operativo no reconocido: $OS_TYPE"
  echo "   Abre manualmente el archivo CotizadorPro.html en tu navegador."
fi

echo "══════════════════════════════════════════════════"
echo "  ¡Listo! CotizadorPro está instalado."
echo "  Nota: Necesitas conexión a internet la primera"
echo "  vez para cargar las librerías PDF (jsPDF)."
echo "══════════════════════════════════════════════════"
echo ""
