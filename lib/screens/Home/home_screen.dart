import 'package:cleaner_app/pages/new_test_page.dart';
import 'package:cleaner_app/providers/onboarding_provider.dart';
import 'package:cleaner_app/providers/purchases_provider.dart';
import 'package:cleaner_app/screens/ContactScreen/contact_screen.dart';
import 'package:cleaner_app/screens/Splash/splash_screen.dart';
import 'package:cleaner_app/screens/Subscription/subscription_screen.dart';
import 'package:cleaner_app/services/secure_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:disk_space/disk_space.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:cleaner_app/screens/Home/widgets/storage_usage_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalGb = 0;
  double _freeGb = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Contact> contacts = [];

  // DEBUG: Onboarding'i resetle ve splash screen'e git
  void _resetOnboarding() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Onboarding'),
        content: const Text(
            'Are you sure you want to reset the onboarding process? This will take you back to the welcome screen.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () async {
              Navigator.pop(context);

              // Onboarding'i sıfırla
              final onboardingProvider =
                  Provider.of<OnboardingProvider>(context, listen: false);
              await SecureStorageService.delete('onboarding_completed');
              onboardingProvider.reset();

              // Splash screen'e git
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Fotoğraf erişim iznini kontrol et
  Future<bool> _checkPhotoPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
      ),
    );
    return permission.isAuth || permission.hasAccess;
  }

  // İzin yoksa native popup göster
  Future<void> _navigateWithPermissionCheck(Widget destination) async {
    final hasPermission = await _checkPhotoPermission();

    if (hasPermission) {
      // İzin varsa direkt sayfaya git
      if (mounted) {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(builder: (context) => destination),
        );
      }
    } else {
      // İzin reddedildiyse, kullanıcıyı settings'e yönlendir
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Photo Access Required'),
            content: const Text(
              'This feature requires access to your photo library. Please enable photo access in Settings.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Open Settings'),
                onPressed: () {
                  PhotoManager.openSetting();
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double usedGb = (_totalGb - _freeGb).clamp(0.0, _totalGb);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Cleaner'),
            // DEBUG butonu - sadece debug modda görünür
            trailing: kDebugMode
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.refresh_circled,
                      color: CupertinoColors.systemRed,
                    ),
                    onPressed: _resetOnboarding,
                  )
                : null,
          ),

          // Actions list section
        ],
      ),
    );
  }
}
