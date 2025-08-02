import 'package:flutter/material.dart';

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
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: Locale('en'),
          child: Row(
            children: [
              Text('🇺🇸'),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Locale('it'),
          child: Row(
            children: [
              Text('🇮🇹'),
              SizedBox(width: 8),
              Text('Italiano'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Locale('es'),
          child: Row(
            children: [
              Text('🇪🇸'),
              SizedBox(width: 8),
              Text('Español'),
            ],
          ),
        ),
      ],
    );
  }
}