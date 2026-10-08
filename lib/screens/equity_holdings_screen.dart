/// Equity Holdings Screen — Stock portfolio with current values and P&L

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class EquityHoldingsScreen extends StatefulWidget {
  const EquityHoldingsScreen({super.key});

  @override
  State<EquityHoldingsScreen> createState() => _EquityHoldingsScreenState();
}

class _EquityHoldingsScreenState extends State<EquityHoldingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshEquityHoldings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final holdingsList = provider.equityHoldings;
        final holdings = holdingsList?.holdings ?? [];

        return LoadingOverlay(
          isLoading: provider.isLoading,
          child: RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () => provider.refreshEquityHoldings(),
            child: holdings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: holdings.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildHeader(holdingsList!);
                      }
                      final holding = holdings[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: HoldingCard(holding: holding),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EquityHoldingsList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Holdings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${data.holdingsCount} Stocks',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Summary card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryItem(
                    label: 'Invested',
                    value: _formatLakhs(data.totalInvested),
                  ),
                  _SummaryItem(
                    label: 'Current',
                    value: _formatLakhs(data.totalCurrent),
                    alignRight: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.bgSecondary),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryItem(
                    label: 'Total P&L',
                    value: '${data.totalPnl >= 0 ? "+" : ""}${_formatLakhs(data.totalPnl)}',
                    valueColor: data.totalPnl >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
                    subtitle: '${data.totalPnlPct >= 0 ? "+" : ""}${data.totalPnlPct.toStringAsFixed(2)}%',
                  ),
                  _SummaryItem(
                    label: "Today's Change",
                    value: '${data.totalDayChange >= 0 ? "+" : ""}${_formatAmount(data.totalDayChange)}',
                    valueColor: data.totalDayChange >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
                    alignRight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No equity holdings',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your stock portfolio will appear here',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLakhs(double n) {
    if (n.abs() >= 100000) {
      return '₹${(n / 100000).toStringAsFixed(2)}L';
    } else if (n.abs() >= 1000) {
      return '₹${(n / 1000).toStringAsFixed(1)}K';
    }
    return '₹${n.toStringAsFixed(0)}';
  }

  String _formatAmount(double n) {
    if (n.abs() >= 100000) {
      return '₹${(n / 100000).toStringAsFixed(2)}L';
    } else if (n.abs() >= 1000) {
      return '₹${(n / 1000).toStringAsFixed(1)}K';
    }
    return '₹${n.toStringAsFixed(0)}';
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;
  final bool alignRight;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 11,
              color: valueColor ?? AppTheme.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// Holding Card — Individual stock holding
class HoldingCard extends StatefulWidget {
  final EquityHolding holding;

  const HoldingCard({super.key, required this.holding});

  @override
  State<HoldingCard> createState() => _HoldingCardState();
}

class _HoldingCardState extends State<HoldingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.holding;
    final borderColor = h.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: borderColor, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.symbol,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${h.quantity} shares @ ₹${h.averagePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // P&L display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${h.isProfit ? "+" : ""}₹${_formatPnl(h.pnl)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: h.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                      ),
                    ),
                    Text(
                      '${h.pnlPct >= 0 ? "+" : ""}${h.pnlPct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: h.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Quick stats row
            Row(
              children: [
                _DetailItem(label: 'LTP', value: '₹${h.lastPrice.toStringAsFixed(2)}'),
                _DetailItem(
                  label: 'Day',
                  value: '${h.dayChangePct >= 0 ? "+" : ""}${h.dayChangePct.toStringAsFixed(2)}%',
                  valueColor: h.isDayPositive ? AppTheme.primaryGreen : AppTheme.primaryRed,
                ),
                _DetailItem(label: 'Value', value: _formatValue(h.currentValue)),
                if (!_isExpanded)
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Expanded details
            if (_isExpanded) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _DetailItem(label: 'Invested', value: _formatValue(h.investedValue)),
                  _DetailItem(label: 'Avg Price', value: '₹${h.averagePrice.toStringAsFixed(2)}'),
                  _DetailItem(label: 'Exchange', value: h.exchange),
                ],
              ),
              if (h.t1Quantity > 0 || h.collateralQuantity > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (h.t1Quantity > 0)
                      _DetailItem(label: 'T+1 Qty', value: '${h.t1Quantity}'),
                    if (h.collateralQuantity > 0)
                      _DetailItem(label: 'Pledged', value: '${h.collateralQuantity}'),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.expand_less,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPnl(double n) {
    if (n.abs() >= 100000) {
      return '${(n / 100000).toStringAsFixed(2)}L';
    } else if (n.abs() >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toStringAsFixed(0);
  }

  String _formatValue(double n) {
    if (n >= 100000) {
      return '₹${(n / 100000).toStringAsFixed(2)}L';
    } else if (n >= 1000) {
      return '₹${(n / 1000).toStringAsFixed(1)}K';
    }
    return '₹${n.toStringAsFixed(0)}';
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
