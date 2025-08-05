#!/bin/bash

# Portfolio Linux Uninstall Script
set -e

APP_NAME="portfolio"
DESKTOP_FILE="portfolio.desktop"

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

print_status "Uninstalling Portfolio for Linux..."

# Paths
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
APPLICATIONS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

# Terminate application if running
if pgrep -f "$APP_NAME" > /dev/null; then
    print_status "Closing running Portfolio..."
    pkill -f "$APP_NAME" || true
    sleep 2
fi

# Remove files
if [ -d "$INSTALL_DIR" ]; then
    print_status "Removing application directory..."
    rm -rf "$INSTALL_DIR"
fi

if [ -f "$APPLICATIONS_DIR/$DESKTOP_FILE" ]; then
    print_status "Removing .desktop file..."
    rm -f "$APPLICATIONS_DIR/$DESKTOP_FILE"
fi

if [ -f "$ICONS_DIR/$APP_NAME.png" ]; then
    print_status "Removing icon..."
    rm -f "$ICONS_DIR/$APP_NAME.png"
fi

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

print_success "Uninstallation completed!"
print_status "Portfolio has been removed from the system"