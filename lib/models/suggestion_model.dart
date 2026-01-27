class SuggestionModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int order; // For sorting suggestions
  final double? latitude; // City center latitude for map navigation
  final double? longitude; // City center longitude for map navigation
  final double? zoom; // Default zoom level for city

  SuggestionModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.order,
    this.latitude,
    this.longitude,
    this.zoom,
  });

  factory SuggestionModel.fromMap(Map<String, dynamic> map, String id) {
    return SuggestionModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      order: map['order'] ?? 0,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      zoom: map['zoom']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'order': order,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (zoom != null) 'zoom': zoom,
    };
  }
}
