import 'package:flutter/material.dart';
import 'package:flutter_tdl/services/download_settings_service.dart';
import 'package:flutter_tdl/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'services/tdl_service.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/download_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/forward_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/migrate_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tdlService = TdlService();
  final settingsService = SettingsService();
  final downloadSettingsService = DownloadSettingsService();

  await tdlService.init();
  await settingsService.loadSettings();
  await downloadSettingsService.loadSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tdlService),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: downloadSettingsService),
      ],
      child: const TdlFlutterApp(),
    ),
  );
}

class TdlFlutterApp extends StatelessWidget {
  const TdlFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tdl-flutter',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    LoginScreen(),
    DownloadScreen(),
    UploadScreen(),
    ForwardScreen(),
    ChatScreen(),
    MigrateScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.login_outlined),
                selectedIcon: Icon(Icons.login),
                label: Text('登录'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download_outlined),
                selectedIcon: Icon(Icons.download),
                label: Text('下载'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.upload_outlined),
                selectedIcon: Icon(Icons.upload),
                label: Text('上传'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.forward_outlined),
                selectedIcon: Icon(Icons.forward),
                label: Text('转发'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('工具'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sync_alt_outlined),
                selectedIcon: Icon(Icons.sync_alt),
                label: Text('迁移'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('设置'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
        ],
      ),
    );
  }
}
