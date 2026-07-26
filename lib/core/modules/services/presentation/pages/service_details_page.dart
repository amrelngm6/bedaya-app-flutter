import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/presentation/widgets/success_story_card.dart';
import 'package:bedaya2/core/modules/videos/presentation/widgets/video_player_widget.dart';
import 'package:bedaya2/presentation/widgets/photo_gallery_widget.dart';
import 'package:bedaya2/core/modules/services/presentation/widgets/service_feature_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;

class ServiceDetailsPage extends StatefulWidget {
  final HospitalServiceApiModel service;

  const ServiceDetailsPage({super.key, required this.service});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    sl.analytics.trackScreen('ServiceDetailsPage - ${widget.service.title}');
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
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _buildHeroSection(),
                _buildTitleSection(),
                _buildTabBar(),
                _buildTabContent(),
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
      flexibleSpace: FlexibleSpaceBar(
        title: _showTitle
            ? Text(
                widget.service.titleLocalized(context),
                style: AppStyles.h3.copyWith(color: Colors.white, fontSize: 16),
              )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.service.coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.lightBlueBackground,
                  child: const Icon(
                    Icons.image,
                    size: 80,
                    color: AppColors.primaryTeal,
                  ),
                );
              },
            ),
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

  Widget _buildHeroSection() {
    if (widget.service.videos.isNotEmpty) {
      final introVideo = widget.service.videos.first;
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            sl.analytics.trackTap(
              'watch_intro_video_tap',
              screenName: '${'Watch Service'.tr()} - ${widget.service.title}',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerWidget(
                  videoUrl: introVideo.videoUrl,
                  title: '${'Introduction to'.tr()} ${widget.service.title}',
                ),
              ),
            );
          },
          icon: const Icon(Icons.play_circle_filled, size: 28),
          label: Text(
            'Watch Introduction Video'.tr(),
            style: AppStyles.buttonText,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.service.titleLocalized(context),
            style: AppStyles.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            widget.service.category.tr(),
            style: AppStyles.bodyLarge.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.ratingGold, size: 20),
              const SizedBox(width: 4),
              Text(
                (widget.service.successRate ?? 0.0).toStringAsFixed(1),
                style: AppStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                '(${widget.service.successStories.length} ${'reviews'.tr()})',
                style: AppStyles.bodyMedium,
              ),
              const Spacer(),
              if (widget.service.durationDays != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.darkTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.service.durationDays} ${'days'.tr()}',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.darkTeal,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.darkTeal,
        indicatorWeight: 3,
        labelStyle: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'overview'.tr()),
          Tab(text: 'gallery'.tr()),
          Tab(text: 'videos'.tr()),
          Tab(text: 'stories'.tr()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildGalleryTab(),
          _buildVideosTab(),
          _buildSuccessStoriesTab(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MarkdownBody(
        data: html2md.convert(widget.service.descriptionLocalized(context)),

        styleSheet: MarkdownStyleSheet(
          p: AppStyles.bodyLarge.copyWith(
            height: 1.8,
            fontSize: 14,
            color: const Color(0xFF2C3E50),
          ),
          h1: AppStyles.h1.copyWith(
            fontSize: 20,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
          h2: AppStyles.h2.copyWith(
            fontSize: 18,
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
          listIndent: 20,
          blockquotePadding: const EdgeInsets.all(16),
          blockquoteDecoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: AppColors.primaryTeal, width: 4),
            ),
          ),
        ),
        // Limit to 100 characters
        // style: AppStyles.bodyMedium.copyWith(
        //   color: Colors.blueGrey,
        //   fontSize: 14,
        // ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About This Service'.tr(), style: AppStyles.h2),
          const SizedBox(height: 12),
          _buildContent(),

          // Text(
          //   widget.service.description,
          //   style: AppStyles.bodyLarge.copyWith(height: 1.6),
          // ),
          const SizedBox(height: 24),
          if (widget.service.features.isNotEmpty) ...[
            Text('Key Features'.tr(), style: AppStyles.h2),
            const SizedBox(height: 16),
            ...widget.service.features.map(
              (feature) => ServiceFeatureCard(feature: feature),
            ),
          ],
          const SizedBox(height: 24),
          if (widget.service.benefits.isNotEmpty) ...[
            Text('Benefits'.tr(), style: AppStyles.h2),
            const SizedBox(height: 16),
            ...widget.service.benefits.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.lightBlueBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppStyles.bodyLarge.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return PhotoGalleryWidget(photos: const []);
  }

  Widget _buildVideosTab() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.service.videos.length,
        itemBuilder: (context, index) {
          final video = widget.service.videos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(ServiceVideoApiModel video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: video.thumbnailUrl != null
                      ? Image.network(
                          video.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.lightBlueBackground,
                              child: const Icon(
                                Icons.videocam,
                                size: 60,
                                color: AppColors.primaryTeal,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.lightBlueBackground,
                          child: const Icon(
                            Icons.videocam,
                            size: 60,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerWidget(
                                videoUrl: video.videoUrl,
                                title: video.title,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(video.durationSeconds),
                      style: AppStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                video.title,
                style: AppStyles.h3.copyWith(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStoriesTab() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.service.successStories.length,
        itemBuilder: (context, index) {
          final story = widget.service.successStories[index];
          return SuccessStoryCard(story: story);
        },
      ),
    );
  }

  // String? _formatPrice() {
  //   if (widget.service.priceFrom == null) return null;
  //   final currency = widget.service.currency ?? '';
  //   final from = widget.service.priceFrom!.toStringAsFixed(0);
  //   if (widget.service.priceTo != null) {
  //     return '$currency $from – ${widget.service.priceTo!.toStringAsFixed(0)}';
  //   }
  //   return '$currency $from';
  // }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
