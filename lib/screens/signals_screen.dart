/// Signals Screen — Pending signals with take/skip actions and filters
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  // Filter state
  String _sortBy = 'score'; // score, date, symbol
  SignalType? _filterType; // null = all, CALL, PUT
  double _minScore = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshSignals();
    });
  }

  List<Signal> _applyFilters(List<Signal> signals) {
    var filtered = signals.where((s) {
      if (_filterType != null && s.signalType != _filterType) return false;
      if (s.score < _minScore) return false;
      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'score':
        filtered.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'date':
        filtered.sort((a, b) => b.signalDate.compareTo(a.signalDate));
        break;
      case 'symbol':
        filtered.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
    }

    return filtered;
  }

  void _showTakeSignalDialog(BuildContext context, String signalId, String symbol) {
    int lots = 1;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Take $symbol Signal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Number of lots:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LotButton(
                    icon: Icons.remove,
                    onPressed: lots > 1 ? () => setDialogState(() => lots--) : null,
                  ),
                  Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$lots',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _LotButton(
                    icon: Icons.add,
                    onPressed: lots < 10 ? () => setDialogState(() => lots++) : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final message = await context.read<AppProvider>().takeSignal(signalId, lots);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Text('Take Signal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        _sortBy = 'score';
                        _filterType = null;
                        _minScore = 0;
                      });
                      setState(() {});
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sort By
              Text('Sort By', style: TextStyle(fontSize: 14, color: context.textSec)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                    label: 'Score',
                    selected: _sortBy == 'score',
                    onSelected: () => setSheetState(() {
                      _sortBy = 'score';
                      setState(() {});
                    }),
                  ),
                  _FilterChip(
                    label: 'Date',
                    selected: _sortBy == 'date',
                    onSelected: () => setSheetState(() {
                      _sortBy = 'date';
                      setState(() {});
                    }),
                  ),
                  _FilterChip(
                    label: 'Symbol',
                    selected: _sortBy == 'symbol',
                    onSelected: () => setSheetState(() {
                      _sortBy = 'symbol';
                      setState(() {});
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Signal Type
              Text('Signal Type', style: TextStyle(fontSize: 14, color: context.textSec)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filterType == null,
                    onSelected: () => setSheetState(() {
                      _filterType = null;
                      setState(() {});
                    }),
                  ),
                  _FilterChip(
                    label: 'CALL',
                    selected: _filterType == SignalType.CALL,
                    color: AppTheme.primaryGreen,
                    onSelected: () => setSheetState(() {
                      _filterType = SignalType.CALL;
                      setState(() {});
                    }),
                  ),
                  _FilterChip(
                    label: 'PUT',
                    selected: _filterType == SignalType.PUT,
                    color: AppTheme.primaryRed,
                    onSelected: () => setSheetState(() {
                      _filterType = SignalType.PUT;
                      setState(() {});
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Min Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min Score', style: TextStyle(fontSize: 14, color: context.textSec)),
                  Text(
                    _minScore.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _minScore,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppTheme.primaryGreen,
                onChanged: (v) => setSheetState(() {
                  _minScore = v;
                  setState(() {});
                }),
              ),
              const SizedBox(height: 20),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final signalList = provider.signals;
        final allSignals = signalList?.signals ?? [];
        final signals = _applyFilters(allSignals);
        final hasFilters = _filterType != null || _minScore > 0 || _sortBy != 'score';

        return LoadingOverlay(
          isLoading: provider.isLoading,
          child: RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () => provider.refreshSignals(),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Signals', style: theme.textTheme.headlineMedium),
                                if (signalList != null)
                                  Row(
                                    children: [
                                      Text('Market: ', style: TextStyle(fontSize: 13, color: context.textSec)),
                                      RegimeBadge(regime: signalList.regime),
                                    ],
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                // Filter button
                                IconButton(
                                  onPressed: _showFilterSheet,
                                  icon: Badge(
                                    isLabelVisible: hasFilters,
                                    smallSize: 8,
                                    child: Icon(
                                      Icons.filter_list,
                                      color: hasFilters ? AppTheme.primaryGreen : null,
                                    ),
                                  ),
                                  tooltip: 'Filter & Sort',
                                ),
                                // Scan button
                                OutlinedButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          final message = await provider.triggerScan();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(message)),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Scan', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (signalList?.lastScanTime != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Last scan: ${_formatTime(signalList!.lastScanTime!)}',
                            style: TextStyle(fontSize: 12, color: context.textSec),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Filter chips (if active)
                if (hasFilters)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (_filterType != null)
                            Chip(
                              label: Text(_filterType!.name, style: const TextStyle(fontSize: 12)),
                              onDeleted: () => setState(() => _filterType = null),
                              deleteIconColor: context.textSec,
                              backgroundColor: context.cardBg,
                              side: BorderSide.none,
                            ),
                          if (_minScore > 0)
                            Chip(
                              label: Text('Score ≥ ${_minScore.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                              onDeleted: () => setState(() => _minScore = 0),
                              deleteIconColor: context.textSec,
                              backgroundColor: context.cardBg,
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                    ),
                  ),

                // Signal count
                if (allSignals.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        hasFilters
                            ? 'Showing ${signals.length} of ${allSignals.length} signals'
                            : '${signals.length} New Signals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),

                // Signal list
                if (signals.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState(hasFilters))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SignalCard(
                            signal: signals[index],
                            onTake: () => _showTakeSignalDialog(
                              context,
                              signals[index].id,
                              signals[index].symbol,
                            ),
                            onSkip: () async {
                              await provider.skipSignal(signals[index].id);
                            },
                          ),
                        ),
                        childCount: signals.length,
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.search_off,
            size: 64,
            color: context.textSec.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No signals match filters' : 'No pending signals',
            style: TextStyle(fontSize: 16, color: context.textSec),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters ? 'Try adjusting your filters' : 'Tap "Scan" to run the scanner',
            style: TextStyle(fontSize: 13, color: context.textSec),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() {
                _filterType = null;
                _minScore = 0;
                _sortBy = 'score';
              }),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LotButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _LotButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null ? AppTheme.primaryGreen : context.textSec,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTheme.primaryGreen;
    
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: activeColor.withOpacity(0.2),
      checkmarkColor: activeColor,
      labelStyle: TextStyle(
        color: selected ? activeColor : context.textSec,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? activeColor : context.borderColor,
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  final Signal signal;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  const _SignalCard({
    required this.signal,
    required this.onTake,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isCall = signal.signalType == SignalType.CALL;
    final accentColor = isCall ? AppTheme.primaryGreen : AppTheme.primaryRed;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Symbol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            signal.symbol,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SignalBadge(type: signal.signalType),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        signal.sector,
                        style: TextStyle(fontSize: 12, color: context.textSec),
                      ),
                    ],
                  ),
                ),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.surfaceBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16, color: AppTheme.orange),
                      const SizedBox(width: 4),
                      Text(
                        signal.score.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Price info row
                Row(
                  children: [
                    _InfoItem(label: 'Price', value: '₹${signal.stockPrice.toStringAsFixed(0)}'),
                    _InfoItem(label: 'Strike', value: '₹${signal.strike.toStringAsFixed(0)}'),
                    _InfoItem(label: 'Premium', value: '₹${signal.premiumEstimate.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 12),
                // SL/Target row
                Row(
                  children: [
                    _InfoItem(
                      label: 'Stop Loss',
                      value: '₹${signal.stopPrice.toStringAsFixed(0)}',
                      valueColor: AppTheme.primaryRed,
                    ),
                    _InfoItem(
                      label: 'Target',
                      value: '₹${signal.targetPrice.toStringAsFixed(0)}',
                      valueColor: AppTheme.primaryGreen,
                    ),
                    _InfoItem(
                      label: 'Risk',
                      value: '${signal.riskPct.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Extra info
                Row(
                  children: [
                    _InfoPill(icon: Icons.trending_up, value: 'RS ${signal.rsRank.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    _InfoPill(icon: Icons.bar_chart, value: '${signal.volumeRatio.toStringAsFixed(1)}x Vol'),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.textSec,
                      side: BorderSide(color: context.borderColor),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onTake,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Take Signal'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: context.textSec),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.textSec),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: context.textSec),
          ),
        ],
      ),
    );
  }
}
