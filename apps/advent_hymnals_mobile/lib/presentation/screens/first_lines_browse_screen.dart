import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class FirstLinesBrowseScreen extends StatefulWidget {
  const FirstLinesBrowseScreen({super.key});

  @override
  State<FirstLinesBrowseScreen> createState() => _FirstLinesBrowseScreenState();
}

class _FirstLinesBrowseScreenState extends State<FirstLinesBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample first lines data
  final List<FirstLineItem> _firstLines = [
    const FirstLineItem(firstLine: 'A mighty fortress is our God', hymnNumber: 46, author: 'Martin Luther'),
    const FirstLineItem(firstLine: 'Abide with me; fast falls the eventide', hymnNumber: 635, author: 'Henry Francis Lyte'),
    const FirstLineItem(firstLine: 'All creatures of our God and King', hymnNumber: 62, author: 'Francis of Assisi'),
    const FirstLineItem(firstLine: 'All hail the power of Jesus\' name', hymnNumber: 223, author: 'Edward Perronet'),
    const FirstLineItem(firstLine: 'Amazing grace! How sweet the sound', hymnNumber: 378, author: 'John Newton'),
    const FirstLineItem(firstLine: 'Be still, my soul: the Lord is on thy side', hymnNumber: 565, author: 'Katharina von Schlegel'),
    const FirstLineItem(firstLine: 'Blessed assurance, Jesus is mine', hymnNumber: 462, author: 'Fanny Crosby'),
    const FirstLineItem(firstLine: 'Christ the Lord is risen today', hymnNumber: 205, author: 'Charles Wesley'),
    const FirstLineItem(firstLine: 'Come, thou almighty King', hymnNumber: 101, author: 'Charles Wesley'),
    const FirstLineItem(firstLine: 'Crown him with many crowns', hymnNumber: 274, author: 'Matthew Bridges'),
    const FirstLineItem(firstLine: 'Eternal Father, strong to save', hymnNumber: 608, author: 'William Whiting'),
    const FirstLineItem(firstLine: 'Faith of our fathers, living still', hymnNumber: 570, author: 'Frederick Faber'),
    const FirstLineItem(firstLine: 'Great is thy faithfulness', hymnNumber: 89, author: 'Thomas Chisholm'),
    const FirstLineItem(firstLine: 'Guide me, O thou great Jehovah', hymnNumber: 618, author: 'William Williams'),
    const FirstLineItem(firstLine: 'Hark! the herald angels sing', hymnNumber: 133, author: 'Charles Wesley'),
    const FirstLineItem(firstLine: 'Holy, holy, holy! Lord God Almighty', hymnNumber: 26, author: 'Reginald Heber'),
    const FirstLineItem(firstLine: 'How firm a foundation', hymnNumber: 529, author: 'K in Rippon\'s Selection'),
    const FirstLineItem(firstLine: 'I love to tell the story', hymnNumber: 490, author: 'A. Catherine Hankey'),
    const FirstLineItem(firstLine: 'Immortal, invisible, God only wise', hymnNumber: 263, author: 'Walter Chalmers Smith'),
    const FirstLineItem(firstLine: 'In the cross of Christ I glory', hymnNumber: 195, author: 'John Bowring'),
    const FirstLineItem(firstLine: 'Jesus loves me! This I know', hymnNumber: 113, author: 'Anna Warner'),
    const FirstLineItem(firstLine: 'Jesus shall reign where\'er the sun', hymnNumber: 540, author: 'Isaac Watts'),
    const FirstLineItem(firstLine: 'Joyful, joyful, we adore thee', hymnNumber: 4, author: 'Henry van Dyke'),
    const FirstLineItem(firstLine: 'Just as I am, without one plea', hymnNumber: 442, author: 'Charlotte Elliott'),
    const FirstLineItem(firstLine: 'Let all the world in every corner sing', hymnNumber: 167, author: 'George Herbert'),
    const FirstLineItem(firstLine: 'Love divine, all loves excelling', hymnNumber: 366, author: 'Charles Wesley'),
    const FirstLineItem(firstLine: 'Nearer, my God, to thee', hymnNumber: 472, author: 'Sarah Adams'),
    const FirstLineItem(firstLine: 'O for a thousand tongues to sing', hymnNumber: 1, author: 'Charles Wesley'),
    const FirstLineItem(firstLine: 'O God, our help in ages past', hymnNumber: 117, author: 'Isaac Watts'),
    const FirstLineItem(firstLine: 'Praise to the Lord, the Almighty', hymnNumber: 139, author: 'Joachim Neander'),
    const FirstLineItem(firstLine: 'Rock of ages, cleft for me', hymnNumber: 361, author: 'Augustus Toplady'),
    const FirstLineItem(firstLine: 'Silent night, holy night', hymnNumber: 145, author: 'Joseph Mohr'),
    const FirstLineItem(firstLine: 'The church\'s one foundation', hymnNumber: 347, author: 'Samuel Stone'),
    const FirstLineItem(firstLine: 'When I survey the wondrous cross', hymnNumber: 188, author: 'Isaac Watts'),
    const FirstLineItem(firstLine: 'What a friend we have in Jesus', hymnNumber: 629, author: 'Joseph Scriven'),
  ];

  List<FirstLineItem> get _filteredFirstLines {
    if (_searchQuery.isEmpty) return _firstLines;
    return _firstLines.where((firstLine) =>
        firstLine.firstLine.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        firstLine.author.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.firstLinesTitle),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            color: const Color(AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search First Lines',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Find hymns by first line or author',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search first lines or authors...',
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
            child: _filteredFirstLines.isEmpty
                ? _buildEmptyState()
                : _buildFirstLinesList(),
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
          const Icon(
            Icons.format_quote_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No first lines found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(AppColors.gray700),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Try adjusting your search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstLinesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredFirstLines.length,
      itemBuilder: (context, index) {
        final firstLine = _filteredFirstLines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(AppColors.gray700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Center(
                child: Text(
                  firstLine.hymnNumber.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(AppColors.gray700),
                  ),
                ),
              ),
            ),
            title: Text(
              firstLine.firstLine,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'By ${firstLine.author}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'Hymn #${firstLine.hymnNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray700),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(AppColors.gray500),
            ),
            onTap: () {
              try {
                // Navigate to hymn detail
                context.push('/hymn/${firstLine.hymnNumber}');
              } catch (e) {
                // Handle navigation error in tests
                print('Navigation error: $e');
              }
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

class FirstLineItem {
  final String firstLine;
  final int hymnNumber;
  final String author;

  const FirstLineItem({
    required this.firstLine,
    required this.hymnNumber,
    required this.author,
  });
}