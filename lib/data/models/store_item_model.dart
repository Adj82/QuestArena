// WHAT THIS FILE DOES:
// Defines items available for purchase in the virtual store.

class StoreItemModel {
  final String itemId;
  final String name;
  final String description;
  final String type;
  final int price;
  final String imageUrl;
  final bool isAvailable;

  StoreItemModel({
    required this.itemId,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      itemId: json['itemId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'avatar',
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'name': name,
    'description': description,
    'type': type,
    'price': price,
    'imageUrl': imageUrl,
    'isAvailable': isAvailable,
  };
}
