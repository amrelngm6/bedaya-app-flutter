// Loading bar widget to show while fetching data or performing an action
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final String? message;

  const Loader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[const SizedBox(height: 16), Text(message!)],
      ],
    );
  }
}
