class HomeOfferEntity {
  final String id;
  final String imageUrl; // swap to real URL when backend is ready
  final String title;
  final double originalPrice;
  final double discountedPrice;
  final int savePercent;
  final bool isFavorite;
  final String category;
  final String storeName;

  const HomeOfferEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.savePercent,
    this.isFavorite = false,
    required this.category,
    required this.storeName,
  });

  HomeOfferEntity copyWith({bool? isFavorite}) => HomeOfferEntity(
        id: id,
        imageUrl: imageUrl,
        title: title,
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        savePercent: savePercent,
        isFavorite: isFavorite ?? this.isFavorite,
        category: category,
        storeName: storeName,
      );
}
