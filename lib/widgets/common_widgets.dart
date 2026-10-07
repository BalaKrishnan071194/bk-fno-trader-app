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
// Position Card
// ─────────────────────────────────────────────────────────────────────────────

class PositionCard extends StatelessWidget {
  final Position position;
  final VoidCallback? onExit;
  final VoidCallback? onAdjustSL;
  final bool showActions;

  const PositionCard({
    super.key,
    required this.position,
    this.onExit,
    this.onAdjustSL,
    this.showActions = false,
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                position.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SignalBadge(type: position.signalType),
            ],
          ),
          const SizedBox(height: 8),
          
          // Details row 1
          Row(
            children: [
              _DetailItem(label: 'Entry', value: '₹${position.entryPremium.toStringAsFixed(2)}'),
              _DetailItem(label: 'LTP', value: '₹${position.ltp.toStringAsFixed(2)}'),
              _DetailItem(
                label: 'P&L',
                value: '${position.isProfit ? "+" : ""}₹${position.pnlAmount.toStringAsFixed(0)}',
                isProfit: position.isProfit,
                alignRight: true,
              ),
            ],
          ),
          
          if (showActions) ...[
            const SizedBox(height: 10),
            // Details row 2
            Row(
              children: [
                _DetailItem(label: 'SL', value: '₹${position.optionStop.toStringAsFixed(2)}'),
                _DetailItem(label: 'Target', value: '₹${(position.entryPremium * 2).toStringAsFixed(0)}'),
                _DetailItem(label: 'Lots', value: '${position.lots} (${position.option.lotSize})'),
              ],
            ),
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAdjustSL,
                    child: const Text('Adjust SL', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onExit,
                    child: const Text('Exit Now', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
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
