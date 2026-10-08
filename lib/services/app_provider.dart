/// App Provider — State management for F&O Trading App
/// Uses Provider pattern for reactive state updates

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Data
  DashboardData? _dashboard;
  PositionList? _positions;
  SignalList? _signals;
  PerformanceData? _performance;
  Settings? _settings;
  List<TradeHistoryItem>? _history;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _api.isLoggedIn;
  ApiService get apiService => _api;
  
  DashboardData? get dashboard => _dashboard;
  PositionList? get positions => _positions;
  SignalList? get signals => _signals;
  PerformanceData? get performance => _performance;
  Settings? get settings => _settings;
  List<TradeHistoryItem>? get history => _history;

  // ─────────────────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _api.loadStoredToken();
    if (_api.isLoggedIn) {
      await refreshAll();
    }
    notifyListeners();
  }

  Future<bool> login(String apiKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _api.login(apiKey);
      if (success) {
        await refreshAll();
      } else {
        _error = 'Invalid API key';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _dashboard = null;
    _positions = null;
    _signals = null;
    _performance = null;
    _settings = null;
    _history = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data Fetching
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refreshAll() async {
    await Future.wait([
      refreshDashboard(),
      refreshPositions(),
    ]);
  }

  Future<void> refreshDashboard() async {
    try {
      _dashboard = await _api.getDashboard();
      _error = null;
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
    }
    notifyListeners();
  }

  Future<void> refreshPositions() async {
    try {
      _positions = await _api.getPositions();
      _error = null;
    } catch (e) {
      _error = 'Failed to load positions: $e';
    }
    notifyListeners();
  }

  Future<void> refreshSignals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _signals = await _api.getSignals();
      _error = null;
    } catch (e) {
      _error = 'Failed to load signals: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPerformance() async {
    try {
      _performance = await _api.getPerformance();
      _error = null;
    } catch (e) {
      _error = 'Failed to load performance: $e';
    }
    notifyListeners();
  }

  Future<void> refreshSettings() async {
    try {
      _settings = await _api.getSettings();
      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    }
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    try {
      _history = await _api.getTradeHistory();
      _error = null;
    } catch (e) {
      _error = 'Failed to load history: $e';
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> exitPosition(String symbol) async {
    _isLoading = true;
    notifyListeners();

    try {
      final message = await _api.exitPosition(symbol);
      await refreshPositions();
      await refreshDashboard();
      return message;
    } catch (e) {
      return 'Exit failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> updateStopLoss(String symbol, double newStop) async {
    try {
      final message = await _api.updateStopLoss(symbol, newStop);
      await refreshPositions();
      return message;
    } catch (e) {
      return 'Update failed: $e';
    }
  }

  Future<String> triggerScan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final message = await _api.triggerScan();
      await refreshSignals();
      return message;
    } catch (e) {
      return 'Scan failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> takeSignal(String signalId, int lots) async {
    _isLoading = true;
    notifyListeners();

    try {
      final message = await _api.takeSignal(signalId, lots);
      await refreshPositions();
      await refreshSignals();
      return message;
    } catch (e) {
      return 'Take signal failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> skipSignal(String signalId) async {
    try {
      await _api.skipSignal(signalId);
      await refreshSignals();
    } catch (e) {
      _error = 'Skip failed: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
