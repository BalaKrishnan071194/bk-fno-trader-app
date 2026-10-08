/// Performance Screen — Stats, charts, and trade history (Redesigned)
library;

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

class _PerformanceScreenState extends State<PerformanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chartPeriod = '30D';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.refreshPerformance();
      provider.refreshHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your trading performance',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Summary Cards
              if (perf != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSummaryCards(perf),
                  ),
                ),

              // P&L Chart
              if (perf != null && perf.dailyPnl.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPnLChart(perf),
                  ),
                ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: AppTheme.primaryGreen,
                      unselectedLabelColor: context.textSec,
                      tabs: const [
                        Tab(text: 'Statistics'),
                        Tab(text: 'Trade History'),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Statistics Tab
                    perf != null
                        ? _buildStatisticsTab(perf)
                        : const Center(child: CircularProgressIndicator()),

                    // Trade History Tab
                    _buildHistoryTab(history),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(PerformanceData perf) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total P&L',
            value: '₹${_formatNumber(perf.totalPnl)}',
            isProfit: perf.totalPnl >= 0,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Win Rate',
            value: '${perf.winRate.toStringAsFixed(0)}%',
            subtitle: '${perf.totalTrades} trades',
            icon: Icons.pie_chart_outline,
            iconColor: AppTheme.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildPnLChart(PerformanceData perf) {
    final dailyPnl = perf.dailyPnl;
    if (dailyPnl.isEmpty) return const SizedBox.shrink();

    // Calculate cumulative P&L
    double cumulative = 0;
    final cumulativeData = dailyPnl.map((d) {
      cumulative += d.pnl;
      return cumulative;
    }).toList();

    final maxVal = cumulativeData.reduce((a, b) => a.abs() > b.abs() ? a : b).abs();
    final minVal = cumulativeData.reduce((a, b) => a < b ? a : b);
    final maxYVal = cumulativeData.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cumulative P&L',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSec,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_formatNumber(cumulative)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cumulative >= 0 ? context.profit : context.loss,
                    ),
                  ),
                ],
              ),
              // Period selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _chartPeriod,
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(fontSize: 12, color: context.textSec),
                  items: ['7D', '30D', '90D'].map((p) => 
                    DropdownMenuItem(value: p, child: Text(p))
                  ).toList(),
                  onChanged: (v) => setState(() => _chartPeriod = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 3 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.borderColor.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value),
                          style: TextStyle(fontSize: 10, color: context.textSec),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: minVal < 0 ? minVal * 1.1 : 0,
                maxY: maxYVal > 0 ? maxYVal * 1.1 : 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: cumulativeData.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: cumulative >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (cumulative >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed)
                          .withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorder: BorderSide(color: context.borderColor),
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        '₹${_formatNumber(spot.y)}',
                        TextStyle(
                          color: spot.y >= 0 ? context.profit : context.loss,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(PerformanceData perf) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Grid
          _buildMetricsGrid(perf),
          const SizedBox(height: 20),

          // Direction Breakdown
          Text(
            'By Direction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          _buildDirectionCards(perf),
          const SizedBox(height: 20),

          // Win/Loss Distribution
          _buildWinLossBar(perf),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(PerformanceData perf) {
    final metrics = [
      _MetricData('Profit Factor', perf.profitFactor.toStringAsFixed(2), Icons.speed),
      _MetricData('Max Drawdown', '-₹${_formatNumber(perf.maxDrawdown)}', Icons.trending_down, isLoss: true),
      _MetricData('Avg Winner', '+₹${_formatNumber(perf.avgWinner)}', Icons.arrow_upward, isProfit: true),
      _MetricData('Avg Loser', '-₹${_formatNumber(perf.avgLoser)}', Icons.arrow_downward, isLoss: true),
      _MetricData('Total Trades', '${perf.totalTrades}', Icons.repeat),
      _MetricData('Avg Trade', '₹${_formatNumber(perf.avgTradePnl)}', Icons.show_chart, 
          isProfit: perf.avgTradePnl >= 0, isLoss: perf.avgTradePnl < 0),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final m = metrics[index];
        return _MetricCard(
          title: m.title,
          value: m.value,
          icon: m.icon,
          isProfit: m.isProfit,
          isLoss: m.isLoss,
        );
      },
    );
  }

  Widget _buildDirectionCards(PerformanceData perf) {
    return Row(
      children: [
        Expanded(
          child: _DirectionCard(
            type: 'CALL',
            stats: perf.callStats,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DirectionCard(
            type: 'PUT',
            stats: perf.putStats,
            color: AppTheme.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildWinLossBar(PerformanceData perf) {
    final wins = (perf.totalTrades * perf.winRate / 100).round();
    final losses = perf.totalTrades - wins;
    final winPct = perf.totalTrades > 0 ? wins / perf.totalTrades : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Win/Loss Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: winPct,
              minHeight: 12,
              backgroundColor: AppTheme.primaryRed.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('$wins Wins', style: TextStyle(fontSize: 13, color: context.textSec)),
                ],
              ),
              Row(
                children: [
                  Text('$losses Losses', style: TextStyle(fontSize: 13, color: context.textSec)),
                  const SizedBox(width: 6),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<TradeHistoryItem> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: context.textSec.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No closed trades yet',
              style: TextStyle(fontSize: 16, color: context.textSec),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) => _TradeHistoryCard(trade: history[index]),
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

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final bool isProfit;
  final Color? iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.isProfit = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? (isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              if (isProfit && iconColor == null)
                Icon(Icons.trending_up, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: iconColor != null 
                  ? Theme.of(context).textTheme.bodyLarge?.color 
                  : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: context.textSec),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: context.textSec),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final bool isProfit;
  final bool isLoss;

  _MetricData(this.title, this.value, this.icon, {this.isProfit = false, this.isLoss = false});
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isProfit;
  final bool isLoss;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isProfit = false,
    this.isLoss = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? valueColor;
    if (isProfit) valueColor = AppTheme.primaryGreen;
    if (isLoss) valueColor = AppTheme.primaryRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: context.textSec),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: context.textSec),
          ),
        ],
      ),
    );
  }
}

class _DirectionCard extends StatelessWidget {
  final String type;
  final DirectionStats stats;
  final Color color;

  const _DirectionCard({
    required this.type,
    required this.stats,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${stats.trades} trades',
                style: TextStyle(fontSize: 11, color: context.textSec),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${stats.pnl >= 0 ? "+" : ""}₹${(stats.pnl / 1000).toStringAsFixed(1)}K',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: stats.pnl >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatPill(label: 'Win', value: '${stats.winRate.toStringAsFixed(0)}%'),
              const SizedBox(width: 8),
              _StatPill(label: 'PF', value: stats.profitFactor.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 11, color: context.textSec),
      ),
    );
  }
}

class _TradeHistoryCard extends StatelessWidget {
  final TradeHistoryItem trade;

  const _TradeHistoryCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          // Left colored bar
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: trade.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Symbol and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      trade.symbol,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SignalBadge(type: trade.signalType),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${trade.daysHeld}d held • ${trade.exitReason}',
                  style: TextStyle(fontSize: 12, color: context.textSec),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: trade.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                ),
              ),
              Text(
                '${trade.isProfit ? "+" : ""}${trade.pnlPct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: trade.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
