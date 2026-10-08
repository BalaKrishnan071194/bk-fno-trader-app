/// F&O Trading App — Main entry point
/// 
/// A Flutter mobile app for F&O swing trading with FastAPI backend.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'models/models.dart';
import 'services/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/positions_screen.dart';
import 'screens/signals_screen.dart';
import 'screens/performance_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/equity_holdings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FnoTraderApp());
}

class FnoTraderApp extends StatelessWidget {
  const FnoTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          // Update system UI based on theme
          final isDark = provider.isDarkMode;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? AppTheme.darkBgTertiary : AppTheme.lightBgSecondary,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp(
            title: 'F&O Trader',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper that checks auth state and redirects
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoggedIn) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final market = provider.selectedMarket;
        
        // Build screens based on selected market
        final screens = _getScreensForMarket(market);
        final navItems = _getNavItemsForMarket(market);

        return Scaffold(
          appBar: AppBar(
            title: _MarketSelector(
              selectedMarket: market,
              onChanged: (m) => provider.setMarket(m),
            ),
            centerTitle: false,
            actions: [
              // Theme toggle button
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                onPressed: () => provider.toggleTheme(),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex.clamp(0, screens.length - 1),
              children: screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex.clamp(0, navItems.length - 1),
            onTap: (index) => setState(() => _currentIndex = index),
            items: navItems,
          ),
        );
      },
    );
  }

  List<Widget> _getScreensForMarket(MarketType market) {
    switch (market) {
      case MarketType.fno:
        return const [
          DashboardScreen(),
          PositionsScreen(),
          SignalsScreen(),
          PerformanceScreen(),
          SettingsScreen(),
        ];
      case MarketType.equity:
        return const [
          DashboardScreen(),
          EquityHoldingsScreen(),
          PerformanceScreen(),
          SettingsScreen(),
        ];
      case MarketType.us:
        // Future: US stocks screens
        return const [
          DashboardScreen(),
          SettingsScreen(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForMarket(MarketType market) {
    switch (market) {
      case MarketType.fno:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Positions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Signals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];
      case MarketType.equity:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'Holdings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];
      case MarketType.us:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];
    }
  }
}

/// Market Selector Dropdown in AppBar
class _MarketSelector extends StatelessWidget {
  final MarketType selectedMarket;
  final ValueChanged<MarketType> onChanged;

  const _MarketSelector({
    required this.selectedMarket,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MarketType>(
      initialValue: selectedMarket,
      onSelected: onChanged,
      offset: const Offset(0, 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedMarket.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 24),
        ],
      ),
      itemBuilder: (context) => [
        _buildMenuItem(context, MarketType.fno),
        _buildMenuItem(context, MarketType.equity),
        _buildMenuItem(context, MarketType.us, enabled: false), // US coming soon
      ],
    );
  }

  PopupMenuItem<MarketType> _buildMenuItem(BuildContext context, MarketType market, {bool enabled = true}) {
    final isSelected = market == selectedMarket;
    final theme = Theme.of(context);
    
    return PopupMenuItem<MarketType>(
      value: market,
      enabled: enabled,
      child: Row(
        children: [
          Text(market.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              market.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: enabled 
                    ? theme.textTheme.bodyLarge?.color 
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 18, color: AppTheme.primaryGreen),
          if (!enabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Soon',
                style: TextStyle(fontSize: 10, color: context.textSec),
              ),
            ),
        ],
      ),
    );
  }
}
