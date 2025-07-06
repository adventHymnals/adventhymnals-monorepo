import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/hymnal_provider.dart';
import '../widgets/app_drawer.dart';

class BrowseScreen extends StatefulWidget {
  final String? category;
  final String? selectedItem;

  const BrowseScreen({
    super.key,
    this.category,
    this.selectedItem,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Authors', 'Composers', 'Themes', 'Tunes', 'Meters'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // Set initial tab based on category
    if (widget.category != null) {
      final categoryIndex = _getCategoryIndex(widget.category!);
      _tabController.index = categoryIndex;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HymnalProvider>().loadBrowseData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getCategoryIndex(String category) {
    switch (category.toLowerCase()) {
      case 'authors':
        return 0;
      case 'composers':
        return 1;
      case 'themes':
        return 2;
      case 'tunes':
        return 3;
      case 'meters':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<HymnalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBrowseData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.browseDataError != null) {
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
                    'Error Loading Browse Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.browseDataError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadBrowseData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBrowseList(context, provider.authors, 'author'),
              _buildBrowseList(context, provider.composers, 'composer'),
              _buildBrowseList(context, provider.themes, 'theme'),
              _buildBrowseList(context, provider.tunes, 'tune'),
              _buildBrowseList(context, provider.meters, 'meter'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrowseList(BuildContext context, List<dynamic> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(type),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type}s found',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildBrowseItem(context, item, type);
      },
    );
  }

  Widget _buildBrowseItem(BuildContext context, dynamic item, String type) {
    final String name = _getItemName(item, type);
    final int count = _getItemCount(item, type);
    final bool isSelected = widget.selectedItem == name;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getIconForType(type),
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('$count hymn${count != 1 ? 's' : ''}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToBrowseDetail(context, type, name),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'author':
        return Icons.person;
      case 'composer':
        return Icons.music_note;
      case 'theme':
        return Icons.category;
      case 'tune':
        return Icons.queue_music;
      case 'meter':
        return Icons.straighten;
      default:
        return Icons.list;
    }
  }

  String _getItemName(dynamic item, String type) {
    switch (type) {
      case 'author':
        return item.author;
      case 'composer':
        return item.composer;
      case 'theme':
        return item.theme;
      case 'tune':
        return item.tune;
      case 'meter':
        return item.meter;
      default:
        return 'Unknown';
    }
  }

  int _getItemCount(dynamic item, String type) {
    return item.count;
  }

  void _navigateToBrowseDetail(BuildContext context, String type, String name) {
    final encodedName = Uri.encodeComponent(name);
    switch (type) {
      case 'author':
        context.go('/browse/authors/$encodedName');
        break;
      case 'composer':
        context.go('/browse/composers/$encodedName');
        break;
      case 'theme':
        context.go('/browse/themes/$encodedName');
        break;
      case 'tune':
        context.go('/browse/tunes/$encodedName');
        break;
      case 'meter':
        context.go('/browse/meters/$encodedName');
        break;
    }
  }
}