# F&O Trading Mobile App — Technical Specification

## Overview

A Flutter mobile app for monitoring and managing F&O swing trading positions, with a FastAPI backend that wraps existing Telegram handlers.

## Architecture

```
┌─────────────────┐     HTTPS/JSON      ┌──────────────────┐
│  Flutter App    │ ◄─────────────────► │  FastAPI Server  │
│  (iOS/Android)  │                     │  (VPS: port 8080)│
└─────────────────┘                     └────────┬─────────┘
                                                 │
                                                 ▼
                                    ┌────────────────────────┐
                                    │  Existing FNO Module   │
                                    │  - FnoSwingLoop        │
                                    │  - FnoTelegramHandlers │
                                    │  - FnoPositionManager  │
                                    └────────────────────────┘
```

## API Endpoints (FastAPI Backend)

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Validate API key, return JWT |
| GET | `/api/auth/status` | Check Zerodha connection status |

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard` | Summary: P&L, positions count, regime |

### Positions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/positions` | List all open positions with live LTP |
| GET | `/api/positions/{symbol}` | Single position detail |
| POST | `/api/positions/{symbol}/exit` | Exit position |
| PUT | `/api/positions/{symbol}/sl` | Update stop-loss |

### Signals
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/signals` | Current pending signals |
| POST | `/api/signals/{id}/take` | Execute signal (buy) |
| POST | `/api/signals/{id}/skip` | Skip signal |
| POST | `/api/scan` | Trigger manual scan |

### Performance
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/performance` | P&L stats, win rate, profit factor |
| GET | `/api/history` | Closed trades history |

### Settings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/settings` | Current config |
| PUT | `/api/settings` | Update config (max positions, etc.) |

## Data Models

### DashboardResponse
```json
{
  "today_pnl": 12450.0,
  "total_pnl": 185230.0,
  "open_positions": 9,
  "win_rate": 75.0,
  "regime": "BULLISH",
  "nifty_price": 25432.50,
  "nifty_change_pct": 0.82,
  "zerodha_connected": true,
  "token_expiry": "2026-10-07T15:30:00"
}
```

### PositionResponse
```json
{
  "symbol": "TCS",
  "signal_type": "PUT",
  "tradingsymbol": "TCS26OCT4200PE",
  "strike": 4200,
  "lots": 1,
  "lot_size": 175,
  "entry_price": 85.50,
  "ltp": 72.30,
  "stop_price": 42.75,
  "target_price": 170.0,
  "pnl_amount": 2310.0,
  "pnl_pct": 15.4,
  "days_held": 3,
  "entry_date": "2026-10-04"
}
```

### SignalResponse
```json
{
  "id": "HDFCBANK-CALL-2026-10-07",
  "symbol": "HDFCBANK",
  "signal_type": "CALL",
  "stock_price": 1680.0,
  "strike": 1700,
  "premium_estimate": 45.0,
  "stop_price": 1630.0,
  "target_price": 1780.0,
  "rs_rank": 87.5,
  "score": 3.5,
  "sector": "Banking"
}
```

## Flutter App Screens

### 1. Dashboard (Home)
- Today's P&L (large, colored)
- Total F&O P&L
- Open positions count
- Win rate percentage
- NIFTY status with regime badge
- Quick access cards for top 2 positions
- Zerodha connection indicator

### 2. Positions
- List of all open positions
- Each card shows:
  - Symbol + option type badge (CALL/PUT)
  - Entry price, LTP, P&L
  - Stop-loss, target, lots
  - "Exit" and "Adjust SL" buttons
- Pull-to-refresh for live LTP update

### 3. Signals
- Pending signals from scanner
- "Scan Now" button
- Each signal card:
  - Symbol + direction badge
  - Stock price, strike, premium estimate
  - RS rank, score, stop, target
  - "Take Signal" and "Skip" buttons
- Recent taken/skipped signals (grayed)

### 4. Performance
- Equity curve chart (30 days)
- Stats grid:
  - Total P&L
  - Win Rate
  - Profit Factor
  - Max Drawdown
  - Total Trades
  - Avg Trade
- CALL vs PUT breakdown

### 5. Settings
- Trading parameters:
  - Max positions
  - Position size %
  - Default SL %
  - Default target %
- Notification toggles
- Zerodha connection status
- Re-authenticate button

## Security

1. **API Key Authentication**: Simple bearer token for MVP
2. **HTTPS Only**: All traffic encrypted
3. **Rate Limiting**: 60 requests/minute per client
4. **No Credential Storage**: App never stores Zerodha creds

## Tech Stack

### Backend (FastAPI)
- Python 3.12
- FastAPI + Uvicorn
- Pydantic models
- JWT authentication
- Wraps existing FnoTelegramHandlers

### Frontend (Flutter)
- Flutter 3.x
- Dart
- Provider for state management
- http package for API calls
- fl_chart for charts

## File Structure

```
mobile_app/
├── api/
│   ├── main.py              # FastAPI app entry
│   ├── routes/
│   │   ├── auth.py
│   │   ├── dashboard.py
│   │   ├── positions.py
│   │   ├── signals.py
│   │   ├── performance.py
│   │   └── settings.py
│   ├── models.py            # Pydantic response models
│   ├── deps.py              # Dependencies (auth, db)
│   └── requirements.txt
│
└── flutter_app/
    ├── lib/
    │   ├── main.dart
    │   ├── models/          # Dart data classes
    │   ├── services/        # API client
    │   ├── screens/         # UI screens
    │   └── widgets/         # Reusable components
    ├── pubspec.yaml
    └── README.md
```

## Deployment

### Backend
1. Run on VPS alongside existing FNO loop
2. `uvicorn mobile_app.api.main:app --host 0.0.0.0 --port 8080`
3. Nginx reverse proxy with SSL

### Flutter App
1. Build APK: `flutter build apk --release`
2. Distribute via direct APK install (not Play Store for MVP)
