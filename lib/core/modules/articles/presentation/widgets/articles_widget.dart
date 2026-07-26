import 'package:bedaya2/core/modules/articles/models/article_model.dart';
import 'package:bedaya2/core/modules/articles/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';

class ArticlesWidget extends StatefulWidget {
  final List<ArticleApiModel> articlesList;
  const ArticlesWidget({super.key, required this.articlesList});

  @override
  State<ArticlesWidget> createState() => _ArticlesWidgetState();
}

class _ArticlesWidgetState extends State<ArticlesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: SizedBox(
        height: 340,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.articlesList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: ArticleCard(
                article: widget.articlesList[index],
                isHorizontal: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
