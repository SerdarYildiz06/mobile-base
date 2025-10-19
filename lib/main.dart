import 'package:cleaner_app/firebase_options.dart';
import 'package:cleaner_app/providers/onboarding_provider.dart';
import 'package:cleaner_app/providers/purchases_provider.dart';
import 'package:cleaner_app/screens/Splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  /// Widget binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  /// Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Sentry ile hata yakalama ve Firebase başlatma
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PurchasesProvider()),
        ChangeNotifierProvider(create: (context) => OnboardingProvider()),
      ],
      child: CupertinoApp(
        title: "Cleaner",
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemGreen,
          brightness: Brightness.light,
          scaffoldBackgroundColor: CupertinoColors.systemGrey6,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
