import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class TunesBrowseScreen extends StatefulWidget {
  const TunesBrowseScreen({super.key});

  @override
  State<TunesBrowseScreen> createState() => _TunesBrowseScreenState();
}

class _TunesBrowseScreenState extends State<TunesBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample tunes data
  final List<TuneItem> _tunes = [
    const TuneItem(name: 'AMAZING GRACE', meter: 'CM', hymnCount: 12),
    const TuneItem(name: 'AUSTRIA', meter: '87.87 D', hymnCount: 8),
    const TuneItem(name: 'BEECHER', meter: '87.87 D', hymnCount: 5),
    const TuneItem(name: 'CORONATION', meter: 'CM', hymnCount: 3),
    const TuneItem(name: 'EASTER HYMN', meter: '77.77 with Alleluias', hymnCount: 4),
    const TuneItem(name: 'DUKE STREET', meter: 'LM', hymnCount: 15),
    const TuneItem(name: 'HYFRYDOL', meter: '87.87 D', hymnCount: 6),
    const TuneItem(name: 'ITALIAN HYMN', meter: '664.6664', hymnCount: 2),
    const TuneItem(name: 'LOBE DEN HERREN', meter: '14.14.4.78', hymnCount: 1),
    const TuneItem(name: 'MARYTON', meter: 'LM', hymnCount: 7),
    const TuneItem(name: 'NICAEA', meter: '11.12.12.10', hymnCount: 1),
    const TuneItem(name: 'OLD HUNDREDTH', meter: 'LM', hymnCount: 9),
    const TuneItem(name: 'PASSION CHORALE', meter: '76.76 D', hymnCount: 3),
    const TuneItem(name: 'PICARDY', meter: '87.87.87', hymnCount: 2),
    const TuneItem(name: 'REGENT SQUARE', meter: '87.87.87', hymnCount: 4),
    const TuneItem(name: 'ST. ANNE', meter: 'CM', hymnCount: 6),
    const TuneItem(name: 'ST. GEORGE\'S WINDSOR', meter: '77.77 D', hymnCount: 1),
    const TuneItem(name: 'THAXTED', meter: '13.13.13.13.13.13', hymnCount: 1),
    const TuneItem(name: 'VENI CREATOR', meter: 'LM', hymnCount: 2),
    const TuneItem(name: 'WESTMINSTER ABBEY', meter: '87.87.87', hymnCount: 1),
  ];

  List<TuneItem> get _filteredTunes {
    if (_searchQuery.isEmpty) return _tunes;
    return _tunes.where((tune) =>
        tune.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tune.meter.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tunesTitle),
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
                  'Search Tunes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Find hymns by tune name or meter',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tunes or meters...',
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
            child: _filteredTunes.isEmpty
                ? _buildEmptyState()
                : _buildTunesList(),
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
            Icons.music_note_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No tunes found',
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

  Widget _buildTunesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredTunes.length,
      itemBuilder: (context, index) {
        final tune = _filteredTunes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(AppColors.warningOrange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const Icon(
                Icons.music_note,
                color: Color(AppColors.warningOrange),
              ),
            ),
            title: Text(
              tune.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'Meter: ${tune.meter}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  '${tune.hymnCount} hymn${tune.hymnCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.secondaryBlue),
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
              // Navigate to hymns with this tune
              // context.push('/hymns/tune/${tune.name}');
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

class TuneItem {
  final String name;
  final String meter;
  final int hymnCount;

  const TuneItem({
    required this.name,
    required this.meter,
    required this.hymnCount,
  });
}