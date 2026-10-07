# F&O Trading Mobile App

A Flutter mobile app for F&O swing trading, paired with a FastAPI backend.

## Structure

```
mobile_app/
├── SPEC.md                    # Full technical specification
├── api/                       # FastAPI backend
│   ├── main.py                # FastAPI app with all endpoints
│   ├── models.py              # Pydantic response models
│   └── requirements.txt       # Python dependencies
│
└── flutter_app/               # Flutter mobile app
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── theme.dart         # Dark trading theme
    │   ├── models/            # Dart data classes
    │   │   └── models.dart
    │   ├── services/          # API client & state
    │   │   ├── api_service.dart
    │   │   └── app_provider.dart
    │   ├── screens/           # UI screens
    │   │   ├── dashboard_screen.dart
    │   │   ├── positions_screen.dart
    │   │   ├── signals_screen.dart
    │   │   ├── performance_screen.dart
    │   │   ├── settings_screen.dart
    │   │   └── login_screen.dart
    │   └── widgets/           # Reusable components
    │       └── common_widgets.dart
    └── pubspec.yaml           # Flutter dependencies
```

## Getting Started

### 1. Start the FastAPI Backend

```bash
cd mobile_app/api

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

The API will be available at `http://localhost:8080`. 

API docs: `http://localhost:8080/docs`

### 2. Configure the Flutter App

Edit `lib/services/api_service.dart` and set your VPS IP:

```dart
static const String _baseUrl = 'http://YOUR_VPS_IP:8080/api';
```

### 3. Build the Flutter App

```bash
cd mobile_app/flutter_app

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## API Authentication

The app uses simple API key authentication:

1. Set `FNO_API_KEY` environment variable on the server
2. Enter the same key in the app's login screen
3. The app stores the JWT token locally

For production, implement proper JWT with refresh tokens.

## Screens

| Screen | Description |
|--------|-------------|
| **Dashboard** | P&L summary, NIFTY status, top positions |
| **Positions** | All open positions with Exit/Adjust SL |
| **Signals** | Scanner signals with Take/Skip actions |
| **Performance** | P&L chart, stats, trade history |
| **Settings** | Config display, Zerodha status |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Authenticate |
| GET | `/api/dashboard` | Dashboard summary |
| GET | `/api/positions` | List positions |
| POST | `/api/positions/{symbol}/exit` | Exit position |
| PUT | `/api/positions/{symbol}/sl` | Update stop-loss |
| GET | `/api/signals` | List signals |
| POST | `/api/scan` | Trigger scanner |
| GET | `/api/performance` | Stats & history |
| GET | `/api/settings` | Current config |

## Deployment

### Backend (VPS)

```bash
# On VPS
cd ~/bk-swing-stock-handler
pip install -r mobile_app/api/requirements.txt

# Run with systemd or supervisor
uvicorn mobile_app.api.main:app --host 0.0.0.0 --port 8080
```

### Flutter App

1. Build release APK
2. Transfer to phone via USB/cloud
3. Install (enable "Unknown sources" in Android settings)

## Tech Stack

- **Backend**: FastAPI, Pydantic, Uvicorn
- **Frontend**: Flutter 3.x, Provider, fl_chart
- **Auth**: Simple API key → JWT token
