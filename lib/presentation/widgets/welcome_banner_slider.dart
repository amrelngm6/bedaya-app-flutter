import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/models/slide_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/presentation/widgets/welcome_slider.dart';

class WelcomeBannerSlider extends StatelessWidget {
  final List<SlideModel> slides;

  const WelcomeBannerSlider({super.key, required this.slides});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WelcomeSlider(
          height: 160,
          autoPlay: true,
          slides: [
            for (var slide in slides)
              SlideData(
                title: context.locale == Locale('ar')
                    ? slide.arTitle.tr()
                    : slide.title.tr(),
                subtitle: context.locale == Locale('ar')
                    ? slide.arDescription.tr()
                    : slide.description.tr(),
                // buttonText: 'Check now',
                backgroundGradient: LinearGradient(
                  colors: [Color(0xFF5B8DEF), Color(0xFF0F6FEC)],
                ),
                imageWidget: Image.network(slide.imageUrl ?? ''),
                onTap: () => (sl.analytics.trackTap(
                  'slide_tap',
                  screenName: 'HomePage',
                )),
                onButtonTap: () => (),
              ),
          ],
        ),
      ],
    );
  }
}
