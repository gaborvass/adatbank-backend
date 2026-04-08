# Mobile App Integration Guide

This guide explains how to integrate the Hungarian Football Data API into your mobile app with API Key authentication.

## Authentication

The API uses **API Key authentication** for access control. Only requests with a valid API key can access the endpoints.

- **All endpoints** require: `X-API-Key: your-api-key` header
- **Access restricted** to your mobile app only
- **No rate limits** - your app can make as many requests as needed

## Getting Your API Key

After deployment, the API key will be in the stack outputs:

```bash
# Get API key from CloudFormation
aws cloudformation describe-stacks \
  --stack-name hungarian-football-api \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiKeyValue`].OutputValue' \
  --output text
```

**Important**: Save the API key securely. You won't be able to retrieve it again from AWS Console.

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/federations` | Get all football federations |
| GET | `/seasons` | Get all seasons |
| GET | `/basicData` | Get federations and seasons combined |
| GET | `/leagues/{seasonId}/{federationId}` | Get leagues |
| GET | `/rounds/{sId}/{fId}/{lId}` | Get rounds |
| GET | `/results/{sId}/{fId}/{lId}/{rId}` | Get match results |
| GET | `/standings/{sId}/{fId}/{lId}/{rId}` | Get standings |

## Base URL

```
https://your-api-id.execute-api.region.amazonaws.com/Prod
```

## Integration Examples

### Swift (iOS)

```swift
import Foundation

class FootballAPIClient {
    private let baseURL = "https://your-api-id.execute-api.region.amazonaws.com/Prod"
    private let apiKey = "your-api-key-here"  // Store in Keychain!

    // Store API Key securely in Keychain
    func saveAPIKey(_ key: String) {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "football-api-key",
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    // Retrieve API Key from Keychain
    func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "football-api-key",
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    private func makeRequest(to endpoint: String) -> URLRequest {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        return request
    }

    func getFederations() async throws -> [Federation] {
        let request = makeRequest(to: "/federations")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Federation].self, from: data)
    }

    func getSeasons() async throws -> [Season] {
        let request = makeRequest(to: "/seasons")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Season].self, from: data)
    }

    func getLeagues(seasonId: String, federationId: String) async throws -> [League] {
        let request = makeRequest(to: "/leagues/\(seasonId)/\(federationId)")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([League].self, from: data)
    }
}

// Models
struct Federation: Codable {
    let federationId: String
    let federationName: String
}

struct Season: Codable {
    let seasonId: String
    let seasonName: String
    let isCurrent: Bool
}

struct League: Codable {
    let leagueId: String
    let leagueName: String?
}
```

### Kotlin (Android)

```kotlin
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Request
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

// API Key storage (use EncryptedSharedPreferences for production)
object ApiKeyStorage {
    private const val PREFS_NAME = "football_api_prefs"
    private const val KEY_API_KEY = "api_key"

    fun saveApiKey(context: android.content.Context, key: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_API_KEY, key).apply()
    }

    fun getApiKey(context: android.content.Context): String? {
        val prefs = context.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        return prefs.getString(KEY_API_KEY, null)
    }
}

// API Key Interceptor
class ApiKeyInterceptor(private val apiKey: String) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): okhttp3.Response {
        val original = chain.request()
        val request = original.newBuilder()
            .header("X-API-Key", apiKey)
            .header("Content-Type", "application/json")
            .method(original.method, original.body)
            .build()
        return chain.proceed(request)
    }
}

// Retrofit API Service
interface FootballApiService {
    @GET("federations")
    suspend fun getFederations(): List<Federation>

    @GET("seasons")
    suspend fun getSeasons(): List<Season>

    @GET("leagues/{seasonId}/{federationId}")
    suspend fun getLeagues(
        @Path("seasonId") seasonId: String,
        @Path("federationId") federationId: String
    ): List<League>
}

// API Client
object FootballApiClient {
    private const val BASE_URL = "https://your-api-id.execute-api.region.amazonaws.com/Prod/"

    fun create(apiKey: String): FootballApiService {
        val client = OkHttpClient.Builder()
            .addInterceptor(ApiKeyInterceptor(apiKey))
            .build()

        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(FootballApiService::class.java)
    }
}

// Data Classes
data class Federation(
    val federationId: String,
    val federationName: String
)

data class Season(
    val seasonId: String,
    val seasonName: String,
    val isCurrent: Boolean
)

data class League(
    val leagueId: String,
    val leagueName: String?
)

// Usage
class MainActivity : AppCompatActivity() {
    private lateinit var apiService: FootballApiService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val apiKey = ApiKeyStorage.getApiKey(this) ?: return
        apiService = FootballApiClient.create(apiKey)

        lifecycleScope.launch {
            try {
                val federations = apiService.getFederations()
                Log.d("API", "Federations: $federations")
            } catch (e: Exception) {
                Log.e("API", "Error: ${e.message}")
            }
        }
    }
}
```

### Flutter (Dart)

```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FootballAPIClient {
  final String baseUrl = 'https://your-api-id.execute-api.region.amazonaws.com/Prod';
  final String apiKey;

  // Secure storage for API key
  static const _storage = FlutterSecureStorage();

  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'football_api_key', value: key);
  }

  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'football_api_key');
  }

  FootballAPIClient({required this.apiKey});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
  };

  Future<List<Federation>> getFederations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/federations'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Federation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load federations');
    }
  }

  Future<List<Season>> getSeasons() async {
    final response = await http.get(
      Uri.parse('$baseUrl/seasons'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Season.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load seasons');
    }
  }

  Future<List<League>> getLeagues(String seasonId, String federationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leagues/$seasonId/$federationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => League.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load leagues');
    }
  }
}

// Models
class Federation {
  final String federationId;
  final String federationName;

  Federation({required this.federationId, required this.federationName});

  factory Federation.fromJson(Map<String, dynamic> json) {
    return Federation(
      federationId: json['federationId'],
      federationName: json['federationName'],
    );
  }
}

class Season {
  final String seasonId;
  final String seasonName;
  final bool isCurrent;

  Season({
    required this.seasonId,
    required this.seasonName,
    required this.isCurrent,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonId: json['seasonId'],
      seasonName: json['seasonName'],
      isCurrent: json['isCurrent'],
    );
  }
}

class League {
  final String leagueId;
  final String? leagueName;

  League({required this.leagueId, this.leagueName});

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      leagueId: json['leagueId'],
      leagueName: json['leagueName'],
    );
  }
}
```

### React Native (JavaScript/TypeScript)

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios, { AxiosInstance } from 'axios';

// Types
interface Federation {
  federationId: string;
  federationName: string;
}

interface Season {
  seasonId: string;
  seasonName: string;
  isCurrent: boolean;
}

interface League {
  leagueId: string;
  leagueName?: string;
}

class FootballAPIClient {
  private client: AxiosInstance;
  private readonly BASE_URL = 'https://your-api-id.execute-api.region.amazonaws.com/Prod';

  constructor(apiKey: string) {
    this.client = axios.create({
      baseURL: this.BASE_URL,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      },
    });
  }

  // Save API Key securely
  static async saveApiKey(key: string): Promise<void> {
    await AsyncStorage.setItem('football_api_key', key);
  }

  // Retrieve API Key
  static async getApiKey(): Promise<string | null> {
    return await AsyncStorage.getItem('football_api_key');
  }

  async getFederations(): Promise<Federation[]> {
    const response = await this.client.get<Federation[]>('/federations');
    return response.data;
  }

  async getSeasons(): Promise<Season[]> {
    const response = await this.client.get<Season[]>('/seasons');
    return response.data;
  }

  async getLeagues(seasonId: string, federationId: string): Promise<League[]> {
    const response = await this.client.get<League[]>(
      `/leagues/${seasonId}/${federationId}`
    );
    return response.data;
  }

  async getRounds(
    seasonId: string,
    federationId: string,
    leagueId: string
  ): Promise<Round[]> {
    const response = await this.client.get<Round[]>(
      `/rounds/${seasonId}/${federationId}/${leagueId}`
    );
    return response.data;
  }

  async getResults(
    seasonId: string,
    federationId: string,
    leagueId: string,
    roundId: string
  ): Promise<Match[]> {
    const response = await this.client.get<Match[]>(
      `/results/${seasonId}/${federationId}/${leagueId}/${roundId}`
    );
    return response.data;
  }

  async getStandings(
    seasonId: string,
    federationId: string,
    leagueId: string,
    roundId: string
  ): Promise<Team[]> {
    const response = await this.client.get<Team[]>(
      `/standings/${seasonId}/${federationId}/${leagueId}/${roundId}`
    );
    return response.data;
  }
}

// Usage
import React, { useEffect, useState } from 'react';

export default function App() {
  const [federations, setFederations] = useState<Federation[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const apiKey = await FootballAPIClient.getApiKey();
        if (!apiKey) {
          throw new Error('API Key not found');
        }

        const client = new FootballAPIClient(apiKey);
        const data = await client.getFederations();
        setFederations(data);
      } catch (error) {
        console.error('Error:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) return <ActivityIndicator />;

  return (
    <FlatList
      data={federations}
      keyExtractor={(item) => item.federationId}
      renderItem={({ item }) => (
        <Text>{item.federationName}</Text>
      )}
    />
  );
}
```

## Error Handling

All endpoints may return these error codes:

| Status | Meaning | Solution |
|--------|---------|----------|
| 200 | Success | - |
| 400 | Bad Request | Check path parameters |
| 403 | Forbidden | Missing or invalid API key |
| 500 | Server Error | External data source issue |
| 502 | Bad Gateway | Failed to scrape data |

## Testing Without API Key (Development)

For local testing, you can temporarily disable API key requirement by setting `ApiKeyRequired: false` in the SAM template for each endpoint.

**Warning**: Remember to re-enable it before production deployment.

## Security Best Practices

1. **Never hardcode the API key** in your app bundle
2. **Store it securely** (Keychain on iOS, EncryptedSharedPreferences on Android)
3. **Use environment variables** for different builds (dev/staging/prod)
4. **Regenerate API key** if compromised via AWS Console
5. **Monitor CloudWatch** for unusual activity

## Support

For issues or questions about the API:
- Check CloudWatch Logs for Lambda errors
- Monitor API usage in CloudWatch Metrics
- Test endpoints locally first (see README_TESTING.md)
