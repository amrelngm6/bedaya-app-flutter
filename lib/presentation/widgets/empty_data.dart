// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bedaya2/core/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyData extends StatefulWidget {
  const EmptyData({super.key, this.title, this.text});

  final String? title;
  final String? text;

  @override
  State<EmptyData> createState() => _EmptyDataState();
}

class _EmptyDataState extends State<EmptyData> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 100,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              margin: const EdgeInsets.only(top: 100),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: SvgPicture.asset('assets/svg/map_locations.svg'),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.title ?? '', style: AppStyles.h2),
                  const SizedBox(height: 20),
                  Text(
                    widget.text ?? '',
                    style: AppStyles.bodyLarge.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //  buttonText(openPage, 0, lang.translate('Back'))
          ],
        ),
      ),
    );
  }
}
