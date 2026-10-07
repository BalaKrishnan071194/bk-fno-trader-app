/// Settings Screen — Trading config and connection status

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../theme.dart';
import 'subscribers_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = false;
  bool _dailySummaryEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final settings = provider.settings;
        final dashboard = provider.dashboard;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Trading Section
              _buildSectionTitle('Trading'),
              _buildSettingsCard([
                _buildSettingsRow(
                  'Max Positions',
                  '${settings?.maxPositions ?? 10}',
                ),
                _buildSettingsRow(
                  'Position Size',
                  '${settings?.positionSizePct ?? 2.5}% of capital',
                ),
                _buildSettingsRow(
                  'Default SL',
                  '${settings?.optionStopPct ?? 50}%',
                ),
                _buildSettingsRow(
                  'Max Lots',
                  '${settings?.maxLots ?? 8}',
                ),
                _buildSettingsRow(
                  'Min Score',
                  '${settings?.minScore ?? 2.5}',
                ),
              ]),

              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionTitle('Notifications'),
              _buildSettingsCard([
                _buildToggleRow(
                  'Signal Alerts',
                  _notificationsEnabled,
                  (val) => setState(() => _notificationsEnabled = val),
                ),
                _buildToggleRow(
                  'Exit Alerts',
                  _notificationsEnabled,
                  (val) => setState(() => _notificationsEnabled = val),
                ),
                _buildToggleRow(
                  'Daily Summary',
                  _dailySummaryEnabled,
                  (val) => setState(() => _dailySummaryEnabled = val),
                ),
                _buildToggleRow(
                  'Sound',
                  _soundEnabled,
                  (val) => setState(() => _soundEnabled = val),
                ),
              ]),

              const SizedBox(height: 16),

              // Connection Section
              _buildSectionTitle('Connection'),
              _buildSettingsCard([
                _buildSettingsRow(
                  'Zerodha Status',
                  dashboard?.zerodhaConnected == true ? '● Connected' : '○ Disconnected',
                  valueColor: dashboard?.zerodhaConnected == true
                      ? AppTheme.primaryGreen
                      : AppTheme.primaryRed,
                ),
                _buildSettingsRow(
                  'Token Expiry',
                  dashboard?.tokenExpiry != null
                      ? _formatExpiry(dashboard!.tokenExpiry!)
                      : 'Unknown',
                ),
                _buildSettingsRow(
                  'User ID',
                  'BTY813',
                ),
              ]),

              const SizedBox(height: 16),

              // Re-authenticate button
              _buildSettingsCard([
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please re-authenticate via Telegram /totp'),
                        ),
                      );
                    },
                    child: const Text('Re-authenticate Zerodha'),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // Manage Subscribers
              _buildSectionTitle('Telegram'),
              _buildSettingsCard([
                ListTile(
                  leading: const Icon(Icons.people, color: AppTheme.textSecondary),
                  title: const Text('Manage Subscribers'),
                  subtitle: const Text('Add/remove Telegram notification recipients'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscribersScreen(),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // Logout button
              Center(
                child: TextButton(
                  onPressed: () => _showLogoutConfirmation(context, provider),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: AppTheme.primaryRed),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version
              Center(
                child: Text(
                  'F&O Trader v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                const Divider(
                  height: 1,
                  color: AppTheme.border,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
            activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.bgPrimary,
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.logout();
              if (mounted) {
                // Navigate to login screen
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    if (expiry.year == now.year &&
        expiry.month == now.month &&
        expiry.day == now.day) {
      return 'Today ${expiry.hour.toString().padLeft(2, '0')}:${expiry.minute.toString().padLeft(2, '0')}';
    }
    return '${expiry.day}/${expiry.month} ${expiry.hour.toString().padLeft(2, '0')}:${expiry.minute.toString().padLeft(2, '0')}';
  }
}
