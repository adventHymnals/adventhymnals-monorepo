import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/hymnal_provider.dart';
import '../models/hymnal.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_bar_widget.dart';

class HymnalsScreen extends StatefulWidget {
  const HymnalsScreen({super.key});

  @override
  State<HymnalsScreen> createState() => _HymnalsScreenState();
}

class _HymnalsScreenState extends State<HymnalsScreen> {
  String _searchQuery = '';
  SupportedLanguage? _selectedLanguage;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HymnalProvider>();
      if (!provider.hasData) {
        provider.loadHymnals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hymnals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('Sort by Year'),
              ),
              const PopupMenuItem(
                value: 'songs',
                child: Text('Sort by Song Count'),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<HymnalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHymnals) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.hymnalsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Hymnals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.hymnalsError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadHymnals(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final hymnals = _getFilteredAndSortedHymnals(provider.hymnalsList);

          return Column(
            children: [
              // Search and filter section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SearchBarWidget(
                      onSearch: () {
                        // Handle search within hymnals
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<SupportedLanguage?>(
                            value: _selectedLanguage,
                            decoration: const InputDecoration(
                              labelText: 'Filter by Language',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<SupportedLanguage?>(
                                value: null,
                                child: Text('All Languages'),
                              ),
                              ...SupportedLanguage.values.map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(_getLanguageName(lang)),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Results count
              if (hymnals.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${hymnals.length} hymnal${hymnals.length != 1 ? 's' : ''} found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Hymnals list
              Expanded(
                child: hymnals.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hymnals found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: hymnals.length,
                        itemBuilder: (context, index) {
                          final hymnal = hymnals[index];
                          return _buildHymnalCard(context, hymnal);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHymnalCard(BuildContext context, HymnalReference hymnal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/hymnals/${hymnal.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hymnal.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hymnal.abbreviation.isNotEmpty)
                          Text(
                            '(${hymnal.abbreviation})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.music_note,
                    label: '${hymnal.totalSongs} songs',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_today,
                    label: '${hymnal.year}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    icon: Icons.language,
                    label: hymnal.languageName,
                  ),
                ],
              ),
              
              if (hymnal.compiler != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Compiled by: ${hymnal.compiler}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              
              if (hymnal.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  hymnal.note!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<HymnalReference> _getFilteredAndSortedHymnals(List<HymnalReference> hymnals) {
    var filtered = hymnals.where((hymnal) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return hymnal.name.toLowerCase().contains(query) ||
               hymnal.abbreviation.toLowerCase().contains(query) ||
               (hymnal.compiler?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).where((hymnal) {
      if (_selectedLanguage != null) {
        return hymnal.language == _selectedLanguage;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case 'year':
        filtered.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'songs':
        filtered.sort((a, b) => b.totalSongs.compareTo(a.totalSongs));
        break;
      case 'name':
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  String _getLanguageName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.en:
        return 'English';
      case SupportedLanguage.sw:
        return 'Kiswahili';
      case SupportedLanguage.luo:
        return 'Dholuo';
      case SupportedLanguage.fr:
        return 'French';
      case SupportedLanguage.es:
        return 'Spanish';
      case SupportedLanguage.de:
        return 'German';
      case SupportedLanguage.pt:
        return 'Portuguese';
      case SupportedLanguage.it:
        return 'Italian';
    }
  }
}