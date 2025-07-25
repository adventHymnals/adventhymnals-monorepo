import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/database/database_helper.dart';
import '../widgets/banner_ad_widget.dart';

class BrowseHubScreen extends StatefulWidget {
  const BrowseHubScreen({super.key});

  @override
  State<BrowseHubScreen> createState() => _BrowseHubScreenState();
}

class _BrowseHubScreenState extends State<BrowseHubScreen> {
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = DatabaseHelper.instance;
      final database = await db.database;
      
      // Load various statistics from database
      final results = await Future.wait([
        database.rawQuery('SELECT COUNT(*) as count FROM hymns'),
        database.rawQuery('SELECT COUNT(DISTINCT author_name) as count FROM hymns WHERE author_name IS NOT NULL'),
        database.rawQuery('SELECT COUNT(*) as count FROM topics'),
        database.rawQuery('SELECT COUNT(*) as count FROM collections'),
        database.rawQuery('SELECT COUNT(DISTINCT tune_name) as count FROM hymns WHERE tune_name IS NOT NULL'),
        database.rawQuery('SELECT COUNT(DISTINCT meter) as count FROM hymns WHERE meter IS NOT NULL'),
      ]);
      
      setState(() {
        _stats = {
          'hymns': results[0].first['count'] as int,
          'authors': results[1].first['count'] as int,
          'topics': results[2].first['count'] as int,
          'collections': results[3].first['count'] as int,
          'tunes': results[4].first['count'] as int,
          'meters': results[5].first['count'] as int,
        };
      });
    } catch (e) {
      print('Error loading stats: $e');
      // Fallback to default values
      setState(() {
        _stats = {
          'hymns': 0,
          'authors': 0,
          'topics': 0,
          'collections': 0,
          'tunes': 0,
          'meters': 0,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.browseTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.go('/home');
            } catch (e) {
              print('❌ [BrowseHubScreen] Navigation error: $e');
              // Fallback to Navigator.pop if context.go fails
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          tooltip: 'Back to Home',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Explore Hymns',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Browse hymns by different categories',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(AppColors.gray700),
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Browse Categories Grid
            _buildBrowseGrid(context),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Banner Ad
            const BannerAdWidget(),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Quick Stats
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseGrid(BuildContext context) {
    final browseItems = [
      const BrowseItem(
        icon: Icons.library_books,
        title: AppStrings.collectionsTitle,
        subtitle: 'Browse by hymnal collections',
        color: Color(AppColors.primaryBlue),
        route: '/browse/collections',
      ),
      const BrowseItem(
        icon: Icons.person,
        title: AppStrings.authorsTitle,
        subtitle: 'Find hymns by author',
        color: Color(AppColors.successGreen),
        route: '/browse/authors',
      ),
      const BrowseItem(
        icon: Icons.music_note,
        title: 'Composers',
        subtitle: 'Find hymns by composer',
        color: Color(AppColors.infoBlue),
        route: '/browse/composers',
      ),
      const BrowseItem(
        icon: Icons.category,
        title: AppStrings.topicsTitle,
        subtitle: 'Browse by theme and topic',
        color: Color(AppColors.purple),
        route: '/browse/topics',
      ),
      const BrowseItem(
        icon: Icons.queue_music,
        title: AppStrings.tunesTitle,
        subtitle: 'Search by tune name',
        color: Color(AppColors.warningOrange),
        route: '/browse/tunes',
      ),
      const BrowseItem(
        icon: Icons.straighten,
        title: AppStrings.metersTitle,
        subtitle: 'Find hymns by meter',
        color: Color(AppColors.secondaryBlue),
        route: '/browse/meters',
      ),
      const BrowseItem(
        icon: Icons.menu_book,
        title: AppStrings.scriptureTitle,
        subtitle: 'Browse by scripture reference',
        color: Color(AppColors.errorRed),
        route: '/browse/scripture',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getResponsiveColumnCount(context),
        crossAxisSpacing: AppSizes.spacing12,
        mainAxisSpacing: AppSizes.spacing12,
        childAspectRatio: 1.1,
      ),
      itemCount: browseItems.length,
      itemBuilder: (context, index) {
        final item = browseItems[index];
        return _buildBrowseCard(context, item);
      },
    );
  }

  int _getResponsiveColumnCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints for column count
    if (screenWidth >= 1200) {
      // Desktop: 4 columns
      return 4;
    } else if (screenWidth >= 800) {
      // Large tablet: 3 columns
      return 3;
    } else if (screenWidth >= 600) {
      // Small tablet: 3 columns
      return 3;
    } else {
      // Mobile: 2 columns
      return 2;
    }
  }

  Widget _buildBrowseCard(BuildContext context, BrowseItem item) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push(item.route);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Icon(
                  item.icon,
                  size: AppSizes.iconSizeLarge,
                  color: item.color,
                ),
              ),
              const SizedBox(height: AppSizes.spacing12),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacing4),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppColors.gray600),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: const Color(AppColors.background),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: const Color(AppColors.gray300),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.library_books,
                  title: _stats['hymns']?.toString() ?? '0',
                  subtitle: 'Total Hymns',
                  color: const Color(AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.person,
                  title: _stats['authors']?.toString() ?? '0',
                  subtitle: 'Authors',
                  color: const Color(AppColors.successGreen),
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.category,
                  title: _stats['topics']?.toString() ?? '0',
                  subtitle: 'Topics',
                  color: const Color(AppColors.purple),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.collections,
                  title: _stats['collections']?.toString() ?? '0',
                  subtitle: 'Collections',
                  color: const Color(AppColors.warningOrange),
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.music_note,
                  title: _stats['tunes']?.toString() ?? '0',
                  subtitle: 'Tunes',
                  color: const Color(AppColors.secondaryBlue),
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.straighten,
                  title: _stats['meters']?.toString() ?? '0',
                  subtitle: 'Meters',
                  color: const Color(AppColors.errorRed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppSizes.iconSizeLarge,
          color: color,
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(AppColors.gray600),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class BrowseItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const BrowseItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}