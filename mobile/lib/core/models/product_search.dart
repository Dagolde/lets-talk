class ProductSearchResult {
  final List<Product> results;
  final int total;
  final String query;

  ProductSearchResult({
    required this.results,
    required this.total,
    required this.query,
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      results: (json['results'] as List).map((p) => Product.fromJson(p)).toList(),
      total: json['total'] ?? 0,
      query: json['query'] ?? '',
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String image;
  final double rating;
  final int reviewsCount;
  final String location;
  final String distance;
  final double? similarityScore;
  final String? retailer;
  final String? url;
  final String? type;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.image,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.distance,
    this.similarityScore,
    this.retailer,
    this.url,
    this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is String ? int.tryParse(json['id'].toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0 : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'USD',
      image: json['image'] ?? 'https://via.placeholder.com/300x300',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      location: json['location'] ?? '',
      distance: json['distance'] ?? '',
      similarityScore: json['similarity_score'] != null 
          ? double.tryParse(json['similarity_score'].toString()) ?? 0.0
          : null,
      retailer: json['retailer'],
      url: json['url'],
      type: json['type'],
    );
  }

  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';

  String get formattedRating => rating > 0 ? rating.toStringAsFixed(1) : 'N/A';

  String get formattedReviews => reviewsCount > 0 ? '$reviewsCount reviews' : 'No reviews';

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $formattedPrice, retailer: $retailer)';
  }
}
