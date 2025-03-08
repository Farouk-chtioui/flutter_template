class ScreenModel {
  final String id;
  final String name;
  final String route;
  final String screenType;
  final String? description;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  ScreenModel({
    required this.id,
    required this.name,
    required this.route,
    required this.screenType,
    this.description,
    required this.settings,
    required this.metadata,
    required this.tags,
  });

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    return ScreenModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled',
      route: json['route'] as String? ?? '/',
      screenType: json['screenType'] as String? ?? 'default',
      description: json['description'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }
}
