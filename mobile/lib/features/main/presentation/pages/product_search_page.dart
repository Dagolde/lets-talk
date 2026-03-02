import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/product_search_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../product_search/presentation/pages/product_search_results_page.dart';
import 'embedded_google_search_page.dart';
import 'google_lens_search_page.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductSearchProvider>().loadSearchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProductSearchProvider>(
        builder: (context, productSearchProvider, child) {
          return Column(
            children: [
              // Search Options
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'AI-Powered Product Search',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Take a photo of any product to find it online',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _takePhoto();
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _pickFromGallery();
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Google Search Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmbeddedGoogleSearchPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Google Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GoogleLensSearchPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Google Lens'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Text Search
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for products...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  _executeTextSearch(_searchController.text);
                                }
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length >= 2) {
                              _loadSuggestions(value);
                            } else {
                              setState(() {
                                _showSuggestions = false;
                                _suggestions.clear();
                              });
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _executeTextSearch(value);
                            }
                          },
                        ),
                        // Search Suggestions
                        if (_showSuggestions && _suggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                return ListTile(
                                  leading: const Icon(Icons.search, color: Colors.grey),
                                  title: Text(suggestion),
                                  onTap: () {
                                    _searchController.text = suggestion;
                                    setState(() {
                                      _showSuggestions = false;
                                    });
                                    _executeTextSearch(suggestion);
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Search History
              Expanded(
                child: productSearchProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      )
                    : productSearchProvider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${productSearchProvider.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    productSearchProvider.clearError();
                                    productSearchProvider.loadSearchHistory();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : productSearchProvider.searchHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No product searched yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Search for products to see results here',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Try searching for:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        _buildSearchSuggestionChip('iPhone 15'),
                                        _buildSearchSuggestionChip('Samsung TV'),
                                        _buildSearchSuggestionChip('Nike shoes'),
                                        _buildSearchSuggestionChip('MacBook Pro'),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: productSearchProvider.searchHistory.length,
                                itemBuilder: (context, index) {
                                  final search = productSearchProvider.searchHistory[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey[200],
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      title: Text(
                                        search.query ?? 'Image Search',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Found ${search.total} products',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            'Search completed',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'completed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductSearchResultsPage(searchResult: {
                                              'results': search.results,
                                              'query': search.query ?? 'Image Search',
                                              'total': search.total,
                                            }),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (photo != null) {
        await _processImage(File(photo.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _processImage(File imageFile) async {
    final productSearchProvider = context.read<ProductSearchProvider>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing image...'),
          ],
        ),
      ),
    );

    try {
      final result = await productSearchProvider.searchProductByImage(imageFile);
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductSearchResultsPage(searchResult: {
              'results': result.results,
              'query': 'Image Search',
              'total': result.total,
              'image_url': imageFile.path,
            }),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products found for this image')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }



  Widget _buildSearchSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () {
        _searchController.text = suggestion;
        _executeTextSearch(suggestion);
      },
      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
      labelStyle: const TextStyle(
        color: Color(0xFF4CAF50),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final response = await ApiService().getProductSuggestions(query);
      if (response.success && response.data != null) {
        setState(() {
          _suggestions = response.data!;
          _showSuggestions = true;
        });
      }
    } catch (e) {
      // Silently handle suggestion errors
      print('Error loading suggestions: $e');
    }
  }

  Future<void> _executeTextSearch(String query) async {
    final productSearchProvider = context.read<ProductSearchProvider>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Searching products...'),
          ],
        ),
      ),
    );

    try {
      final result = await productSearchProvider.searchProduct(query);
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductSearchResultsPage(searchResult: {
              'results': result.results,
              'query': query,
              'total': result.total,
            }),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products found')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
