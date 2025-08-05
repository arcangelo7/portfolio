import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

class LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLanguageChanged;
  
  const LanguageSelector({
    super.key,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              CountryFlag.fromCountryCode('US', width: 16, height: 12),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('it'),
          child: Row(
            children: [
              CountryFlag.fromCountryCode('IT', width: 16, height: 12),
              const SizedBox(width: 8),
              const Text('Italiano'),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('es'),
          child: Row(
            children: [
              CountryFlag.fromCountryCode('ES', width: 16, height: 12),
              const SizedBox(width: 8),
              const Text('Español'),
            ],
          ),
        ),
      ],
    );
  }
}