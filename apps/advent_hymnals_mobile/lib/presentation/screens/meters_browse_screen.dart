import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class MetersBrowseScreen extends StatefulWidget {
  const MetersBrowseScreen({super.key});

  @override
  State<MetersBrowseScreen> createState() => _MetersBrowseScreenState();
}

class _MetersBrowseScreenState extends State<MetersBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample meters data
  final List<MeterItem> _meters = [
    const MeterItem(name: 'CM', fullName: 'Common Meter', pattern: '8.6.8.6', hymnCount: 45),
    const MeterItem(name: 'LM', fullName: 'Long Meter', pattern: '8.8.8.8', hymnCount: 38),
    const MeterItem(name: 'SM', fullName: 'Short Meter', pattern: '6.6.8.6', hymnCount: 12),
    const MeterItem(name: '87.87 D', fullName: 'Double 87.87', pattern: '8.7.8.7.8.7.8.7', hymnCount: 25),
    const MeterItem(name: '76.76 D', fullName: 'Double 76.76', pattern: '7.6.7.6.7.6.7.6', hymnCount: 8),
    const MeterItem(name: '77.77 D', fullName: 'Double 77.77', pattern: '7.7.7.7.7.7.7.7', hymnCount: 6),
    const MeterItem(name: '87.87.87', fullName: 'Triple 87.87', pattern: '8.7.8.7.8.7', hymnCount: 14),
    const MeterItem(name: '10.10.10.10', fullName: 'Ten-syllable meter', pattern: '10.10.10.10', hymnCount: 9),
    const MeterItem(name: '11.11.11.11', fullName: 'Eleven-syllable meter', pattern: '11.11.11.11', hymnCount: 7),
    const MeterItem(name: '664.6664', fullName: 'Irregular meter', pattern: '6.6.4.6.6.6.4', hymnCount: 3),
    const MeterItem(name: '77.77 with Alleluias', fullName: 'Easter meter', pattern: '7.7.7.7+A', hymnCount: 4),
    const MeterItem(name: '11.12.12.10', fullName: 'Nicaea meter', pattern: '11.12.12.10', hymnCount: 1),
    const MeterItem(name: '14.14.4.78', fullName: 'Praise meter', pattern: '14.14.4.7.8', hymnCount: 1),
    const MeterItem(name: '13.13.13.13.13.13', fullName: 'Thaxted meter', pattern: '13.13.13.13.13.13', hymnCount: 1),
    const MeterItem(name: '98.98', fullName: 'Secular meter', pattern: '9.8.9.8', hymnCount: 5),
    const MeterItem(name: '86.86', fullName: 'Standard meter', pattern: '8.6.8.6', hymnCount: 15),
    const MeterItem(name: '65.65', fullName: 'Short irregular', pattern: '6.5.6.5', hymnCount: 2),
    const MeterItem(name: '54.54 D', fullName: 'Double short', pattern: '5.4.5.4.5.4.5.4', hymnCount: 3),
    const MeterItem(name: '88.88', fullName: 'Equal meter', pattern: '8.8.8.8', hymnCount: 11),
    const MeterItem(name: '12.12.12.12', fullName: 'Twelve-syllable meter', pattern: '12.12.12.12', hymnCount: 2),
  ];

  List<MeterItem> get _filteredMeters {
    if (_searchQuery.isEmpty) return _meters;
    return _meters.where((meter) =>
        meter.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meter.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meter.pattern.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.metersTitle),
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
                  'Search Meters',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Find hymns by meter pattern',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search meters...',
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
            child: _filteredMeters.isEmpty
                ? _buildEmptyState()
                : _buildMetersList(),
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
            Icons.straighten_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No meters found',
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

  Widget _buildMetersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredMeters.length,
      itemBuilder: (context, index) {
        final meter = _filteredMeters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(AppColors.secondaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const Icon(
                Icons.straighten,
                color: Color(AppColors.secondaryBlue),
              ),
            ),
            title: Text(
              meter.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  meter.fullName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'Pattern: ${meter.pattern}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray600),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  '${meter.hymnCount} hymn${meter.hymnCount == 1 ? '' : 's'}',
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
              // Navigate to hymns with this meter
              // context.push('/hymns/meter/${meter.name}');
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

class MeterItem {
  final String name;
  final String fullName;
  final String pattern;
  final int hymnCount;

  const MeterItem({
    required this.name,
    required this.fullName,
    required this.pattern,
    required this.hymnCount,
  });
}