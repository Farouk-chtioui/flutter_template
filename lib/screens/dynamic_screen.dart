import 'package:flutter/material.dart';
import '../models/screen_model.dart';

class DynamicScreen extends StatelessWidget {
  final ScreenModel screen;
  final Map<String, dynamic> design;

  const DynamicScreen({
    super.key,
    required this.screen,
    required this.design,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final lightTheme = design['themeColors']?['light'] as Map<String, dynamic>? ?? {};
      
      return Scaffold(
        appBar: AppBar(
          title: Text(screen.name),
          backgroundColor: _safeHexToColor(lightTheme['topBarBackground']?.toString()),
          foregroundColor: _safeHexToColor(lightTheme['topBarTextAndIcon']?.toString()),
        ),
        body: _buildScreenContent(context, screen.screenType),
      );
    } catch (e) {
      debugPrint('Error building DynamicScreen: $e');
      return const Scaffold(
        body: Center(child: Text('Error loading screen')),
      );
    }
  }

  Color _safeHexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    try {
      hex = hex.replaceAll('#', '');
      hex = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('Error parsing color: $e');
      return Colors.black;
    }
  }

  Widget _buildScreenContent(BuildContext context, String screenType) {
    try {
      switch (screenType.toLowerCase()) {
        case 'content-list':
          return _buildContentList();
        case 'schedule':
          return _buildSchedule();
        case 'map':
          return _buildMap();
        default:
          return Center(child: Text('Unknown screen type: $screenType'));
      }
    } catch (e) {
      debugPrint('Error building screen content: $e');
      return const Center(child: Text('Error loading content'));
    }
  }

  Widget _buildContentList() {
    final lightTheme = design['themeColors']?['light'] as Map<String, dynamic>? ?? {};
    return GridView.builder(
      padding: EdgeInsets.all(screen.settings['padding']?.toDouble() ?? 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  _safeHexToColor(lightTheme['accent']?.toString()),
                  _safeHexToColor(lightTheme['secondaryAccent']?.toString()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'Item ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchedule() {
    final lightTheme = design['themeColors']?['light'] as Map<String, dynamic>? ?? {};
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(screen.settings['padding']?.toDouble() ?? 16.0),
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _safeHexToColor(lightTheme['accent']?.toString()),
              child: Text('${index + 1}'),
            ),
            title: Text('Event ${index + 1}'),
            subtitle: const Text('10:00 AM - 11:00 AM'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    final lightTheme = design['themeColors']?['light'] as Map<String, dynamic>? ?? {};
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 100,
            color: _safeHexToColor(lightTheme['accent']?.toString()),
          ),
          const SizedBox(height: 16),
          const Text(
            'Map View Coming Soon',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
