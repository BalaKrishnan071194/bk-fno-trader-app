/// Positions Screen — All open positions with exit/adjust actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshPositions();
    });
  }

  void _showExitConfirmation(BuildContext context, String symbol) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Exit Position'),
        content: Text('Are you sure you want to exit $symbol?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final message = await context.read<AppProvider>().exitPosition(symbol);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showAdjustSLDialog(BuildContext context, String symbol, double currentSL) {
    final controller = TextEditingController(text: currentSL.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: Text('Adjust SL for $symbol'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New Stop Price',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newSL = double.tryParse(controller.text);
              if (newSL == null || newSL <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid price')),
                );
                return;
              }
              Navigator.pop(ctx);
              final message = await context.read<AppProvider>().updateStopLoss(symbol, newSL);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final positionList = provider.positions;
        final positions = positionList?.positions ?? [];

        return LoadingOverlay(
          isLoading: provider.isLoading,
          child: RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () => provider.refreshPositions(),
            child: positions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: positions.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildHeader(provider);
                      }
                      final pos = positions[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PositionCard(
                          position: pos,
                          showActions: true,
                          onExit: () => _showExitConfirmation(context, pos.symbol),
                          onAdjustSL: () => _showAdjustSLDialog(
                            context,
                            pos.symbol,
                            pos.stopPrice,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppProvider provider) {
    final positionList = provider.positions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Positions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${positionList?.positions.length ?? 0} Active',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (positionList != null)
          Row(
            children: [
              Text(
                'Total P&L: ',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                '${positionList.totalPnl >= 0 ? "+" : ""}₹${positionList.totalPnl.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: positionList.totalPnl >= 0
                      ? AppTheme.primaryGreen
                      : AppTheme.primaryRed,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Capital: ₹${(positionList.totalCapitalUsed / 100000).toStringAsFixed(2)}L',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
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
            Icons.inbox_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No open positions',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check the Signals tab for new opportunities',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
