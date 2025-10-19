import 'package:cleaner_app/providers/purchases_provider.dart';
import 'package:cleaner_app/screens/Subscription/subscription_screen.dart';
import 'package:cleaner_app/services/secure_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:cleaner_app/screens/Home/home_screen.dart';
import 'package:cleaner_app/screens/Settings/settings_screen.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool _hasShownSubscription = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkPremiumStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Her ekran değişikliğinde premium durumunu kontrol et
    if (!_hasShownSubscription) {
      _checkPremiumStatus();
    }
  }

  void _checkPremiumStatus() async {
    final purchasesProvider =
        Provider.of<PurchasesProvider>(context, listen: false);

    // Subscription'ın daha önce gösterilip gösterilmediğini kontrol et
    String? subscriptionShown =
        await SecureStorageService().get(key: 'subscription_shown');

    // Kullanıcı premium değilse ve subscription daha önce gösterilmemişse göster
    if (!purchasesProvider.isPremium() &&
        subscriptionShown != 'true' &&
        !_hasShownSubscription) {
      _hasShownSubscription = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => const SubscriptionsScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        border: null,
        iconSize: 24,
        onTap: (index) {},
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.square_stack_3d_up),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.photo_fill_on_rectangle_fill),
            label: 'Cleaner',
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            List<Widget> pages = [
              const HomeScreen(),
              const HomeScreen(),
              const SettingsScreen(),
            ];

            return pages[index];
          },
        );
      },
    );
  }
}
