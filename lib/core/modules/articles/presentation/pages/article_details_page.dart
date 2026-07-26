import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:bedaya2/core/data/sample_articles_data.dart';
import 'package:bedaya2/core/modules/articles/models/article_model.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/articles/presentation/widgets/article_card.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/auth_required_sheet.dart';

class ArticleDetailsPage extends StatefulWidget {
  final ArticleApiModel article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _isLiked = false;
  // bool _isBookmarked = false;

  ArticleApiModel articleDetails = ArticleApiModel(
    id: 0,
    title: '',
    subtitle: '',
    content: '',
    category: '',
    coverImageUrl: '',
    authorName: '',
    authorRole: '',
    authorImageUrl: null,
    readingTimeMinutes: 0,
    viewsCount: 0,
    likesCount: 0,
    tags: [],
    relatedImages: [],
    publishedAt: '',
  );

  @override
  void initState() {
    super.initState();
    _loadArticleDetails();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadArticleDetails() async {
    // Simulate loading delay
    final result = await sl.articles.getArticleById(widget.article.id);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          articleDetails = data;
          sl.analytics.trackScreen(
            'ArticleDetailsPage - Viewed ${articleDetails.title}',
          );
          _isLiked = articleDetails.isLikedByMe;
        });
        break;
      case Failure():
        setState(() {
          articleDetails = widget.article;
        });
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relatedArticles = SampleArticlesData.getRelatedArticles(
      articleDetails.id.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildContent(),
                if (articleDetails.relatedImages.isNotEmpty)
                  _buildImageGallery(),
                _buildTags(),
                _buildAuthorCard(),
                if (relatedArticles.isNotEmpty)
                  _buildRelatedArticles(relatedArticles),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryTeal,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : AppColors.darkTeal,
            ),
          ),
          onPressed: () {
            handleLike();
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _showTitle
            ? Text(
                articleDetails.title,
                style: AppStyles.h3.copyWith(color: Colors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            articleDetails.coverImageUrl != ''
                ? Image.network(
                    articleDetails.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.lightBlueBackground,
                        child: const Icon(
                          Icons.article,
                          size: 80,
                          color: AppColors.primaryTeal,
                        ),
                      );
                    },
                  )
                : SizedBox.shrink(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryTeal, width: 1),
            ),
            child: Text(
              articleDetails.category.tr(),
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            articleDetails.title,
            style: AppStyles.h1.copyWith(fontSize: 26, height: 1.3),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            articleDetails.subtitle,
            style: AppStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Meta Information
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: articleDetails.authorImageUrl != null
                    ? NetworkImage(articleDetails.authorImageUrl!)
                    : null,
                backgroundColor: AppColors.lightBlueBackground,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articleDetails.authorName,
                      style: AppStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      articleDetails.authorRole.tr(),
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildStatItem(
                Icons.calendar_today,
                articleDetails.formattedDate,
              ),
              _buildStatItem(
                Icons.schedule,
                '${articleDetails.readingTimeMinutes} ${'min read'.tr()}',
              ),
              _buildStatItem(
                Icons.visibility_outlined,
                _formatNumber(articleDetails.viewsCount),
              ),
              _buildStatItem(
                Icons.favorite_border,
                _formatNumber(articleDetails.likesCount),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MarkdownBody(
        data: articleDetails.content,
        styleSheet: MarkdownStyleSheet(
          p: AppStyles.bodyLarge.copyWith(
            height: 1.8,
            fontSize: 16,
            color: const Color(0xFF2C3E50),
          ),
          h1: AppStyles.h1.copyWith(
            fontSize: 24,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
          h2: AppStyles.h2.copyWith(
            fontSize: 20,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
          h3: AppStyles.h3.copyWith(
            fontSize: 18,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
          listBullet: AppStyles.bodyLarge.copyWith(
            color: AppColors.primaryTeal,
          ),
          listIndent: 24,
          blockquotePadding: const EdgeInsets.all(16),
          blockquoteDecoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: AppColors.primaryTeal, width: 4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Related Images'.tr(),
            style: AppStyles.h2.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: articleDetails.relatedImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    articleDetails.relatedImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.lightBlueBackground,
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: AppColors.primaryTeal,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text('Tags'.tr(), style: AppStyles.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: articleDetails.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: articleDetails.authorImageUrl != null
                ? NetworkImage(articleDetails.authorImageUrl!)
                : null,
            backgroundColor: AppColors.lightBlueBackground,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Written by'.tr(),
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  articleDetails.authorName,
                  style: AppStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  articleDetails.authorRole,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticles(List<ArticleModel> relatedArticles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Text(
            'Related Articles'.tr(),
            style: AppStyles.h2.copyWith(fontSize: 20),
          ),
        ),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: relatedArticles.length,
            itemBuilder: (context, index) {
              final article = ArticleApiModel.fromArticleModel(
                relatedArticles[index],
              );

              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: ArticleCard(article: article, isHorizontal: false),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildBottomBar() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           // Like Button
  //           Expanded(
  //             child: OutlinedButton.icon(
  //               onPressed: () async {
  //                 handleLike();
  //               },
  //               icon: Icon(
  //                 _isLiked ? Icons.favorite : Icons.favorite_border,
  //                 color: _isLiked ? Colors.red : AppColors.darkTeal,
  //               ),
  //               label: Text(
  //                 _isLiked ? 'Liked'.tr() : 'Like'.tr(),
  //                 style: AppStyles.bodyMedium.copyWith(
  //                   color: AppColors.darkTeal,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               style: OutlinedButton.styleFrom(
  //                 padding: const EdgeInsets.symmetric(vertical: 14),
  //                 side: const BorderSide(color: AppColors.darkTeal),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           // Share Button
  //           Expanded(
  //             child: ElevatedButton.icon(
  //               onPressed: _shareArticle,
  //               icon: const Icon(Icons.share, color: Colors.white),
  //               label: Text('Share'.tr(), style: AppStyles.buttonText),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: AppColors.primaryTeal,
  //                 padding: const EdgeInsets.symmetric(vertical: 14),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void handleLike() async {
    _checkAuthAndProceed(back: false);
    if (!sl.storage.isLoggedIn) return;
    setState(() {
      _isLiked = !_isLiked;
    });
    await sl.articles.toggleLike(articleDetails.id);
    sl.analytics.trackTap(
      'like_button_tap',
      screenName:
          '${_isLiked ? "Liked" : "Unliked"} Article - ${articleDetails.title}',
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // ─── Auth Gate ────────────────────────────────────────────────────────────

  void _checkAuthAndProceed({bool? back = false}) {
    if (!sl.storage.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAuthModal(back: back);
      });
    }
  }

  Future<void> _showAuthModal({bool? back = false}) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (sheetCtx) => AuthRequiredSheet(
        onNavigateToLogin: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onNavigateToRegister: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onGoBack: () {
          Navigator.pop(sheetCtx);
          if (mounted && back == true) Navigator.pop(context);
        },
      ),
    );

    // If the modal was closed without authenticating, leave the booking page.
    if (mounted && !sl.storage.isLoggedIn && back == true) {
      Navigator.pop(context);
    }
  }
}
