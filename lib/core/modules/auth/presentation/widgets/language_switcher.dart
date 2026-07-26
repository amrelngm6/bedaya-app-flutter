import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [Text('🇺🇸'), const SizedBox(width: 8), Text('English')],
          ),
        ),
        PopupMenuItem(
          value: const Locale('ar'),
          child: Row(
            children: [Text('🇸🇦'), const SizedBox(width: 8), Text('العربية')],
          ),
        ),
      ],
    );
  }
}
