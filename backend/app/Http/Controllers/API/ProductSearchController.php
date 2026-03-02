<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\ProductSearch;
use App\Services\GoogleProductSearchService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProductSearchController extends Controller
{
    protected $googleProductSearchService;

    public function __construct(GoogleProductSearchService $googleProductSearchService)
    {
        $this->googleProductSearchService = $googleProductSearchService;
    }

    /**
     * Search for products using AI.
     */
    public function search(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'query' => 'nullable|string|max:500',
            'category' => 'nullable|string|max:100',
            'price_min' => 'nullable|numeric|min:0',
            'price_max' => 'nullable|numeric|min:0',
            'location' => 'nullable|string|max:255'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // If no query provided, return empty results
        if (empty($request->input('query'))) {
            $results = [];
        } else {
            // Record search with query
            ProductSearch::create([
                'user_id' => $user->id,
                'query' => $request->input('query'),
                'category' => $request->input('category'),
                'price_min' => $request->input('price_min'),
                'price_max' => $request->input('price_max'),
                'location' => $request->input('location'),
                'type' => 'text_search'
            ]);

            // Search for products using Google Search
            $filters = [
                'category' => $request->input('category'),
                'price_min' => $request->input('price_min'),
                'price_max' => $request->input('price_max'),
                'location' => $request->input('location'),
            ];

            try {
                $results = $this->googleProductSearchService->searchProducts($request->input('query'), $filters);
                
                // If no results from Google search, fall back to mock data
                if (empty($results)) {
                    $results = $this->googleProductSearchService->getFallbackProducts($request->input('query'));
                }
            } catch (\Exception $e) {
                // Log the error and fall back to mock data
                \Log::error('Google product search error: ' . $e->getMessage());
                $results = $this->googleProductSearchService->getFallbackProducts($request->input('query'));
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'results' => $results,
                'total' => count($results),
                'query' => $request->input('query') ?: null
            ]
        ]);
    }

    /**
     * Upload image for visual search.
     */
    public function uploadImage(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|max:10240', // 10MB max
            'category' => 'nullable|string|max:100',
            'description' => 'nullable|string|max:500'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Store image
        $path = $request->file('image')->store('product_searches', 'public');
        $fullPath = storage_path('app/public/' . $path);

        // Record search
        $search = ProductSearch::create([
            'user_id' => $user->id,
            'image_path' => $path,
            'category' => $request->category,
            'description' => $request->description,
            'type' => 'image_search'
        ]);

        // Search for products by image using Google Lens
        $filters = [
            'category' => $request->category,
        ];

        try {
            $results = $this->googleProductSearchService->searchProductsByImage($fullPath, $filters);
            
            // If no results from image search, fall back to mock data
            if (empty($results)) {
                $results = $this->googleProductSearchService->getFallbackProducts('image search');
            }
        } catch (\Exception $e) {
            // Log the error and fall back to mock data
            \Log::error('Google image search error: ' . $e->getMessage());
            $results = $this->googleProductSearchService->getFallbackProducts('image search');
        }

        return response()->json([
            'success' => true,
            'data' => [
                'search_id' => $search->id,
                'results' => $results,
                'total' => count($results)
            ]
        ]);
    }

    /**
     * Get search history.
     */
    public function history(Request $request)
    {
        $user = $request->user();
        
        $searches = ProductSearch::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $searches
        ]);
    }

    /**
     * Get product suggestions based on search query.
     */
    public function suggestions(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'query' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $suggestions = $this->googleProductSearchService->getProductSuggestions($request->input('query'));
            
            return response()->json([
                'success' => true,
                'data' => $suggestions
            ]);
        } catch (\Exception $e) {
            \Log::error('Product suggestions error: ' . $e->getMessage());
            
            return response()->json([
                'success' => true,
                'data' => []
            ]);
        }
    }
}
