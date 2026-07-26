import 'package:bedaya2/core/modules/articles/models/article_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/data/sample_articles_data.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/articles/presentation/widgets/article_card.dart';
import 'package:bedaya2/core/di/service_locator.dart';

class ArticlesListPage extends StatefulWidget {
  const ArticlesListPage({super.key});

  @override
  State<ArticlesListPage> createState() => _ArticlesListPageState();
}

class _ArticlesListPageState extends State<ArticlesListPage> {
  String selectedCategory = 'All Articles';
  List<ArticleApiModel> displayedArticles = [];
  List<ArticleApiModel> articlesList = [];
  final List<String> categories = SampleArticlesData.getCategories();

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _fetchArticles() async {
    final result = await sl.articles.getArticles(page: 1);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          articlesList.clear();
          articlesList.addAll(data.data);
        });
      case Failure(:final exception):
        setState(() {
          exception.message;
        });
    }
    sl.analytics.trackScreen(
      'ArticlesListPage - Fetched ${articlesList.length} articles',
    );
  }

  void _loadArticles() async {
    await _fetchArticles();
    setState(() {
      displayedArticles = articlesList
          .where(
            (article) =>
                selectedCategory == 'All Articles' ||
                article.category == selectedCategory,
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Blog & Articles'.tr(),
          style: AppStyles.h2.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.darkTeal),
            onPressed: () {
              sl.analytics.trackTap(
                'category_change_tap',
                screenName: 'Tabbed ArticlesListPage - Search',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Categories Filter
          _buildCategoriesFilter(),

          // Articles List
          Expanded(
            child: displayedArticles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: displayedArticles.length,
                    itemBuilder: (context, index) {
                      final article = displayedArticles[index];

                      return ArticleCard(article: article, isHorizontal: true);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                _loadArticles();
              });
              sl.analytics.trackTap(
                'category_change_tap',
                screenName: 'Articles Category - $category',
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryTeal
                    : AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : AppColors.greyOutline,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  category.tr(),
                  style: AppStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: AppColors.greyOutline),
          const SizedBox(height: 16),
          Text('No articles found'.tr(), style: AppStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category'.tr(),
            style: AppStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
