"""
Test client for Legal Semantic Search API
Demonstrates how to use all the API endpoints
"""

import requests
import json
import time

# API base URL
BASE_URL = "http://localhost:8000"

def test_health():
    """Test health check endpoint"""
    print("🔍 Testing health check...")
    response = requests.get(f"{BASE_URL}/health")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ API is healthy!")
        print(f"   Total articles: {data['total_articles']}")
        print(f"   Languages: {data['languages']}")
    else:
        print(f"❌ Health check failed: {response.status_code}")
    
    print()

def test_search():
    """Test basic search endpoint"""
    print("🔍 Testing basic search...")
    
    search_data = {
        "query": "murder voluntary killing",
        "top_k": 3,
        "language_filter": None,
        "min_score": 0.65
    }
    
    response = requests.post(f"{BASE_URL}/search", json=search_data)
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Search successful!")
        print(f"   Query: '{data['query']}'")
        print(f"   Results: {data['total_results']}")
        print(f"   Processing time: {data['processing_time_ms']}ms")
        
        for i, result in enumerate(data['results'], 1):
            print(f"   {i}. Article {result['id']} ({result['language']})")
            print(f"      {result['article_label']}")
            print(f"      Similarity: {result['similarity_score']:.4f}")
    else:
        print(f"❌ Search failed: {response.status_code}")
        print(f"   Error: {response.text}")
    
    print()

def test_cross_lingual_search():
    """Test cross-lingual search endpoint"""
    print("🔍 Testing cross-lingual search...")
    
    search_data = {
        "query": "murder killing",
        "target_language": "fr",
        "min_score": 0.50
    }
    
    response = requests.post(f"{BASE_URL}/search/cross-lingual", json=search_data)
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Cross-lingual search successful!")
        print(f"   Query: '{data['query']}' → French results")
        print(f"   Results: {data['total_results']}")
        print(f"   Processing time: {data['processing_time_ms']}ms")
        
        for i, result in enumerate(data['results'], 1):
            print(f"   {i}. Article {result['id']} ({result['language']})")
            print(f"      {result['article_label']}")
            print(f"      Similarity: {result['similarity_score']:.4f}")
    else:
        print(f"❌ Cross-lingual search failed: {response.status_code}")
        print(f"   Error: {response.text}")
    
    print()

def test_get_translations():
    """Test translation lookup endpoint"""
    print("🔍 Testing translation lookup...")
    
    article_id = 107  # Murder article
    response = requests.get(f"{BASE_URL}/article/{article_id}/translations")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Translation lookup successful!")
        print(f"   Article ID: {data['article_id']}")
        print(f"   Translations found: {len(data['translations'])}")
        
        for trans in data['translations']:
            print(f"   - {trans['language']}: {trans['article_label']}")
    else:
        print(f"❌ Translation lookup failed: {response.status_code}")
        print(f"   Error: {response.text}")
    
    print()

def test_get_article():
    """Test specific article lookup"""
    print("🔍 Testing specific article lookup...")
    
    article_id = 107
    language = "en"
    response = requests.get(f"{BASE_URL}/article/{article_id}?language={language}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Article lookup successful!")
        print(f"   Article {data['id']} ({data['language']})")
        print(f"   Label: {data['article_label']}")
        print(f"   Text: {data['article_text'][:100]}...")
    else:
        print(f"❌ Article lookup failed: {response.status_code}")
        print(f"   Error: {response.text}")
    
    print()

def test_quick_search():
    """Test quick search endpoint (GET)"""
    print("🔍 Testing quick search (GET)...")
    
    params = {
        "q": "genocide crime",
        "top_k": 2,
        "lang": "en",
        "min_score": 0.5
    }
    
    response = requests.get(f"{BASE_URL}/search", params=params)
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Quick search successful!")
        print(f"   Query: '{data['query']}'")
        print(f"   Results: {data['total_results']}")
        
        for i, result in enumerate(data['results'], 1):
            print(f"   {i}. Article {result['id']} - {result['article_label']}")
            print(f"      Similarity: {result['similarity_score']:.4f}")
    else:
        print(f"❌ Quick search failed: {response.status_code}")
        print(f"   Error: {response.text}")
    
    print()

def test_stats():
    """Test stats endpoint"""
    print("🔍 Testing stats endpoint...")
    
    response = requests.get(f"{BASE_URL}/stats")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Stats retrieved successfully!")
        print(f"   Total articles: {data['total_articles']}")
        print(f"   Unique articles: {data['unique_articles']}")
        print(f"   Languages: {data['languages']}")
        print(f"   Model: {data['model_info']['model_name']}")
        print(f"   Embedding dimension: {data['model_info']['embedding_dimension']}")
    else:
        print(f"❌ Stats failed: {response.status_code}")
        print(f"   Error: {response.text}")
    
    print()

def run_all_tests():
    """Run all API tests"""
    print("=" * 80)
    print("Legal Semantic Search API - Test Suite")
    print("=" * 80)
    print(f"Testing API at: {BASE_URL}")
    print()
    
    # Wait for API to be ready
    print("⏳ Waiting for API to be ready...")
    max_retries = 30
    for i in range(max_retries):
        try:
            response = requests.get(f"{BASE_URL}/health", timeout=5)
            if response.status_code == 200:
                print("✅ API is ready!")
                break
        except requests.exceptions.RequestException:
            pass
        
        if i == max_retries - 1:
            print("❌ API is not responding. Make sure to start the server with:")
            print("   python legal_search_api.py")
            return
        
        time.sleep(2)
    
    print()
    
    # Run all tests
    test_health()
    test_search()
    test_cross_lingual_search()
    test_get_translations()
    test_get_article()
    test_quick_search()
    test_stats()
    
    print("=" * 80)
    print("✅ All tests completed!")
    print("=" * 80)

if __name__ == "__main__":
    run_all_tests()
