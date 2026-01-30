class PlaceModel {
  final String id;
  final String name;
  final String city;
  final String image;
  final String shortHistory;
  final String fullHistory;
  final double latitude;
  final double longitude;

  PlaceModel({
    required this.id,
    required this.name,
    required this.city,
    required this.image,
    required this.shortHistory,
    required this.fullHistory,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map, String id) {
    return PlaceModel(
      id: id,
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      image: map['image'] ?? '',
      shortHistory: map['shortHistory'] ?? '',
      fullHistory: map['fullHistory'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'image': image,
      'shortHistory': shortHistory,
      'fullHistory': fullHistory,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
