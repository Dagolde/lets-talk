import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/product_search_provider.dart';
import '../../../../core/models/product_search.dart';

class ProductSearchResultsPage extends StatefulWidget {
  final Map<String, dynamic> searchResult;

  const ProductSearchResultsPage({
    super.key,
    required this.searchResult,
  });

  @override
  State<ProductSearchResultsPage> createState() => _ProductSearchResultsPageState();
}

class _ProductSearchResultsPageState extends State<ProductSearchResultsPage> {
  String _selectedFilter = 'all';
  String _selectedSort = 'price_low';

  @override
  Widget build(BuildContext context) {
    final products = widget.searchResult['results'] ?? widget.searchResult['products'] ?? [];
    final query = widget.searchResult['query'] ?? 'Product Search';
    final imageUrl = widget.searchResult['image_url'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(query, imageUrl),
          _buildFilterChips(),
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : _buildProductList(products),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(String query, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (imageUrl != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Found ${widget.searchResult['total'] ?? 0} products for "$query"',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50)),
            onPressed: () {
              _refreshSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Amazon', 'amazon'),
            const SizedBox(width: 8),
            _buildFilterChip('eBay', 'ebay'),
            const SizedBox(width: 8),
            _buildFilterChip('Walmart', 'walmart'),
            const SizedBox(width: 8),
            _buildFilterChip('Best Buy', 'bestbuy'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
      checkmarkColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.search),
            label: const Text('New Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<dynamic> products) {
    final filteredProducts = _filterProducts(products);
    final sortedProducts = _sortProducts(filteredProducts);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic productData) {
    Product product;
    if (productData is Product) {
      product = productData;
    } else if (productData is Map<String, dynamic>) {
      product = Product.fromJson(productData);
    } else {
      // Fallback for unexpected data types
      return const Card(
        child: ListTile(
          title: Text('Invalid product data'),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          // Product image and basic info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRetailerColor(product.retailer),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.retailer ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price comparison and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.retailer != null)
                        Text(
                          'Available at ${product.retailer}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                                         IconButton(
                       icon: const Icon(Icons.favorite_border, color: Colors.grey),
                       onPressed: () {
                         _addToWishlist(product);
                       },
                     ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _buyNow(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterProducts(List<dynamic> products) {
    if (_selectedFilter == 'all') {
      return products;
    }
    
    return products.where((product) {
      String? retailer;
      if (product is Product) {
        retailer = product.retailer;
      } else if (product is Map<String, dynamic>) {
        retailer = product['retailer'];
      }
      return retailer?.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  List<dynamic> _sortProducts(List<dynamic> products) {
    switch (_selectedSort) {
      case 'price_low':
        products.sort((a, b) {
          double priceA = _getProductPrice(a);
          double priceB = _getProductPrice(b);
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        products.sort((a, b) {
          double priceA = _getProductPrice(a);
          double priceB = _getProductPrice(b);
          return priceB.compareTo(priceA);
        });
        break;
      case 'rating':
        products.sort((a, b) {
          double ratingA = _getProductRating(a);
          double ratingB = _getProductRating(b);
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'relevance':
        products.sort((a, b) {
          double scoreA = _getProductRelevanceScore(a);
          double scoreB = _getProductRelevanceScore(b);
          return scoreB.compareTo(scoreA);
        });
        break;
    }
    return products;
  }

  double _getProductPrice(dynamic product) {
    if (product is Product) {
      return product.price;
    } else if (product is Map<String, dynamic>) {
      return (product['price'] ?? 0).toDouble();
    }
    return 0.0;
  }

  double _getProductRating(dynamic product) {
    if (product is Product) {
      return product.rating;
    } else if (product is Map<String, dynamic>) {
      return (product['rating'] ?? 0).toDouble();
    }
    return 0.0;
  }

  double _getProductRelevanceScore(dynamic product) {
    if (product is Product) {
      return product.similarityScore ?? 0.0;
    } else if (product is Map<String, dynamic>) {
      return (product['similarity_score'] ?? 0).toDouble();
    }
    return 0.0;
  }

  Color _getRetailerColor(String? retailer) {
    switch (retailer?.toLowerCase()) {
      case 'amazon':
        return Colors.orange;
      case 'ebay':
        return Colors.red;
      case 'walmart':
        return Colors.blue;
      case 'best buy':
        return Colors.blue[800]!;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Retailers', 'all'),
            _buildFilterOption('Amazon', 'amazon'),
            _buildFilterOption('eBay', 'ebay'),
            _buildFilterOption('Walmart', 'walmart'),
            _buildFilterOption('Best Buy', 'bestbuy'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (newValue) {
        setState(() {
          _selectedFilter = newValue!;
        });
      },
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Price: Low to High', 'price_low'),
            _buildSortOption('Price: High to Low', 'price_high'),
            _buildSortOption('Rating', 'rating'),
            _buildSortOption('Relevance', 'relevance'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedSort,
      onChanged: (newValue) {
        setState(() {
          _selectedSort = newValue!;
        });
      },
    );
  }

  void _refreshSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing search results...')),
    );
  }

  void _addToWishlist(dynamic product) {
    String productName;
    if (product is Product) {
      productName = product.name;
    } else if (product is Map<String, dynamic>) {
      productName = product['name'] ?? 'Unknown Product';
    } else {
      productName = 'Unknown Product';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $productName to wishlist')),
    );
  }

  void _buyNow(Product product) async {
    if (product.url != null && product.url!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(product.url!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open ${product.retailer}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening product link: $e')),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Buy ${product.name} for ${product.formattedPrice}?'),
              const SizedBox(height: 16),
              Text('Product link not available. Please search for this product on ${product.retailer}.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }
}
