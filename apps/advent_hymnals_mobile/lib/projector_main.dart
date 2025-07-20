import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/theme/app_theme.dart';
import 'presentation/providers/hymn_provider.dart';
import 'core/services/projector_service.dart';
import 'presentation/screens/projector_window_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for frameless windows
  await windowManager.ensureInitialized();
  
  if (args.isNotEmpty) {
    // Parse the window configuration from args
    final config = jsonDecode(args.first) as Map<String, dynamic>;
    final hymnId = config['hymnId'] as int?;
    
    // Configure this window as a frameless projector window
    WindowOptions windowOptions = const WindowOptions(
      backgroundColor: Colors.black,
      titleBarStyle: TitleBarStyle.hidden, // Frameless
      skipTaskbar: true, // Don't show in taskbar
      alwaysOnTop: false,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(ProjectorApp(hymnId: hymnId));
  } else {
    // Fallback if no args provided
    runApp(ProjectorApp(hymnId: null));
  }
}

class ProjectorApp extends StatelessWidget {
  final int? hymnId;
  
  const ProjectorApp({super.key, this.hymnId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HymnProvider()),
        ChangeNotifierProvider(create: (_) => ProjectorService()),
      ],
      child: MaterialApp(
        title: 'Projector Display',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: ProjectorWindowScreen(hymnId: hymnId),
        builder: (context, child) {
          // Set up method channel to receive updates from main window
          DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
            if (call.method == 'updateContent') {
              final data = jsonDecode(call.arguments as String) as Map<String, dynamic>;
              final projectorService = Provider.of<ProjectorService>(context, listen: false);
              
              // Update projector service with new data
              if (data['action'] == 'update') {
                projectorService.notifyListeners();
              }
            }
          });
          
          return child ?? const SizedBox();
        },
      ),
    );
  }
}