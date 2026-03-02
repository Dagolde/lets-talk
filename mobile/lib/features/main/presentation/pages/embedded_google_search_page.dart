import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EmbeddedGoogleSearchPage extends StatefulWidget {
  const EmbeddedGoogleSearchPage({Key? key}) : super(key: key);

  @override
  _EmbeddedGoogleSearchPageState createState() => _EmbeddedGoogleSearchPageState();
}

class _EmbeddedGoogleSearchPageState extends State<EmbeddedGoogleSearchPage> {
  late WebViewController _webViewController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _checkNavigationState();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle external product links
            if (_isProductLink(request.url)) {
              _launchProductLink(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  bool _isProductLink(String url) {
    // Check if the URL is a product purchase link
    final productDomains = [
      'amazon.com',
      'ebay.com',
      'walmart.com',
      'target.com',
      'bestbuy.com',
      'homedepot.com',
      'lowes.com',
      'newegg.com',
      'bhphotovideo.com',
      'adorama.com',
      'shop.google.com',
    ];

    return productDomains.any((domain) => url.contains(domain));
  }

  void _launchProductLink(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening product link in browser...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open product link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening product link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkNavigationState() async {
    final canGoBack = await _webViewController.canGoBack();
    final canGoForward = await _webViewController.canGoForward();
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
      _webViewController.loadRequest(Uri.parse(searchUrl));
    }
  }

  void _goToGoogleShopping(String query) {
    if (query.isNotEmpty) {
      final shoppingUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}&tbm=shop';
      _webViewController.loadRequest(Uri.parse(shoppingUrl));
    }
  }

  void _goToGoogleImages(String query) {
    if (query.isNotEmpty) {
      final imagesUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}&tbm=isch';
      _webViewController.loadRequest(Uri.parse(imagesUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Product Search'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'shopping':
                  _goToGoogleShopping(_searchController.text);
                  break;
                case 'images':
                  _goToGoogleImages(_searchController.text);
                  break;
                case 'home':
                  _webViewController.loadRequest(Uri.parse('https://www.google.com'));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'shopping',
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart),
                    SizedBox(width: 8),
                    Text('Google Shopping'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'images',
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text('Google Images'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('Google Home'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for products on Google...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _webViewController.loadRequest(Uri.parse('https://www.google.com'));
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 12),
                // Search Options
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _performSearch(_searchController.text),
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _goToGoogleShopping(_searchController.text),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Shopping'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _canGoBack ? () {
                    _webViewController.goBack();
                  } : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _canGoForward ? () {
                    _webViewController.goForward();
                  } : null,
                ),
                Expanded(
                  child: Text(
                    _currentUrl,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Google Search...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _goToGoogleShopping(_searchController.text);
        },
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Shopping'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
