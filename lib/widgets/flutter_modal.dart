import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class FlutterModal extends StatelessWidget {
  const FlutterModal({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainer,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PortfolioTheme.cobaltBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flutter_dash,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.flutterAppTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        l10n.flutterAppSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.flutterAppDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildDownloadButton(
                  context,
                  l10n.downloadForAndroid,
                  Icons.android,
                  const Color(0xFF3DDC84),
                  () => _launchUrl(
                    'https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-android-latest.apk',
                  ),
                ),
                _buildDownloadButton(
                  context,
                  l10n.downloadForIOS,
                  Icons.phone_iphone,
                  const Color(0xFF007AFF),
                  () => _launchUrl(
                    'https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-ios-latest.ipa',
                  ),
                ),
                _buildDownloadButton(
                  context,
                  l10n.downloadForWindows,
                  Icons.window,
                  const Color(0xFF0078D4),
                  () => _launchUrl(
                    'https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-windows-latest.zip',
                  ),
                ),
                _buildDownloadButton(
                  context,
                  l10n.downloadForMacOS,
                  Icons.laptop_mac,
                  const Color(0xFF000000),
                  () => _launchUrl(
                    'https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-macos-latest.dmg',
                  ),
                ),
                _buildDownloadButton(
                  context,
                  l10n.downloadForLinux,
                  Icons.desktop_windows,
                  const Color(0xFF1F1F1F),
                  () => _launchUrl(
                    'https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-linux-latest.tar.gz',
                  ),
                ),
                _buildDownloadButton(
                  context,
                  l10n.viewSourceCode,
                  Icons.code,
                  PortfolioTheme.emeraldGreen,
                  () => _launchUrl('https://github.com/arcangelo7/portfolio'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Text(
                  l10n.installationInstructions,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed:
                      () => _launchUrl(
                        'https://github.com/arcangelo7/portfolio/blob/main/README.md',
                      ),
                  icon: const Icon(Icons.article, size: 18),
                  label: const Text('View Installation Instructions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.closeFlutterInfo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
