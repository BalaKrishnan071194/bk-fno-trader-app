/// Data models for F&O Trading App
/// Mirrors the FastAPI Pydantic models

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum SignalType { CALL, PUT }

enum Regime { BULLISH, BEARISH, NEUTRAL }

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class DashboardData {
  final double todayPnl;
  final double totalPnl;
  final int openPositions;
  final double winRate;
  final double profitFactor;
  final Regime regime;
  final double niftyPrice;
  final double niftyChangePct;
  final bool zerodhaConnected;
  final DateTime? tokenExpiry;

  DashboardData({
    required this.todayPnl,
    required this.totalPnl,
    required this.openPositions,
    required this.winRate,
    required this.profitFactor,
    required this.regime,
    required this.niftyPrice,
    required this.niftyChangePct,
    required this.zerodhaConnected,
    this.tokenExpiry,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todayPnl: (json['today_pnl'] as num).toDouble(),
      totalPnl: (json['total_pnl'] as num).toDouble(),
      openPositions: json['open_positions'] as int,
      winRate: (json['win_rate'] as num).toDouble(),
      profitFactor: (json['profit_factor'] as num).toDouble(),
      regime: Regime.values.firstWhere(
        (e) => e.name == json['regime'],
        orElse: () => Regime.NEUTRAL,
      ),
      niftyPrice: (json['nifty_price'] as num).toDouble(),
      niftyChangePct: (json['nifty_change_pct'] as num).toDouble(),
      zerodhaConnected: json['zerodha_connected'] as bool,
      tokenExpiry: json['token_expiry'] != null
          ? DateTime.parse(json['token_expiry'])
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Position
// ─────────────────────────────────────────────────────────────────────────────

class OptionDetail {
  final String tradingsymbol;
  final double strike;
  final DateTime expiry;
  final String optionType;
  final int lotSize;
  final int dte;

  OptionDetail({
    required this.tradingsymbol,
    required this.strike,
    required this.expiry,
    required this.optionType,
    required this.lotSize,
    required this.dte,
  });

  factory OptionDetail.fromJson(Map<String, dynamic> json) {
    return OptionDetail(
      tradingsymbol: json['tradingsymbol'] as String,
      strike: (json['strike'] as num).toDouble(),
      expiry: DateTime.parse(json['expiry']),
      optionType: json['option_type'] as String,
      lotSize: json['lot_size'] as int,
      dte: json['dte'] as int,
    );
  }
}

class Position {
  final String symbol;
  final SignalType signalType;
  final OptionDetail option;
  final int lots;
  final double entryPremium;
  final double ltp;
  final double stopPrice;
  final double targetPrice;
  final double optionStop;
  final double pnlAmount;
  final double pnlPct;
  final int daysHeld;
  final DateTime entryDate;
  final String sector;

  Position({
    required this.symbol,
    required this.signalType,
    required this.option,
    required this.lots,
    required this.entryPremium,
    required this.ltp,
    required this.stopPrice,
    required this.targetPrice,
    required this.optionStop,
    required this.pnlAmount,
    required this.pnlPct,
    required this.daysHeld,
    required this.entryDate,
    required this.sector,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      symbol: json['symbol'] as String,
      signalType: SignalType.values.firstWhere(
        (e) => e.name == json['signal_type'],
      ),
      option: OptionDetail.fromJson(json['option']),
      lots: json['lots'] as int,
      entryPremium: (json['entry_premium'] as num).toDouble(),
      ltp: (json['ltp'] as num).toDouble(),
      stopPrice: (json['stop_price'] as num).toDouble(),
      targetPrice: (json['target_price'] as num).toDouble(),
      optionStop: (json['option_stop'] as num).toDouble(),
      pnlAmount: (json['pnl_amount'] as num).toDouble(),
      pnlPct: (json['pnl_pct'] as num).toDouble(),
      daysHeld: json['days_held'] as int,
      entryDate: DateTime.parse(json['entry_date']),
      sector: json['sector'] as String,
    );
  }

  String get displayName => '${symbol} ${option.strike.toInt()} ${option.optionType}';
  bool get isProfit => pnlAmount >= 0;
}

class PositionList {
  final List<Position> positions;
  final double totalPnl;
  final double totalCapitalUsed;

  PositionList({
    required this.positions,
    required this.totalPnl,
    required this.totalCapitalUsed,
  });

  factory PositionList.fromJson(Map<String, dynamic> json) {
    return PositionList(
      positions: (json['positions'] as List)
          .map((p) => Position.fromJson(p))
          .toList(),
      totalPnl: (json['total_pnl'] as num).toDouble(),
      totalCapitalUsed: (json['total_capital_used'] as num).toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signal
// ─────────────────────────────────────────────────────────────────────────────

class Signal {
  final String id;
  final String symbol;
  final SignalType signalType;
  final DateTime signalDate;
  final double stockPrice;
  final double strike;
  final double premiumEstimate;
  final double stopPrice;
  final double targetPrice;
  final double riskPct;
  final double rsRank;
  final double score;
  final String sector;
  final double volumeRatio;

  Signal({
    required this.id,
    required this.symbol,
    required this.signalType,
    required this.signalDate,
    required this.stockPrice,
    required this.strike,
    required this.premiumEstimate,
    required this.stopPrice,
    required this.targetPrice,
    required this.riskPct,
    required this.rsRank,
    required this.score,
    required this.sector,
    required this.volumeRatio,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      signalType: SignalType.values.firstWhere(
        (e) => e.name == json['signal_type'],
      ),
      signalDate: DateTime.parse(json['signal_date']),
      stockPrice: (json['stock_price'] as num).toDouble(),
      strike: (json['strike'] as num).toDouble(),
      premiumEstimate: (json['premium_estimate'] as num).toDouble(),
      stopPrice: (json['stop_price'] as num).toDouble(),
      targetPrice: (json['target_price'] as num).toDouble(),
      riskPct: (json['risk_pct'] as num).toDouble(),
      rsRank: (json['rs_rank'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      sector: json['sector'] as String,
      volumeRatio: (json['volume_ratio'] as num).toDouble(),
    );
  }
}

class SignalList {
  final List<Signal> signals;
  final DateTime? lastScanTime;
  final Regime regime;

  SignalList({
    required this.signals,
    this.lastScanTime,
    required this.regime,
  });

  factory SignalList.fromJson(Map<String, dynamic> json) {
    return SignalList(
      signals: (json['signals'] as List)
          .map((s) => Signal.fromJson(s))
          .toList(),
      lastScanTime: json['last_scan_time'] != null
          ? DateTime.parse(json['last_scan_time'])
          : null,
      regime: Regime.values.firstWhere(
        (e) => e.name == json['regime'],
        orElse: () => Regime.NEUTRAL,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance
// ─────────────────────────────────────────────────────────────────────────────

class DirectionStats {
  final int trades;
  final double pnl;
  final double winRate;
  final double profitFactor;

  DirectionStats({
    required this.trades,
    required this.pnl,
    required this.winRate,
    required this.profitFactor,
  });

  factory DirectionStats.fromJson(Map<String, dynamic> json) {
    return DirectionStats(
      trades: json['trades'] as int,
      pnl: (json['pnl'] as num).toDouble(),
      winRate: (json['win_rate'] as num).toDouble(),
      profitFactor: (json['profit_factor'] as num).toDouble(),
    );
  }
}

class DailyPnl {
  final DateTime date;
  final double pnl;

  DailyPnl({required this.date, required this.pnl});

  factory DailyPnl.fromJson(Map<String, dynamic> json) {
    return DailyPnl(
      date: DateTime.parse(json['date']),
      pnl: (json['pnl'] as num).toDouble(),
    );
  }
}

class PerformanceData {
  final double totalPnl;
  final double winRate;
  final double profitFactor;
  final double maxDrawdown;
  final int totalTrades;
  final double avgTradePnl;
  final double avgWinner;
  final double avgLoser;
  final DirectionStats callStats;
  final DirectionStats putStats;
  final List<DailyPnl> dailyPnl;

  PerformanceData({
    required this.totalPnl,
    required this.winRate,
    required this.profitFactor,
    required this.maxDrawdown,
    required this.totalTrades,
    required this.avgTradePnl,
    required this.avgWinner,
    required this.avgLoser,
    required this.callStats,
    required this.putStats,
    required this.dailyPnl,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      totalPnl: (json['total_pnl'] as num).toDouble(),
      winRate: (json['win_rate'] as num).toDouble(),
      profitFactor: (json['profit_factor'] as num).toDouble(),
      maxDrawdown: (json['max_drawdown'] as num).toDouble(),
      totalTrades: json['total_trades'] as int,
      avgTradePnl: (json['avg_trade_pnl'] as num).toDouble(),
      avgWinner: (json['avg_winner'] as num).toDouble(),
      avgLoser: (json['avg_loser'] as num).toDouble(),
      callStats: DirectionStats.fromJson(json['call_stats']),
      putStats: DirectionStats.fromJson(json['put_stats']),
      dailyPnl: (json['daily_pnl'] as List)
          .map((d) => DailyPnl.fromJson(d))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trade History
// ─────────────────────────────────────────────────────────────────────────────

class TradeHistoryItem {
  final String symbol;
  final SignalType signalType;
  final String tradingsymbol;
  final DateTime entryDate;
  final DateTime exitDate;
  final double entryPremium;
  final double exitPremium;
  final int lots;
  final double pnlAmount;
  final double pnlPct;
  final String exitReason;
  final int daysHeld;

  TradeHistoryItem({
    required this.symbol,
    required this.signalType,
    required this.tradingsymbol,
    required this.entryDate,
    required this.exitDate,
    required this.entryPremium,
    required this.exitPremium,
    required this.lots,
    required this.pnlAmount,
    required this.pnlPct,
    required this.exitReason,
    required this.daysHeld,
  });

  factory TradeHistoryItem.fromJson(Map<String, dynamic> json) {
    return TradeHistoryItem(
      symbol: json['symbol'] as String,
      signalType: SignalType.values.firstWhere(
        (e) => e.name == json['signal_type'],
      ),
      tradingsymbol: json['tradingsymbol'] as String,
      entryDate: DateTime.parse(json['entry_date']),
      exitDate: DateTime.parse(json['exit_date']),
      entryPremium: (json['entry_premium'] as num).toDouble(),
      exitPremium: (json['exit_premium'] as num).toDouble(),
      lots: json['lots'] as int,
      pnlAmount: (json['pnl_amount'] as num).toDouble(),
      pnlPct: (json['pnl_pct'] as num).toDouble(),
      exitReason: json['exit_reason'] as String,
      daysHeld: json['days_held'] as int,
    );
  }

  bool get isProfit => pnlAmount >= 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings
// ─────────────────────────────────────────────────────────────────────────────

class Settings {
  final int maxPositions;
  final double capital;
  final double positionSizePct;
  final double optionStopPct;
  final int maxLots;
  final double minScore;
  final bool notificationsEnabled;
  final bool autoTradeEnabled;

  Settings({
    required this.maxPositions,
    required this.capital,
    required this.positionSizePct,
    required this.optionStopPct,
    required this.maxLots,
    required this.minScore,
    required this.notificationsEnabled,
    required this.autoTradeEnabled,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      maxPositions: json['max_positions'] as int,
      capital: (json['capital'] as num).toDouble(),
      positionSizePct: (json['position_size_pct'] as num).toDouble(),
      optionStopPct: (json['option_stop_pct'] as num).toDouble(),
      maxLots: json['max_lots'] as int,
      minScore: (json['min_score'] as num).toDouble(),
      notificationsEnabled: json['notifications_enabled'] as bool,
      autoTradeEnabled: json['auto_trade_enabled'] as bool,
    );
  }
}
