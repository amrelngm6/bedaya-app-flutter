import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// A simple language toggle button for quick testing
/// This can be added to AppBars for easy language switching during development
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Text(
        context.locale.languageCode == 'ar' ? 'EN' : 'ع',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: () {
        final newLocale = context.locale.languageCode == 'ar'
            ? const Locale('en')
            : const Locale('ar');
        context.setLocale(newLocale);
      },
      tooltip: 'Toggle Language',
    );
  }
}
