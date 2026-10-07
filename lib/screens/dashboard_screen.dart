/// Dashboard Screen — Home screen with P&L summary and top positions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final dashboard = provider.dashboard;
        final positions = provider.positions?.positions ?? [];

        return RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () => provider.refreshAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'F&O Trader',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dashboard != null)
                      RegimeBadge(regime: dashboard.regime),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary Cards Grid
                if (dashboard != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: "Today's P&L",
                          value: '${dashboard.todayPnl >= 0 ? "+" : ""}₹${_formatNumber(dashboard.todayPnl)}',
                          isPositive: dashboard.todayPnl >= 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Open Positions',
                          value: '${dashboard.openPositions}',
                          isNeutral: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Total F&O P&L',
                          value: '${dashboard.totalPnl >= 0 ? "+" : ""}₹${_formatNumber(dashboard.totalPnl)}',
                          isPositive: dashboard.totalPnl >= 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Win Rate',
                          value: '${dashboard.winRate.toStringAsFixed(0)}%',
                          isNeutral: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // NIFTY Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NIFTY 50',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dashboard.niftyPrice.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${dashboard.niftyChangePct >= 0 ? "+" : ""}${dashboard.niftyChangePct.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: dashboard.niftyChangePct >= 0
                                    ? AppTheme.primaryGreen
                                    : AppTheme.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Connection Status
                if (dashboard != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        dashboard.zerodhaConnected
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: 10,
                        color: dashboard.zerodhaConnected
                            ? AppTheme.primaryGreen
                            : AppTheme.primaryRed,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dashboard.zerodhaConnected
                            ? 'Zerodha Connected'
                            : 'Zerodha Disconnected',
                        style: TextStyle(
                          fontSize: 12,
                          color: dashboard.zerodhaConnected
                              ? AppTheme.textSecondary
                              : AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ],

                // Active Positions
                const SectionTitle(title: 'Active Positions'),
                
                if (positions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No open positions',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...positions.take(3).map((pos) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PositionCard(position: pos),
                  )),

                if (positions.length > 3)
                  TextButton(
                    onPressed: () {
                      // Navigate to positions tab
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: Text(
                      'View all ${positions.length} positions →',
                      style: const TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ),

                // Error display
                if (provider.error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.putBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                              color: AppTheme.putBadgeText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: provider.clearError,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(double n) {
    if (n.abs() >= 100000) {
      return '${(n / 100000).toStringAsFixed(2)}L';
    } else if (n.abs() >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toStringAsFixed(0);
  }
}
