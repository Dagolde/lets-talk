<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ProductSearchService
{
    private $rapidApiKey;
    private $googleApiKey;

    public function __construct()
    {
        $this->rapidApiKey = config('services.rapidapi.key');
        $this->googleApiKey = config('services.google.api_key');
    }

    /**
     * Search for products online using multiple APIs
     */
    public function searchProductsOnline($query, $filters = [])
    {
        $results = [];

        // Try multiple search sources
        $results = array_merge($results, $this->searchGoogleShopping($query, $filters));
        $results = array_merge($results, $this->searchAmazonProducts($query, $filters));
        $results = array_merge($results, $this->searchEbayProducts($query, $filters));

        // Remove duplicates and sort by relevance
        $results = $this->deduplicateAndSort($results);

        return array_slice($results, 0, 20); // Return top 20 results
    }

    /**
     * Search Google Shopping API
     */
    private function searchGoogleShopping($query, $filters = [])
    {
        try {
            // Using RapidAPI Google Shopping endpoint
            $response = Http::withHeaders([
                'X-RapidAPI-Key' => $this->rapidApiKey,
                'X-RapidAPI-Host' => 'google-shopping-data.p.rapidapi.com'
            ])->get('https://google-shopping-data.p.rapidapi.com/shopping/search', [
                'query' => $query,
                'country' => 'us',
                'language' => 'en',
                'limit' => 10
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $products = [];

                if (isset($data['shopping_results'])) {
                    foreach ($data['shopping_results'] as $item) {
                        $products[] = [
                            'id' => uniqid('google_'),
                            'name' => $item['title'] ?? 'Unknown Product',
                            'description' => $item['description'] ?? '',
                            'price' => $this->extractPrice($item['price'] ?? '0'),
                            'currency' => 'USD',
                            'image' => $item['image'] ?? 'https://via.placeholder.com/300x300',
                            'rating' => $item['rating'] ?? 0,
                            'reviews_count' => $item['reviews'] ?? 0,
                            'location' => $item['location'] ?? 'Online',
                            'distance' => 'Online',
                            'retailer' => 'Google Shopping',
                            'url' => $item['link'] ?? '',
                            'similarity_score' => 0.9
                        ];
                    }
                }

                return $products;
            }
        } catch (\Exception $e) {
            Log::error('Google Shopping API error: ' . $e->getMessage());
        }

        return [];
    }

    /**
     * Search Amazon products (using RapidAPI)
     */
    private function searchAmazonProducts($query, $filters = [])
    {
        try {
            $response = Http::withHeaders([
                'X-RapidAPI-Key' => $this->rapidApiKey,
                'X-RapidAPI-Host' => 'amazon-data-scraper.p.rapidapi.com'
            ])->get('https://amazon-data-scraper.p.rapidapi.com/search', [
                'query' => $query,
                'country' => 'us',
                'limit' => 10
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $products = [];

                if (isset($data['results'])) {
                    foreach ($data['results'] as $item) {
                        $products[] = [
                            'id' => uniqid('amazon_'),
                            'name' => $item['title'] ?? 'Unknown Product',
                            'description' => $item['description'] ?? '',
                            'price' => $this->extractPrice($item['price'] ?? '0'),
                            'currency' => 'USD',
                            'image' => $item['image'] ?? 'https://via.placeholder.com/300x300',
                            'rating' => $item['rating'] ?? 0,
                            'reviews_count' => $item['reviews_count'] ?? 0,
                            'location' => 'Amazon',
                            'distance' => 'Online',
                            'retailer' => 'Amazon',
                            'url' => $item['url'] ?? '',
                            'similarity_score' => 0.85
                        ];
                    }
                }

                return $products;
            }
        } catch (\Exception $e) {
            Log::error('Amazon API error: ' . $e->getMessage());
        }

        return [];
    }

    /**
     * Search eBay products (using RapidAPI)
     */
    private function searchEbayProducts($query, $filters = [])
    {
        try {
            $response = Http::withHeaders([
                'X-RapidAPI-Key' => $this->rapidApiKey,
                'X-RapidAPI-Host' => 'ebay-search-result.p.rapidapi.com'
            ])->get('https://ebay-search-result.p.rapidapi.com/search', [
                'q' => $query,
                'limit' => 10
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $products = [];

                if (isset($data['results'])) {
                    foreach ($data['results'] as $item) {
                        $products[] = [
                            'id' => uniqid('ebay_'),
                            'name' => $item['title'] ?? 'Unknown Product',
                            'description' => $item['description'] ?? '',
                            'price' => $this->extractPrice($item['price'] ?? '0'),
                            'currency' => 'USD',
                            'image' => $item['image'] ?? 'https://via.placeholder.com/300x300',
                            'rating' => 0,
                            'reviews_count' => 0,
                            'location' => 'eBay',
                            'distance' => 'Online',
                            'retailer' => 'eBay',
                            'url' => $item['url'] ?? '',
                            'similarity_score' => 0.8
                        ];
                    }
                }

                return $products;
            }
        } catch (\Exception $e) {
            Log::error('eBay API error: ' . $e->getMessage());
        }

        return [];
    }

    /**
     * Search products by image using Google Vision API
     */
    public function searchProductsByImage($imagePath, $filters = [])
    {
        try {
            // First, analyze the image to get product information
            $productInfo = $this->analyzeImage($imagePath);
            
            if ($productInfo) {
                // Search for products based on the detected information
                $query = $productInfo['description'] ?? $productInfo['labels'][0] ?? 'product';
                return $this->searchProductsOnline($query, $filters);
            }
        } catch (\Exception $e) {
            Log::error('Image search error: ' . $e->getMessage());
        }

        return [];
    }

    /**
     * Analyze image using Google Vision API
     */
    private function analyzeImage($imagePath)
    {
        try {
            $imageData = base64_encode(file_get_contents($imagePath));
            
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post("https://vision.googleapis.com/v1/images:annotate?key={$this->googleApiKey}", [
                'requests' => [
                    [
                        'image' => [
                            'content' => $imageData
                        ],
                        'features' => [
                            [
                                'type' => 'LABEL_DETECTION',
                                'maxResults' => 10
                            ],
                            [
                                'type' => 'OBJECT_LOCALIZATION',
                                'maxResults' => 5
                            ]
                        ]
                    ]
                ]
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $labels = [];
                $objects = [];

                if (isset($data['responses'][0]['labelAnnotations'])) {
                    foreach ($data['responses'][0]['labelAnnotations'] as $label) {
                        $labels[] = $label['description'];
                    }
                }

                if (isset($data['responses'][0]['localizedObjectAnnotations'])) {
                    foreach ($data['responses'][0]['localizedObjectAnnotations'] as $object) {
                        $objects[] = $object['name'];
                    }
                }

                return [
                    'labels' => $labels,
                    'objects' => $objects,
                    'description' => implode(' ', array_merge($labels, $objects))
                ];
            }
        } catch (\Exception $e) {
            Log::error('Google Vision API error: ' . $e->getMessage());
        }

        return null;
    }

    /**
     * Extract price from string
     */
    private function extractPrice($priceString)
    {
        if (is_numeric($priceString)) {
            return (float) $priceString;
        }

        // Extract numeric value from price string like "$29.99" or "29.99 USD"
        preg_match('/[\d,]+\.?\d*/', $priceString, $matches);
        if (!empty($matches)) {
            return (float) str_replace(',', '', $matches[0]);
        }

        return 0.0;
    }

    /**
     * Remove duplicates and sort by relevance
     */
    private function deduplicateAndSort($products)
    {
        $unique = [];
        $seen = [];

        foreach ($products as $product) {
            $key = strtolower(trim($product['name']));
            if (!isset($seen[$key])) {
                $seen[$key] = true;
                $unique[] = $product;
            }
        }

        // Sort by similarity score and rating
        usort($unique, function ($a, $b) {
            $scoreA = ($a['similarity_score'] * 0.7) + (($a['rating'] / 5) * 0.3);
            $scoreB = ($b['similarity_score'] * 0.7) + (($b['rating'] / 5) * 0.3);
            return $scoreB <=> $scoreA;
        });

        return $unique;
    }

    /**
     * Get fallback mock products when APIs are unavailable
     */
    public function getMockProducts($query)
    {
        return [
            [
                'id' => 1,
                'name' => "Sample Product 1 - $query",
                'description' => "This is a sample product that matches your search: $query",
                'price' => 29.99,
                'currency' => 'USD',
                'image' => 'https://via.placeholder.com/300x300',
                'rating' => 4.5,
                'reviews_count' => 128,
                'location' => 'Online Store',
                'distance' => 'Online',
                'retailer' => 'Sample Store',
                'url' => 'https://example.com/product1',
                'similarity_score' => 0.9
            ],
            [
                'id' => 2,
                'name' => "Sample Product 2 - $query",
                'description' => "Another sample product related to: $query",
                'price' => 45.00,
                'currency' => 'USD',
                'image' => 'https://via.placeholder.com/300x300',
                'rating' => 4.2,
                'reviews_count' => 89,
                'location' => 'Online Store',
                'distance' => 'Online',
                'retailer' => 'Sample Store',
                'url' => 'https://example.com/product2',
                'similarity_score' => 0.8
            ]
        ];
    }
}
