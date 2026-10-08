/// App Control Screen - Start/Stop Trading Loops
/// Equivalent to Telegram /startapp, /stopapp, /startfno, /stopfno commands

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AppControlScreen extends StatefulWidget {
  const AppControlScreen({super.key});

  @override
  State<AppControlScreen> createState() => _AppControlScreenState();
}

class _AppControlScreenState extends State<AppControlScreen> {
  final ApiService _api = ApiService();
  
  AppsStatus? _status;
  bool _isLoading = true;
  String? _error;
  bool _isActioning = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadStatus(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final status = await _api.getAppsStatus();
      if (mounted) {
        setState(() {
          _status = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startIndia() async {
    await _performAction(
      () => _api.startIndiaApp(),
      'Starting India trading loop...',
    );
  }

  Future<void> _stopIndia() async {
    final confirmed = await _showConfirmDialog(
      'Stop India Trading Loop',
      'Are you sure you want to stop the India (equity swing) trading loop?\n\n'
      'This will also stop F&O as it depends on India.',
    );
    if (confirmed) {
      await _performAction(
        () => _api.stopIndiaApp(),
        'Stopping India trading loop...',
      );
    }
  }

  Future<void> _startFno() async {
    await _performAction(
      () => _api.startFnoApp(),
      'Starting F&O trading loop...',
    );
  }

  Future<void> _stopFno() async {
    final confirmed = await _showConfirmDialog(
      'Stop F&O Trading Loop',
      'Are you sure you want to stop the F&O trading loop?',
    );
    if (confirmed) {
      await _performAction(
        () => _api.stopFnoApp(),
        'Stopping F&O trading loop...',
      );
    }
  }

  Future<void> _performAction(
    Future<AppControlResult> Function() action,
    String loadingMessage,
  ) async {
    setState(() => _isActioning = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(loadingMessage),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      final result = await action();
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        await _loadStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActioning = false);
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Stop'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _loadStatus(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _status == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final status = _status!;

    return RefreshIndicator(
      onRefresh: _loadStatus,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Schedule Info Card
          _buildScheduleCard(status.schedule),
          const SizedBox(height: 16),

          // India App Card
          _buildAppCard(
            title: '🇮🇳 India Equity Swing',
            subtitle: 'NSE Nifty 500 • Zerodha',
            status: status.india,
            onStart: _startIndia,
            onStop: _stopIndia,
          ),
          const SizedBox(height: 16),

          // F&O App Card
          _buildAppCard(
            title: '📊 F&O Swing Options',
            subtitle: 'NSE Options • Zerodha',
            status: status.fno,
            onStart: _startFno,
            onStop: _stopFno,
            dependsOnIndia: true,
            indiaRunning: status.india.running,
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActionsCard(status),
          
          const SizedBox(height: 16),
          
          // Last updated
          Center(
            child: Text(
              'Last updated: ${_formatTime(status.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleInfo schedule) {
    final isInSchedule = schedule.inSchedule;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isInSchedule 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.schedule,
                color: isInSchedule ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isInSchedule ? 'Market Hours' : 'Outside Market Hours',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Schedule: ${schedule.scheduleText}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isInSchedule ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isInSchedule ? 'ACTIVE' : 'INACTIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard({
    required String title,
    required String subtitle,
    required AppStatus status,
    required VoidCallback onStart,
    required VoidCallback onStop,
    bool dependsOnIndia = false,
    bool indiaRunning = true,
  }) {
    final isRunning = status.running;
    final canStart = !dependsOnIndia || indiaRunning;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRunning ? Colors.green : Colors.red,
                    boxShadow: isRunning ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRunning 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isRunning ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isRunning ? 'RUNNING' : 'STOPPED',
                    style: TextStyle(
                      color: isRunning ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // PID info if running
            if (isRunning && status.pid != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'PID: ${status.pid}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            
            // Dependency warning
            if (dependsOnIndia && !indiaRunning)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Requires India loop to be running first',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isActioning || isRunning || !canStart 
                        ? null 
                        : onStart,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isActioning || !isRunning ? null : onStop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(
                        color: isRunning ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(AppsStatus status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.play_circle_fill,
                    label: 'Start All',
                    color: Colors.green,
                    enabled: !_isActioning && !status.allRunning,
                    onPressed: () async {
                      if (!status.india.running) {
                        await _performAction(
                          () => _api.startIndiaApp(),
                          'Starting all trading loops...',
                        );
                      } else if (!status.fno.running) {
                        await _performAction(
                          () => _api.startFnoApp(),
                          'Starting F&O loop...',
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.stop_circle,
                    label: 'Stop All',
                    color: Colors.red,
                    enabled: !_isActioning && status.anyRunning,
                    onPressed: () async {
                      final confirmed = await _showConfirmDialog(
                        'Stop All Trading',
                        'Are you sure you want to stop all trading loops?',
                      );
                      if (confirmed) {
                        await _performAction(
                          () => _api.stopIndiaApp(),
                          'Stopping all trading loops...',
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color.withOpacity(0.1) : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled ? color : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
