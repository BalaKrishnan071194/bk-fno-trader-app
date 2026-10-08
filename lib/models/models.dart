/// Data models for F&O Trading App
/// Mirrors the FastAPI Pydantic models

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum SignalType { CALL, PUT }

enum Regime { BULLISH, BEARISH, NEUTRAL }

/// Market segment selector
enum MarketType {
  fno,      // F&O Options
  equity,   // Indian Equity (Stocks)
  us,       // US Stocks (future)
}

extension MarketTypeExtension on MarketType {
  String get displayName {
    switch (this) {
      case MarketType.fno:
        return 'F&O';
      case MarketType.equity:
        return 'Equity';
      case MarketType.us:
        return 'US Stocks';
    }
  }
  
  String get flag {
    switch (this) {
      case MarketType.fno:
      case MarketType.equity:
        return '🇮🇳';
      case MarketType.us:
        return '🇺🇸';
    }
  }
  
  String get fullName => '$flag $displayName';
}

// ─────────────────────────────────────────────────────────────────────────────
// Funds
// ─────────────────────────────────────────────────────────────────────────────

class EquityFunds {
  final double totalInvested;
  final double currentValue;
  final double unrealizedPnl;
  final double unrealizedPnlPct;
  final double realizedPnl;
  final int holdingsCount;

  EquityFunds({
    required this.totalInvested,
    required this.currentValue,
    required this.unrealizedPnl,
    required this.unrealizedPnlPct,
    required this.realizedPnl,
    required this.holdingsCount,
  });

  factory EquityFunds.fromJson(Map<String, dynamic> json) {
    return EquityFunds(
      totalInvested: (json['total_invested'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      unrealizedPnlPct: (json['unrealized_pnl_pct'] as num?)?.toDouble() ?? 0.0,
      realizedPnl: (json['realized_pnl'] as num?)?.toDouble() ?? 0.0,
      holdingsCount: json['holdings_count'] as int,
    );
  }
}

class FnoFunds {
  final double capitalDeployed;
  final double unrealizedPnl;
  final double unrealizedPnlPct;
  final double realizedPnl;
  final int openPositions;

  FnoFunds({
    required this.capitalDeployed,
    required this.unrealizedPnl,
    required this.unrealizedPnlPct,
    required this.realizedPnl,
    required this.openPositions,
  });

  factory FnoFunds.fromJson(Map<String, dynamic> json) {
    return FnoFunds(
      capitalDeployed: (json['capital_deployed'] as num).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      unrealizedPnlPct: (json['unrealized_pnl_pct'] as num?)?.toDouble() ?? 0.0,
      realizedPnl: (json['realized_pnl'] as num?)?.toDouble() ?? 0.0,
      openPositions: json['open_positions'] as int,
    );
  }
}

class FundsData {
  final double totalCapital;
  final double availableCash;
  final double collateral;
  final EquityFunds equity;
  final FnoFunds fno;
  final double totalUnrealizedPnl;
  final double totalRealizedPnl;
  final double totalPnl;
  final bool zerodhaConnected;
  final DateTime? lastUpdated;

  FundsData({
    required this.totalCapital,
    required this.availableCash,
    required this.collateral,
    required this.equity,
    required this.fno,
    required this.totalUnrealizedPnl,
    required this.totalRealizedPnl,
    required this.totalPnl,
    required this.zerodhaConnected,
    this.lastUpdated,
  });

  factory FundsData.fromJson(Map<String, dynamic> json) {
    return FundsData(
      totalCapital: (json['total_capital'] as num).toDouble(),
      availableCash: (json['available_cash'] as num).toDouble(),
      collateral: (json['collateral'] as num?)?.toDouble() ?? 0.0,
      equity: EquityFunds.fromJson(json['equity']),
      fno: FnoFunds.fromJson(json['fno']),
      totalUnrealizedPnl: (json['total_unrealized_pnl'] as num?)?.toDouble() ?? 0.0,
      totalRealizedPnl: (json['total_realized_pnl'] as num?)?.toDouble() ?? 0.0,
      totalPnl: (json['total_pnl'] as num).toDouble(),
      zerodhaConnected: json['zerodha_connected'] as bool? ?? false,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Equity Holdings (Stocks)
// ─────────────────────────────────────────────────────────────────────────────

class EquityHolding {
  final String symbol;
  final String tradingsymbol;
  final String exchange;
  final String isin;
  final int quantity;
  final double averagePrice;
  final double lastPrice;
  final double closePrice;
  final double pnl;
  final double pnlPct;
  final double dayChange;
  final double dayChangePct;
  final double investedValue;
  final double currentValue;
  final int t1Quantity;
  final int collateralQuantity;
  final String? collateralType;

  EquityHolding({
    required this.symbol,
    required this.tradingsymbol,
    required this.exchange,
    required this.isin,
    required this.quantity,
    required this.averagePrice,
    required this.lastPrice,
    required this.closePrice,
    required this.pnl,
    required this.pnlPct,
    required this.dayChange,
    required this.dayChangePct,
    required this.investedValue,
    required this.currentValue,
    this.t1Quantity = 0,
    this.collateralQuantity = 0,
    this.collateralType,
  });

  factory EquityHolding.fromJson(Map<String, dynamic> json) {
    return EquityHolding(
      symbol: json['symbol'] as String,
      tradingsymbol: json['tradingsymbol'] as String,
      exchange: json['exchange'] as String? ?? 'NSE',
      isin: json['isin'] as String? ?? '',
      quantity: json['quantity'] as int,
      averagePrice: (json['average_price'] as num).toDouble(),
      lastPrice: (json['last_price'] as num).toDouble(),
      closePrice: (json['close_price'] as num).toDouble(),
      pnl: (json['pnl'] as num).toDouble(),
      pnlPct: (json['pnl_pct'] as num).toDouble(),
      dayChange: (json['day_change'] as num).toDouble(),
      dayChangePct: (json['day_change_pct'] as num).toDouble(),
      investedValue: (json['invested_value'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      t1Quantity: json['t1_quantity'] as int? ?? 0,
      collateralQuantity: json['collateral_quantity'] as int? ?? 0,
      collateralType: json['collateral_type'] as String?,
    );
  }

  bool get isProfit => pnl >= 0;
  bool get isDayPositive => dayChange >= 0;
}

class EquityHoldingsList {
  final List<EquityHolding> holdings;
  final double totalInvested;
  final double totalCurrent;
  final double totalPnl;
  final double totalPnlPct;
  final double totalDayChange;
  final int holdingsCount;

  EquityHoldingsList({
    required this.holdings,
    required this.totalInvested,
    required this.totalCurrent,
    required this.totalPnl,
    required this.totalPnlPct,
    required this.totalDayChange,
    required this.holdingsCount,
  });

  factory EquityHoldingsList.fromJson(Map<String, dynamic> json) {
    return EquityHoldingsList(
      holdings: (json['holdings'] as List)
          .map((h) => EquityHolding.fromJson(h))
          .toList(),
      totalInvested: (json['total_invested'] as num).toDouble(),
      totalCurrent: (json['total_current'] as num).toDouble(),
      totalPnl: (json['total_pnl'] as num).toDouble(),
      totalPnlPct: (json['total_pnl_pct'] as num).toDouble(),
      totalDayChange: (json['total_day_change'] as num).toDouble(),
      holdingsCount: json['holdings_count'] as int,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Data
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

// ─────────────────────────────────────────────────────────────────────────────
// App Control (Trading Loop Status)
// ─────────────────────────────────────────────────────────────────────────────

/// Status of a single trading app (India or F&O)
class AppStatus {
  final String app;
  final bool running;
  final int? pid;
  final String message;
  final bool inSchedule;

  AppStatus({
    required this.app,
    required this.running,
    this.pid,
    required this.message,
    this.inSchedule = false,
  });

  factory AppStatus.fromJson(Map<String, dynamic> json) {
    return AppStatus(
      app: json['app'] as String,
      running: json['running'] as bool,
      pid: json['pid'] as int?,
      message: json['message'] as String,
      inSchedule: json['in_schedule'] as bool? ?? false,
    );
  }

  /// User-friendly status text
  String get statusText => running ? 'Running' : 'Stopped';
  
  /// Status color indicator
  bool get isHealthy => running;
}

/// Combined status of all trading apps
class AppsStatus {
  final AppStatus india;
  final AppStatus fno;
  final ScheduleInfo schedule;
  final DateTime timestamp;

  AppsStatus({
    required this.india,
    required this.fno,
    required this.schedule,
    required this.timestamp,
  });

  factory AppsStatus.fromJson(Map<String, dynamic> json) {
    return AppsStatus(
      india: AppStatus.fromJson(json['india']),
      fno: AppStatus.fromJson(json['fno']),
      schedule: ScheduleInfo.fromJson(json['schedule']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// True if both apps are running
  bool get allRunning => india.running && fno.running;
  
  /// True if any app is running
  bool get anyRunning => india.running || fno.running;
}

/// Trading schedule information
class ScheduleInfo {
  final bool inSchedule;
  final String start;
  final String stop;

  ScheduleInfo({
    required this.inSchedule,
    required this.start,
    required this.stop,
  });

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      inSchedule: json['in_schedule'] as bool,
      start: json['start'] as String,
      stop: json['stop'] as String,
    );
  }

  String get scheduleText => '$start – $stop IST';
}

/// Result of app start/stop operation
class AppControlResult {
  final bool success;
  final String message;
  final String app;
  final bool running;
  final int? pid;

  AppControlResult({
    required this.success,
    required this.message,
    required this.app,
    required this.running,
    this.pid,
  });

  factory AppControlResult.fromJson(Map<String, dynamic> json) {
    return AppControlResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      app: json['app'] as String,
      running: json['running'] as bool,
      pid: json['pid'] as int?,
    );
  }
}
