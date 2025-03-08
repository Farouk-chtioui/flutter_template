import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/screen_model.dart';
import 'screens/dynamic_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class OTAData {
  final Map<String, dynamic> design;
  final Map<String, dynamic> layout;
  final List<dynamic> onboarding;
  final List<ScreenModel> screens;
  final Map<String, dynamic> config;

  OTAData({
    required this.design,
    required this.layout,
    required this.onboarding,
    required this.screens,
    required this.config,
  });
}

Future<OTAData> loadOtaData() async {
  try {
    final designString = await rootBundle.loadString('assets/ota_packs/design_pack.json');
    final layoutString = await rootBundle.loadString('assets/ota_packs/layout_pack.json');
    final onboardingString = await rootBundle.loadString('assets/ota_packs/onboarding_pack.json');
    final screensString = await rootBundle.loadString('assets/ota_packs/screens_pack.json');
    final configString = await rootBundle.loadString('assets/ota_packs/config_pack.json');

    final screensList = (json.decode(screensString) as List?)
        ?.map((screen) => ScreenModel.fromJson(screen))
        .toList() ?? [];

    return OTAData(
      design: json.decode(designString),
      layout: json.decode(layoutString),
      onboarding: json.decode(onboardingString),
      screens: screensList,
      config: json.decode(configString),
    );
  } catch (e) {
    debugPrint('Error loading OTA data: $e');
    rethrow;
  }
}

Color hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.black;
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<OTAData> otaDataFuture = loadOtaData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OTAData>(
      future: otaDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error loading OTA data: ${snapshot.error ?? "Unknown error"}'),
              ),
            ),
          );
        }

        final otaData = snapshot.data!;
        final lightTheme = otaData.design['themeColors']?['light'] as Map<String, dynamic>? ?? {};

        return MaterialApp(
          title: otaData.config['appName']?.toString() ?? 'Dynamic App',
          theme: ThemeData(
            primaryColor: hexToColor(lightTheme['accent']?.toString()),
            scaffoldBackgroundColor: hexToColor(lightTheme['mainAppBackground']?.toString()),
            appBarTheme: AppBarTheme(
              backgroundColor: hexToColor(lightTheme['topBarBackground']?.toString()),
              foregroundColor: hexToColor(lightTheme['topBarTextAndIcon']?.toString()),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: hexToColor(lightTheme['bottomBarBackground']?.toString()),
              selectedItemColor: hexToColor(lightTheme['bottomBarSelectedIcon']?.toString()),
              unselectedItemColor: hexToColor(lightTheme['bottomBarUnselectedIcon']?.toString()),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: hexToColor(lightTheme['mainText']?.toString())),
              titleLarge: TextStyle(color: hexToColor(lightTheme['titleText']?.toString())),
            ),
            cardColor: hexToColor(lightTheme['secondaryBackground']?.toString()),
          ),
          home: HomePage(otaData: otaData),
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Not Found')),
                body: const Center(child: Text('Page not found')),
              ),
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final OTAData otaData;
  
  const HomePage({
    super.key, 
    required this.otaData,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<dynamic> get bottomTabs => 
      (widget.otaData.layout['bottomBarTabs'] as List<dynamic>?)?.where((tab) => 
        tab['visible'] == true).toList() ?? [];

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
    final theme = Theme.of(context);
    
    return Scaffold(
      body: screens.isEmpty 
          ? const Center(child: Text('No screens available')) 
          : screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: _buildNavItems(),
          onTap: (index) {
            if (index < screens.length) {
              setState(() => _currentIndex = index);
            }
          },
          elevation: 8,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return bottomTabs.map((tab) {
      return BottomNavigationBarItem(
        icon: Icon(_getIconFromName(tab['iconName']?.toString() ?? '')),
        label: tab['name']?.toString() ?? 'Untitled',
      );
    }).toList();
  }

  List<Widget> _buildScreens() {
    try {
      return bottomTabs.map((tab) {
        final route = (tab['route'] as String?) ?? '/';
        final screenData = widget.otaData.screens.firstWhere(
          (s) => s.route == route,
          orElse: () => ScreenModel(
            id: 'default',
            name: tab['name']?.toString() ?? 'Untitled',
            route: route,
            screenType: 'default',
            description: 'Screen not found',
            settings: {'padding': 16},
            metadata: const {},
            tags: const [],
          ),
        );
        return DynamicScreen(
          screen: screenData,
          design: widget.otaData.design,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error building screens: $e');
      return [
        const Center(child: Text('Error loading screens')),
      ];
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'shoppingcart':
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'localoffer':
        return Icons.local_offer;
      case 'accountcircle':
      case 'account':
        return Icons.account_circle;
      default:
        return Icons.device_unknown;
    }
  }
}
