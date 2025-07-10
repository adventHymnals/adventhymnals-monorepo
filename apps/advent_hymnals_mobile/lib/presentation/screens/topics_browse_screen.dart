import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class TopicsBrowseScreen extends StatefulWidget {
  const TopicsBrowseScreen({super.key});

  @override
  State<TopicsBrowseScreen> createState() => _TopicsBrowseScreenState();
}

class _TopicsBrowseScreenState extends State<TopicsBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample topics data
  final List<TopicItem> _topics = [
    TopicItem(name: 'Worship and Praise', description: 'Hymns of adoration and worship', hymnCount: 187),
    TopicItem(name: 'Jesus Christ', description: 'Life, ministry, and sacrifice of Christ', hymnCount: 156),
    TopicItem(name: 'Salvation and Grace', description: 'God\'s saving grace and redemption', hymnCount: 134),
    TopicItem(name: 'Christmas', description: 'Birth and incarnation of Jesus', hymnCount: 89),
    TopicItem(name: 'Easter and Resurrection', description: 'Christ\'s death and resurrection', hymnCount: 78),
    TopicItem(name: 'Prayer and Communion', description: 'Personal relationship with God', hymnCount: 67),
    TopicItem(name: 'Faith and Trust', description: 'Trust in God\'s providence', hymnCount: 62),
    TopicItem(name: 'Love of God', description: 'God\'s love and mercy', hymnCount: 58),
    TopicItem(name: 'Comfort and Peace', description: 'God\'s comfort in trials', hymnCount: 54),
    TopicItem(name: 'Holy Spirit', description: 'Work and presence of the Spirit', hymnCount: 48),
    TopicItem(name: 'Eternal Life', description: 'Hope of heaven and eternal joy', hymnCount: 45),
    TopicItem(name: 'Christian Living', description: 'Daily walk with Christ', hymnCount: 42),
    TopicItem(name: 'Second Coming', description: 'Return of Jesus Christ', hymnCount: 38),
    TopicItem(name: 'Missions and Evangelism', description: 'Spreading the Gospel', hymnCount: 36),
    TopicItem(name: 'Repentance and Forgiveness', description: 'Turning from sin to God', hymnCount: 34),
    TopicItem(name: 'Baptism', description: 'Symbol of new life in Christ', hymnCount: 28),
    TopicItem(name: 'Communion and Lord\'s Supper', description: 'Remembrance of Christ\'s sacrifice', hymnCount: 26),
    TopicItem(name: 'Creation and Nature', description: 'God\'s creation and natural world', hymnCount: 24),
    TopicItem(name: 'Church and Fellowship', description: 'Unity of believers', hymnCount: 22),
    TopicItem(name: 'Thanksgiving', description: 'Gratitude to God', hymnCount: 21),
    TopicItem(name: 'Cross and Atonement', description: 'Christ\'s sacrifice for sin', hymnCount: 19),
    TopicItem(name: 'Bible and Word of God', description: 'Scripture and divine revelation', hymnCount: 18),
    TopicItem(name: 'Service and Dedication', description: 'Serving God and others', hymnCount: 16),
    TopicItem(name: 'Morning and Evening', description: 'Daily devotion hymns', hymnCount: 15),
    TopicItem(name: 'Trials and Suffering', description: 'Endurance through hardship', hymnCount: 14),
  ];

  List<TopicItem> get _filteredTopics {
    if (_searchQuery.isEmpty) return _topics;
    return _topics.where((topic) =>
        topic.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        topic.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.topicsTitle),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            color: Color(AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse Topics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Find hymns by theme and topic',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search topics or themes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: _filteredTopics.isEmpty
                ? _buildEmptyState()
                : _buildTopicsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No topics found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Color(AppColors.gray700),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Try adjusting your search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Color(AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) {
        final topic = _filteredTopics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(AppColors.purple).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Icon(
                Icons.category,
                color: Color(AppColors.purple),
              ),
            ),
            title: Text(
              topic.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  topic.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Color(AppColors.gray600),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  '${topic.hymnCount} hymn${topic.hymnCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Color(AppColors.purple),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(AppColors.gray500),
            ),
            onTap: () {
              // Navigate to hymns by this topic (placeholder navigation to a sample hymn)
              context.push('/hymn/2');
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class TopicItem {
  final String name;
  final String description;
  final int hymnCount;

  const TopicItem({
    required this.name,
    required this.description,
    required this.hymnCount,
  });
}