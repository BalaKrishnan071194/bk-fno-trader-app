/// API Service for F&O Trading App
/// Handles all HTTP communication with the FastAPI backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiService {
  // Configure this for your VPS
  static const String _baseUrl = 'http://13.206.126.94:8080/api';
  
  String? _accessToken;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // HTTP Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<dynamic> _get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> _post(String endpoint, [Map<String, dynamic>? body]) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> _put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> _delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      _accessToken = null;
      throw ApiException('Unauthorized - please login again', 401);
    } else {
      String message = 'Request failed';
      try {
        final body = jsonDecode(response.body);
        message = body['detail'] ?? body['error'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  Future<bool> login(String apiKey) async {
    try {
      final response = await _post('/auth/login', {'api_key': apiKey});
      _accessToken = response['access_token'];
      
      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  bool get isLoggedIn => _accessToken != null;

  Future<bool> get isZerodhaConnected async {
    try {
      final response = await _get('/auth/status');
      return response['zerodha_connected'] as bool;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dashboard
  // ─────────────────────────────────────────────────────────────────────────

  Future<DashboardData> getDashboard() async {
    final response = await _get('/dashboard');
    return DashboardData.fromJson(response);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Positions
  // ─────────────────────────────────────────────────────────────────────────

  Future<PositionList> getPositions() async {
    final response = await _get('/positions');
    return PositionList.fromJson(response);
  }

  Future<Position> getPosition(String symbol) async {
    final response = await _get('/positions/$symbol');
    return Position.fromJson(response);
  }

  Future<String> exitPosition(String symbol) async {
    final response = await _post('/positions/$symbol/exit');
    return response['message'] as String;
  }

  Future<String> updateStopLoss(String symbol, double newStopPrice) async {
    final response = await _put(
      '/positions/$symbol/sl',
      {'new_stop_price': newStopPrice},
    );
    return response['message'] as String;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Signals
  // ─────────────────────────────────────────────────────────────────────────

  Future<SignalList> getSignals() async {
    final response = await _get('/signals');
    return SignalList.fromJson(response);
  }

  Future<String> triggerScan() async {
    final response = await _post('/scan');
    return response['message'] as String;
  }

  Future<String> takeSignal(String signalId, int lots) async {
    final response = await _post('/signals/$signalId/take', {'lots': lots});
    return response['message'] as String;
  }

  Future<void> skipSignal(String signalId) async {
    await _post('/signals/$signalId/skip');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Performance
  // ─────────────────────────────────────────────────────────────────────────

  Future<PerformanceData> getPerformance() async {
    final response = await _get('/performance');
    return PerformanceData.fromJson(response);
  }

  Future<List<TradeHistoryItem>> getTradeHistory({int limit = 20}) async {
    final response = await _get('/history?limit=$limit');
    return (response['trades'] as List)
        .map((t) => TradeHistoryItem.fromJson(t))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings
  // ─────────────────────────────────────────────────────────────────────────

  Future<Settings> getSettings() async {
    final response = await _get('/settings');
    return Settings.fromJson(response);
  }

  Future<void> updateSettings(Map<String, dynamic> updates) async {
    await _put('/settings', updates);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Subscribers
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSubscribersRaw() async {
    final response = await _get('/subscribers');
    return (response['subscribers'] as List)
        .map((s) => Map<String, dynamic>.from(s))
        .toList();
  }

  Future<void> addSubscriber({
    required String chatId,
    required String role,
    required String accountId,
  }) async {
    await _post('/subscribers', body: {
      'chat_id': chatId,
      'role': role,
      'account_id': accountId,
    });
  }

  Future<void> updateSubscriber({
    required String chatId,
    required String role,
    required String accountId,
  }) async {
    await _put('/subscribers/$chatId', {
      'chat_id': chatId,
      'role': role,
      'account_id': accountId,
    });
  }

  Future<void> removeSubscriber(String chatId) async {
    await _delete('/subscribers/$chatId');
  }
}
