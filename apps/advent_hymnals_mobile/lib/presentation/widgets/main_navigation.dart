import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/church_mode_service.dart';
import 'mini_audio_player.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: AppStrings.homeTitle,
      route: '/home',
    ),
    const NavigationItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: AppStrings.browseTitle,
      route: '/browse',
    ),
    const NavigationItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: AppStrings.searchTitle,
      route: '/search',
    ),
    const NavigationItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: AppStrings.favoritesTitle,
      route: '/favorites',
    ),
    const NavigationItem(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz,
      label: AppStrings.moreTitle,
      route: '/more',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
    
    // Set context for church mode service
    ChurchModeService().setContext(context);
  }

  void _updateCurrentIndex() {
    final String location = GoRouterState.of(context).uri.path;
    
    // Find the index of the current route, handling sub-routes
    for (int i = 0; i < _navigationItems.length; i++) {
      final route = _navigationItems[i].route;
      
      // Check exact match first
      if (location == route) {
        setState(() {
          _currentIndex = i;
        });
        break;
      }
      
      // Check if location starts with the route (for sub-routes)
      // For example, /browse/collections should highlight the Browse tab
      if (location.startsWith('$route/')) {
        setState(() {
          _currentIndex = i;
        });
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      final route = _navigationItems[index].route;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniAudioPlayer(),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: _navigationItems.map((item) {
          final isActive = _navigationItems.indexOf(item) == _currentIndex;
          return BottomNavigationBarItem(
            icon: _buildNavigationIcon(
              isActive ? item.activeIcon : item.icon,
              isActive,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationIcon(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive 
            ? (Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? 
               Theme.of(context).primaryColor).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Icon(
        icon,
        size: AppSizes.iconSize,
        color: isActive 
            ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
            : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

// Custom navigation indicator for enhanced visual feedback
class NavigationIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const NavigationIndicator({
    super.key,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 3,
      width: isActive ? 24 : 0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Extension to add navigation helper methods
extension NavigationExtension on BuildContext {
  void navigateToHome() => go('/home');
  void navigateToBrowse() => go('/browse');
  void navigateToSearch() => go('/search');
  void navigateToFavorites() => go('/favorites');
  void navigateToMore() => go('/more');
  
  void navigateToHymnDetail(int hymnId) => push('/hymn/$hymnId');
  void navigateToSettings() => push('/settings');
  void navigateToRecentlyViewed() => push('/recently-viewed');
  void navigateToDownloads() => push('/downloads');
  void navigateToAuthorsBrowse() => push('/browse/authors');
  void navigateToTopicsBrowse() => push('/browse/topics');
  void navigateToCollectionsBrowse() => push('/browse/collections');
}