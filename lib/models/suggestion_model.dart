class SuggestionModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int order; // For sorting suggestions

  SuggestionModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.order,
  });

  factory SuggestionModel.fromMap(Map<String, dynamic> map, String id) {
    return SuggestionModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'order': order,
    };
  }
}
