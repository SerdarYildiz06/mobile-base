import 'package:cleaner_app/providers/onboarding_provider.dart';
import 'package:cleaner_app/providers/purchases_provider.dart';
import 'package:cleaner_app/screens/BottomNavBar/bottom_nav_bar.dart';
import 'package:cleaner_app/screens/Onboarding/onboarding_screen.dart';
import 'package:cleaner_app/services/telegram_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initializeAndCheck();
    });
  }

  /// Firebase Analytics ve diğer başlatma işlemlerini yapar
  Future<void> _initializeAndCheck() async {
    try {
      /// Firebase Analytics event'ini logla
      await FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {
          'screen_name': 'Splash',
        },
      );
    } catch (e) {
      /// Firebase henüz hazır değilse hata yakalayıp devam et
      debugPrint('Firebase Analytics hatası: $e');
    }

    /// Ana kontrol işlemini başlat
    await check();
  }

  Future<void> check() async {
    try {
      /// Purchases provider'ı başlat
      PurchasesProvider purchasesProvider =
          Provider.of<PurchasesProvider>(context, listen: false);
      await purchasesProvider.initPurchases();

      /// Telegram servisini kaydet
      TelegramService().registerLog();

      /// Onboarding kontrolü yap
      OnboardingProvider onboardingProvider =
          Provider.of<OnboardingProvider>(context, listen: false);
      bool onboardingCompleted =
          await onboardingProvider.isOnboardingCompleted();

      // /// İzin kontrolü yap
      // await PhotoManager.requestPermissionExtend(
      //   requestOption: const PermissionRequestOption(
      //     iosAccessLevel: IosAccessLevel.readWrite,
      //   ),
      // );

      /// 3 saniye bekle ve sonra yönlendirme yap
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        if (onboardingCompleted) {
          /// Onboarding tamamlanmış - izin durumuna bakmadan ana ekrana git
          /// İzin gerektiğinde native popup gelecek
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => const BottomNavBar()),
            (route) => false,
          );
        } else {
          /// Onboarding göster
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => const OnboardingScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      /// Hata durumunda da ana ekrana yönlendir
      debugPrint('Splash screen hatası: $e');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => const BottomNavBar()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'lib/assets/logo/app_logo.png',
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Cleaner',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Builder(builder: (context) {
              return SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(
                      begin: 0,
                      end: 1,
                    ),
                    builder: (context, value, _) => Column(
                      children: [
                        CupertinoActivityIndicator(
                          radius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
