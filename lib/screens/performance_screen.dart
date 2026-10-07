/// Performance Screen — Stats, charts, and trade history

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_provider.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.refreshPerformance();
      provider.refreshHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final perf = provider.performance;
        final history = provider.history ?? [];

        return RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () async {
            await provider.refreshPerformance();
            await provider.refreshHistory();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Last 30 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // P&L Chart
                if (perf != null) _buildPnLChart(perf),

                const SizedBox(height: 16),

                // Stats Grid
                if (perf != null) ...[
                  _buildStatsGrid(perf),
                  const SizedBox(height: 16),
                  _buildDirectionStats(perf),
                ],

                // Trade History
                const SectionTitle(title: 'Recent Trades'),
                if (history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No closed trades yet',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...history.take(10).map((trade) => _buildTradeItem(trade)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPnLChart(PerformanceData perf) {
    final dailyPnl = perf.dailyPnl;
    if (dailyPnl.isEmpty) return const SizedBox.shrink();

    // Find max for scaling
    double maxPnl = 1;
    for (final d in dailyPnl) {
      if (d.pnl.abs() > maxPnl) maxPnl = d.pnl.abs();
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily P&L',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxPnl,
                minY: -maxPnl,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.border.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: dailyPnl.asMap().entries.map((entry) {
                  final isPositive = entry.value.pnl >= 0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.pnl,
                        color: isPositive ? AppTheme.primaryGreen : AppTheme.primaryRed,
                        width: 6,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(PerformanceData perf) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        StatCard(
          label: 'Total P&L',
          value: '${perf.totalPnl >= 0 ? "+" : ""}₹${_formatNumber(perf.totalPnl)}',
          isProfit: perf.totalPnl >= 0,
        ),
        StatCard(
          label: 'Profit Factor',
          value: perf.profitFactor.toStringAsFixed(2),
        ),
        StatCard(
          label: 'Win Rate',
          value: '${perf.winRate.toStringAsFixed(0)}%',
        ),
        StatCard(
          label: 'Total Trades',
          value: '${perf.totalTrades}',
        ),
        StatCard(
          label: 'Max Drawdown',
          value: '-₹${_formatNumber(perf.maxDrawdown)}',
          isProfit: false,
        ),
        StatCard(
          label: 'Avg Trade',
          value: '${perf.avgTradePnl >= 0 ? "+" : ""}₹${_formatNumber(perf.avgTradePnl)}',
          isProfit: perf.avgTradePnl >= 0,
        ),
      ],
    );
  }

  Widget _buildDirectionStats(PerformanceData perf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'By Direction'),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'CALL (${perf.callStats.trades} trades)',
                value: '${perf.callStats.pnl >= 0 ? "+" : ""}₹${_formatNumber(perf.callStats.pnl)}',
                subtitle: '${perf.callStats.winRate.toStringAsFixed(0)}% win rate',
                isProfit: perf.callStats.pnl >= 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'PUT (${perf.putStats.trades} trades)',
                value: '${perf.putStats.pnl >= 0 ? "+" : ""}₹${_formatNumber(perf.putStats.pnl)}',
                subtitle: '${perf.putStats.winRate.toStringAsFixed(0)}% win rate',
                isProfit: perf.putStats.pnl >= 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTradeItem(TradeHistoryItem trade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Symbol and type
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      trade.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SignalBadge(type: trade.signalType),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${trade.daysHeld}d • ${trade.exitReason}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // P&L
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${trade.isProfit ? "+" : ""}₹${trade.pnlAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: trade.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                ),
              ),
              Text(
                '${trade.isProfit ? "+" : ""}${trade.pnlPct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: trade.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
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
