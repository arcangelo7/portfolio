# Portfolio

[![Test](https://github.com/arcangelo7/portfolio/actions/workflows/test.yml/badge.svg)](https://github.com/arcangelo7/portfolio/actions/workflows/test.yml)
[![Coverage](test/coverage-badge.svg)](https://arcangelo7.github.io/portfolio/test/coverage/)
[![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat&logo=flutter)](https://flutter.dev)

[![Web](https://img.shields.io/badge/Platform-Web-4285F4?style=flat&logo=google-chrome&logoColor=white)](https://arcangelo7.github.io/portfolio/)
[![Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat&logo=android&logoColor=white)](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-android-latest.apk)
[![iOS](https://img.shields.io/badge/Platform-iOS-000000?style=flat&logo=apple&logoColor=white)](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-ios-latest.ipa)
[![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?style=flat&logo=windows&logoColor=white)](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-windows-latest.zip)
[![macOS](https://img.shields.io/badge/Platform-macOS-000000?style=flat&logo=apple&logoColor=white)](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-macos-latest.tar.gz)
[![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-linux-latest.tar.gz)

A responsive Flutter portfolio website showcasing my institutional profile and skills.

**🌐 Portfolio Website**: [https://arcangelo7.github.io/portfolio/](https://arcangelo7.github.io/portfolio/)

## Features

- Real-time publication updates from Zotero library
- Dynamic CV generation with PDF export
- Multi-language support (English, Italian, Spanish)
- Dark/Light theme toggle
- Responsive design for all platforms
- Modern Material 3 design
- Cross-platform compatibility (one codebase for all operating systems)

## Supported Platforms

- **Web**: [Live Demo](https://arcangelo7.github.io/portfolio/) - Also installable as Progressive Web App (PWA)
- **Android**: [Download APK](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-android-latest.apk)
- **iOS**: [Download IPA](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-ios-latest.ipa) (unsigned - requires sideloading) ⚠️ **Note**: I don't own a Mac or iPhone, so iOS builds are untested
- **Windows**: [Download Windows Build](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-windows-latest.zip)
- **macOS**: [Download macOS Build](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-macos-latest.tar.gz) ⚠️ **Note**: I don't own a Mac, so macOS builds are untested
- **Linux**: [Download Linux Build](https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-linux-latest.tar.gz)

### Platform-specific Installation

#### Web Installation

The web version is available as a Progressive Web App (PWA):

1. Visit [https://arcangelo7.github.io/portfolio/](https://arcangelo7.github.io/portfolio/)
2. Click the install button in your browser's address bar
3. The app will be installed and accessible from your desktop/start menu

#### Android Installation

1. Download the APK file from the releases page
2. Enable "Install from unknown sources" in your Android settings
3. Open the downloaded APK file
4. Follow the installation prompts
5. Launch the app from your app drawer

#### iOS Installation

1. Download the iOS IPA file from the releases page
2. Install using one of these methods:
   - **AltStore**: Install AltStore on your device, then use it to install the IPA
   - **Sideloadly**: Use Sideloadly to install the IPA via USB connection
   - **Xcode**: Open the project in Xcode and deploy to your device
3. Trust the developer certificate in Settings > General > Device Management

#### Windows Installation

1. Download the Windows ZIP file from the releases page
2. Extract the ZIP to your preferred directory
3. Run `portfolio.exe` from the extracted folder

#### macOS Installation

1. Download the macOS tar.gz file from the releases page
2. Extract the archive: `tar -xzf portfolio-macos-latest.tar.gz`
3. Move the app to Applications: `mv portfolio.app /Applications/`
4. Run from Applications folder or Launchpad
5. If you get a security warning, go to System Preferences > Security & Privacy and click "Open Anyway"

#### Linux Installation

1. Download the Linux tar.gz file from the releases page
2. Extract the archive: `tar -xzf portfolio-linux-latest.tar.gz`
3. Navigate to the extracted directory
4. Run the installation script: `chmod +x install.sh && ./install.sh`
5. The app will be installed system-wide and accessible from your application menu

To uninstall:

```bash
./uninstall.sh
```

### Development Installation

For developers who want to run from source:

```bash
# Clone the repository
git clone https://github.com/arcangelo7/portfolio.git
cd portfolio

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run

# For specific platforms
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
flutter run -d windows   # Windows
flutter run -d macos     # macOS
flutter run -d linux     # Linux
```

## Testing

Run tests with coverage (auto-excludes generated files):

```bash
./test/test_coverage.sh --html
```

**📊 Test Coverage**: View detailed coverage report at [https://arcangelo7.github.io/portfolio/test/coverage/](https://arcangelo7.github.io/portfolio/test/coverage/)