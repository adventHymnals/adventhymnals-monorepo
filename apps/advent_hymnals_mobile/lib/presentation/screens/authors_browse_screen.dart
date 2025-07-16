import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class AuthorsBrowseScreen extends StatefulWidget {
  const AuthorsBrowseScreen({super.key});

  @override
  State<AuthorsBrowseScreen> createState() => _AuthorsBrowseScreenState();
}

class _AuthorsBrowseScreenState extends State<AuthorsBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample authors data
  final List<AuthorItem> _authors = [
    const AuthorItem(name: 'Charles Wesley', years: '1707-1788', hymnCount: 156),
    const AuthorItem(name: 'Isaac Watts', years: '1674-1748', hymnCount: 134),
    const AuthorItem(name: 'Fanny J. Crosby', years: '1820-1915', hymnCount: 89),
    const AuthorItem(name: 'John Newton', years: '1725-1807', hymnCount: 67),
    const AuthorItem(name: 'Philip P. Bliss', years: '1838-1876', hymnCount: 45),
    const AuthorItem(name: 'John Wesley', years: '1703-1791', hymnCount: 42),
    const AuthorItem(name: 'William Cowper', years: '1731-1800', hymnCount: 38),
    const AuthorItem(name: 'Horatius Bonar', years: '1808-1889', hymnCount: 36),
    const AuthorItem(name: 'Frances R. Havergal', years: '1836-1879', hymnCount: 34),
    const AuthorItem(name: 'Charlotte Elliott', years: '1789-1871', hymnCount: 32),
    const AuthorItem(name: 'Augustus M. Toplady', years: '1740-1778', hymnCount: 28),
    const AuthorItem(name: 'Ray Palmer', years: '1808-1887', hymnCount: 26),
    const AuthorItem(name: 'Samuel Stennett', years: '1727-1795', hymnCount: 24),
    const AuthorItem(name: 'John Fawcett', years: '1740-1817', hymnCount: 22),
    const AuthorItem(name: 'Philip Doddridge', years: '1702-1751', hymnCount: 21),
    const AuthorItem(name: 'Thomas Kelly', years: '1769-1855', hymnCount: 19),
    const AuthorItem(name: 'John Keble', years: '1792-1866', hymnCount: 18),
    const AuthorItem(name: 'Thomas Ken', years: '1637-1711', hymnCount: 16),
    const AuthorItem(name: 'Samuel F. Smith', years: '1808-1895', hymnCount: 15),
    const AuthorItem(name: 'James Montgomery', years: '1771-1854', hymnCount: 14),
    const AuthorItem(name: 'John Greenleaf Whittier', years: '1807-1892', hymnCount: 13),
    const AuthorItem(name: 'William B. Bradbury', years: '1816-1868', hymnCount: 12),
    const AuthorItem(name: 'Reginald Heber', years: '1783-1826', hymnCount: 11),
    const AuthorItem(name: 'Anna L. Waring', years: '1823-1910', hymnCount: 10),
    const AuthorItem(name: 'John Mason Neale', years: '1818-1866', hymnCount: 9),
  ];

  List<AuthorItem> get _filteredAuthors {
    if (_searchQuery.isEmpty) return _authors;
    return _authors.where((author) =>
        author.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        author.years.contains(_searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.authorsTitle),
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
                  'Browse Authors',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Find hymns by author name or time period',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search authors or years...',
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
            child: _filteredAuthors.isEmpty
                ? _buildEmptyState()
                : _buildAuthorsList(),
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
            Icons.person_outline,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No authors found',
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

  Widget _buildAuthorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredAuthors.length,
      itemBuilder: (context, index) {
        final author = _filteredAuthors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(AppColors.successGreen).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const Icon(
                Icons.person,
                color: Color(AppColors.successGreen),
              ),
            ),
            title: Text(
              author.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  author.years,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  '${author.hymnCount} hymn${author.hymnCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.successGreen),
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
              // Navigate to hymns by this author (placeholder navigation to a sample hymn)
              context.push('/hymn/1');
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

class AuthorItem {
  final String name;
  final String years;
  final int hymnCount;

  const AuthorItem({
    required this.name,
    required this.years,
    required this.hymnCount,
  });
}