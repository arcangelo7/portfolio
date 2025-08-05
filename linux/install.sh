#!/bin/bash

# Portfolio Linux Installation Script
set -e

APP_NAME="portfolio"
DESKTOP_FILE="portfolio.desktop"
ICON_FILE="icon-512.png"

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as normal user
if [ "$EUID" -eq 0 ]; then
    print_error "Do not run this script as root!"
    exit 1
fi

print_status "Installing Portfolio for Linux..."

# Find script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="$SCRIPT_DIR"

# Check if bundle exists
if [ ! -f "$BUNDLE_DIR/$APP_NAME" ]; then
    print_error "Cannot find executable $APP_NAME in $BUNDLE_DIR"
    exit 1
fi

# Create necessary directories
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
APPLICATIONS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

print_status "Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$APPLICATIONS_DIR" 
mkdir -p "$ICONS_DIR"

# Copy application files
print_status "Copying application files..."
cp -r "$BUNDLE_DIR"/* "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/$APP_NAME"

# Copy icon if exists
if [ -f "$BUNDLE_DIR/data/flutter_assets/assets/images/$ICON_FILE" ]; then
    print_status "Installing icon..."
    cp "$BUNDLE_DIR/data/flutter_assets/assets/images/$ICON_FILE" "$ICONS_DIR/$APP_NAME.png"
elif [ -f "$BUNDLE_DIR/data/flutter_assets/web/icons/$ICON_FILE" ]; then
    print_status "Installing icon (fallback)..."
    cp "$BUNDLE_DIR/data/flutter_assets/web/icons/$ICON_FILE" "$ICONS_DIR/$APP_NAME.png"
else
    print_warning "Icon not found, default will be used"
fi

# Create .desktop file
print_status "Creating .desktop file..."
cat > "$APPLICATIONS_DIR/$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Portfolio
Comment=Arcangelo's personal portfolio
Exec=$INSTALL_DIR/$APP_NAME
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Development;
StartupWMClass=$APP_NAME
EOF

# Update applications database
print_status "Updating applications database..."
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATIONS_DIR"
fi

# Update icon cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    print_status "Updating icon cache..."
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

print_success "Installation completed!"
print_status "The application should now appear in the applications menu"
print_status "You can also launch it from terminal with: $INSTALL_DIR/$APP_NAME"

# Ask if user wants to launch the app
echo
read -p "Do you want to launch Portfolio now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting Portfolio..."
    "$INSTALL_DIR/$APP_NAME" &
    print_success "Portfolio started!"
fi