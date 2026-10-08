/// Reusable Widgets for F&O Trading App

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final bool isNeutral;
  final bool fullWidth;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.isPositive = true,
    this.isNeutral = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNeutral
                  ? AppTheme.textPrimary
                  : (isPositive ? AppTheme.primaryGreen : AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Funds Widget — Capital breakdown card
// ─────────────────────────────────────────────────────────────────────────────

class FundsWidget extends StatelessWidget {
  final FundsData funds;

  const FundsWidget({super.key, required this.funds});

  String _formatLakhs(double n) {
    if (n.abs() >= 100000) {
      return '₹${(n / 100000).toStringAsFixed(2)}L';
    } else if (n.abs() >= 1000) {
      return '₹${(n / 1000).toStringAsFixed(1)}K';
    }
    return '₹${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgSecondary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with total capital
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Capital',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                _formatLakhs(funds.totalCapital),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Capital breakdown bars
          _CapitalBar(
            label: 'Available Cash',
            value: funds.availableCash,
            total: funds.totalCapital,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          _CapitalBar(
            label: 'Equity Holdings',
            value: funds.equity.currentValue,
            total: funds.totalCapital,
            color: const Color(0xFF3B82F6), // Blue
            trailing: funds.equity.unrealizedPnl,
          ),
          const SizedBox(height: 8),
          _CapitalBar(
            label: 'F&O Positions',
            value: funds.fno.capitalDeployed,
            total: funds.totalCapital,
            color: const Color(0xFFA855F7), // Purple
            trailing: funds.fno.unrealizedPnl,
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.bgSecondary),
          const SizedBox(height: 10),
          
          // Total P&L footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Unrealized P&L',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${funds.totalUnrealizedPnl >= 0 ? "+" : ""}${_formatLakhs(funds.totalUnrealizedPnl)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: funds.totalUnrealizedPnl >= 0
                      ? AppTheme.primaryGreen
                      : AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapitalBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;
  final double? trailing;

  const _CapitalBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    this.trailing,
  });

  String _formatAmount(double n) {
    if (n.abs() >= 100000) {
      return '₹${(n / 100000).toStringAsFixed(2)}L';
    } else if (n.abs() >= 1000) {
      return '₹${(n / 1000).toStringAsFixed(1)}K';
    }
    return '₹${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            Row(
              children: [
                Text(
                  _formatAmount(value),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${trailing! >= 0 ? "+" : ""}${_formatAmount(trailing!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: trailing! >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signal Type Badge
// ─────────────────────────────────────────────────────────────────────────────

class SignalBadge extends StatelessWidget {
  final SignalType type;

  const SignalBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isCall = type == SignalType.CALL;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCall ? AppTheme.callBadgeBg : AppTheme.putBadgeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isCall ? AppTheme.callBadgeText : AppTheme.putBadgeText,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Regime Badge
// ─────────────────────────────────────────────────────────────────────────────

class RegimeBadge extends StatelessWidget {
  final Regime regime;

  const RegimeBadge({super.key, required this.regime});

  @override
  Widget build(BuildContext context) {
    final color = regime == Regime.BULLISH
        ? AppTheme.primaryGreen
        : (regime == Regime.BEARISH ? AppTheme.primaryRed : AppTheme.textSecondary);
    final bgColor = regime == Regime.BULLISH
        ? AppTheme.callBadgeBg
        : (regime == Regime.BEARISH ? AppTheme.putBadgeBg : AppTheme.bgTertiary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        regime.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Position Card — Expandable with actions
// ─────────────────────────────────────────────────────────────────────────────

class PositionCard extends StatefulWidget {
  final Position position;
  final VoidCallback? onExit;
  final VoidCallback? onAdjustSL;
  final bool showActions;
  final bool initiallyExpanded;

  const PositionCard({
    super.key,
    required this.position,
    this.onExit,
    this.onAdjustSL,
    this.showActions = false,
    this.initiallyExpanded = false,
  });

  @override
  State<PositionCard> createState() => _PositionCardState();
}

class _PositionCardState extends State<PositionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded || widget.showActions;
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.position;
    final borderColor = pos.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed;
    
    // Calculate R-multiple (profit as multiple of risk)
    final risk = pos.entryPremium - pos.optionStop;
    final rMultiple = risk > 0 ? (pos.ltp - pos.entryPremium) / risk : 0.0;

    return GestureDetector(
      onTap: widget.showActions ? null : () {
        setState(() => _isExpanded = !_isExpanded);
      },
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
                  child: Row(
                    children: [
                      Text(
                        pos.displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SignalBadge(type: pos.signalType),
                    ],
                  ),
                ),
                // P&L display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${pos.isProfit ? "+" : ""}₹${pos.pnlAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: pos.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                      ),
                    ),
                    Text(
                      '${pos.pnlPct >= 0 ? "+" : ""}${pos.pnlPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: pos.isProfit ? AppTheme.primaryGreen : AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Quick stats row (always visible)
            Row(
              children: [
                _DetailItem(label: 'Entry', value: '₹${pos.entryPremium.toStringAsFixed(1)}'),
                _DetailItem(label: 'LTP', value: '₹${pos.ltp.toStringAsFixed(1)}'),
                _DetailItem(label: 'Lots', value: '${pos.lots}'),
                if (!_isExpanded)
                  Expanded(
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
              
              // Stop loss and target row
              Row(
                children: [
                  _DetailItem(
                    label: 'SL',
                    value: '₹${pos.optionStop.toStringAsFixed(1)}',
                  ),
                  _DetailItem(
                    label: 'Target',
                    value: '₹${(pos.entryPremium + 2 * risk).toStringAsFixed(0)}',
                  ),
                  _DetailItem(
                    label: 'R-Multiple',
                    value: '${rMultiple >= 0 ? "+" : ""}${rMultiple.toStringAsFixed(1)}R',
                    isProfit: rMultiple >= 0,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Stock SL, Days held, Sector
              Row(
                children: [
                  _DetailItem(label: 'Stock SL', value: '₹${pos.stopPrice.toStringAsFixed(0)}'),
                  _DetailItem(label: 'Days', value: '${pos.daysHeld}'),
                  _DetailItem(label: 'Sector', value: pos.sector.length > 10 
                      ? '${pos.sector.substring(0, 10)}...' 
                      : pos.sector),
                ],
              ),
              
              // Action buttons
              if (widget.onExit != null || widget.onAdjustSL != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (widget.onAdjustSL != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onAdjustSL,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Update SL', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    if (widget.onAdjustSL != null && widget.onExit != null)
                      const SizedBox(width: 10),
                    if (widget.onExit != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onExit,
                          icon: const Icon(Icons.exit_to_app, size: 16),
                          label: const Text('EXIT', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              
              // Collapse indicator when expanded
              if (!widget.showActions) ...[
                const SizedBox(height: 8),
                Center(
                  child: Icon(
                    Icons.expand_less,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool? isProfit;
  final bool alignRight;

  const _DetailItem({
    required this.label,
    required this.value,
    this.isProfit,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              fontWeight: FontWeight.w600,
              color: isProfit == null
                  ? AppTheme.textPrimary
                  : (isProfit! ? AppTheme.primaryGreen : AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signal Card
// ─────────────────────────────────────────────────────────────────────────────

class SignalCard extends StatelessWidget {
  final Signal signal;
  final VoidCallback? onTake;
  final VoidCallback? onSkip;

  const SignalCard({
    super.key,
    required this.signal,
    this.onTake,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = signal.signalType == SignalType.CALL
        ? AppTheme.primaryGreen
        : AppTheme.primaryRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                signal.symbol,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SignalBadge(type: signal.signalType),
            ],
          ),
          const SizedBox(height: 8),
          
          // Details row 1
          Row(
            children: [
              _DetailItem(label: 'Price', value: '₹${signal.stockPrice.toStringAsFixed(0)}'),
              _DetailItem(label: 'Strike', value: '${signal.strike.toInt()} ${signal.signalType == SignalType.CALL ? "CE" : "PE"}'),
              _DetailItem(label: 'Premium', value: '~₹${signal.premiumEstimate.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 8),
          
          // Details row 2
          Row(
            children: [
              _DetailItem(label: 'RS Rank', value: signal.rsRank.toStringAsFixed(1)),
              _DetailItem(label: 'SL', value: '₹${signal.stopPrice.toStringAsFixed(0)}'),
              _DetailItem(label: 'Target', value: '₹${signal.targetPrice.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Actions
          Row(
            children: [
              OutlinedButton(
                onPressed: onSkip,
                child: const Text('Skip', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTake,
                  child: const Text('Take Signal', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Card
// ─────────────────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool? isProfit;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.isProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isProfit == null
                  ? AppTheme.textPrimary
                  : (isProfit! ? AppTheme.primaryGreen : AppTheme.primaryRed),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Indicator
// ─────────────────────────────────────────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
          ),
      ],
    );
  }
}
