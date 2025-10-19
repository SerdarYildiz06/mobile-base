import 'package:cleaner_app/screens/Permission/photo_permission_screen.dart';
import 'package:cleaner_app/screens/BottomNavBar/bottom_nav_bar.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'package:cleaner_app/providers/purchases_provider.dart';
import 'package:cleaner_app/widgets/blurred_progress_indicator.dart';
import 'package:cleaner_app/widgets/my_button.dart';
import 'package:cleaner_app/services/secure_storage_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  StoreProduct? selectedProduct;

  double _totalGb = 0;
  double _freeGb = 0;
  double _usedGb = 0;
  String _deviceName = 'iPhone';

  bool showClose = false;

  late AnimationController _animationController;
  late Animation<double> _photosAnimation;
  late Animation<double> _appsAnimation;

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceName = 'iPhone';

      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        // iPhone model adını al
        deviceName = iosInfo.name; // Örn: "Ahmet'in iPhone'u"
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = androidInfo.model;
      }

      setState(() {
        _deviceName = deviceName;
      });
    } catch (e) {
      print('Cihaz bilgisi alınamadı: $e');
    }
  }

  Future<void> _loadStorage() async {
    final free = await DiskSpace.getFreeDiskSpace; // MB
    final total = await DiskSpace.getTotalDiskSpace; // MB
    setState(() {
      // MB'dan GB'a çevir (1024 MB = 1 GB)
      _totalGb = (total ?? 0).toDouble() / 1024;
      _freeGb = (free ?? 0).toDouble() / 1024;
      _usedGb = _totalGb - _freeGb;
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _photosAnimation = Tween<double>(begin: 0.0, end: 0.75).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _appsAnimation = Tween<double>(begin: 0.0, end: 0.20).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          showClose = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _animationController.forward();
        }
      });
      _setSelectedProduct();
      _loadDeviceInfo();
      _loadStorage();
    });
  }

  Future<void> _setSelectedProduct() async {
    final purchasesProvider =
        Provider.of<PurchasesProvider>(context, listen: false);
    if (purchasesProvider.products.isEmpty) {
      await purchasesProvider.getProducts();
    }
    final products = purchasesProvider.products
      ..sort((a, b) => a.price.compareTo(b.price));
    selectedProduct = products.first;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesProvider = Provider.of<PurchasesProvider>(context);
    final products = purchasesProvider.products
      ..sort((a, b) => a.price.compareTo(b.price));

    return PopScope(
      canPop: false,
      child: BlurredProgressIndicator(
        show: purchasesProvider.processing,
        child: Container(
          color: CupertinoColors.white,
          child: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                color: CupertinoColors.white,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                _buildIntroText(),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(14.0),
                                              child: Image.asset(
                                                  "lib/assets/images/photos.png",
                                                  height: 60,
                                                  width: 60),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    CupertinoColors.systemRed,
                                                child: Text(
                                                  '652',
                                                  style: TextStyle(
                                                      color: CupertinoColors
                                                          .white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('Photos'),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(14.0),
                                              child: Image.asset(
                                                  "lib/assets/images/icloud.png",
                                                  height: 60,
                                                  width: 60),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    CupertinoColors.systemRed,
                                                child: Text(
                                                  '324',
                                                  style: TextStyle(
                                                      color: CupertinoColors
                                                          .white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('iCloud'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildStorageAnimation(),
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 5),
                                    child: Center(
                                      child: Text(
                                        'AI Powered Smart Cleaning, No Ads, Compress Photos & Videos, Secret Space and more!',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildSubscriptionPlans(
                                    products, purchasesProvider),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        _buildFooter(purchasesProvider),
                        const SizedBox(height: 24),
                      ],
                    ),
                    if (showClose)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CupertinoButton(
                          onPressed: () async {
                            // Subscription ekranını gösterildi olarak kaydet
                            await SecureStorageService()
                                .set(key: 'subscription_shown', value: 'true');

                            // Premium kontrolü yap
                            if (!purchasesProvider.isPremium()) {
                              // Premium değilse soft reminder göster
                              final shouldContinue =
                                  await showCupertinoDialog<bool>(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title:
                                      const Text('Continue with Free Version?'),
                                  content: const Text(
                                    'Without premium, you\'ll have limited features:\n\n'
                                    '• Only 3 swipes per session\n'
                                    '• Ads will be shown\n'
                                    '• No AI-powered cleaning\n'
                                    '• No photo compression\n\n'
                                    'Are you sure you want to continue?',
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      child: const Text('Continue with Free'),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: const Text('Get Premium'),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldContinue != true) return;
                            }

                            if (!mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => PhotoPermissionScreen(
                                  onPermissionGranted: () {
                                    // İzin verildikten sonra asset'leri yükle ve ana ekrana git

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              const BottomNavBar()),
                                      (route) => false,
                                    );
                                  },
                                  onSkip: () {
                                    // Kullanıcı izin vermek istemezse de ana ekrana git
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              const BottomNavBar()),
                                      (route) => false,
                                    );
                                  },
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Icon(CupertinoIcons.xmark,
                              color: CupertinoColors.systemGrey3, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Clean your Storage',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get rid of what you don’t need',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageAnimation() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with device name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.device_phone_portrait,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _deviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Storage usage info
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final displayUsed = _totalGb > 0
                  ? _usedGb
                  : ((_photosAnimation.value + _appsAnimation.value) * 128);
              final displayTotal = _totalGb > 0 ? _totalGb : 128.0;

              return Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${displayUsed.toStringAsFixed(1)} GB ',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                        TextSpan(
                          text: 'used of ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${displayTotal.toStringAsFixed(0)} GB storage ${((displayUsed / displayTotal) * 100).toStringAsFixed(0)}% full',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Storage Bar
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade800.withOpacity(0.5),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      // Photos
                      if (_photosAnimation.value > 0)
                        Expanded(
                          flex: (_photosAnimation.value * 1000).toInt(),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                              ),
                            ),
                          ),
                        ),
                      // Apps
                      if (_appsAnimation.value > 0)
                        Expanded(
                          flex: (_appsAnimation.value * 1000).toInt(),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD93D), Color(0xFFFFE66D)],
                              ),
                            ),
                          ),
                        ),
                      // Empty space
                      Expanded(
                        flex: ((1.0 -
                                    _photosAnimation.value -
                                    _appsAnimation.value) *
                                1000)
                            .toInt(),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem(
                color: const Color(0xFFFF6B6B),
                label: 'Photos',
              ),
              _buildLegendItem(
                color: const Color(0xFFFFD93D),
                label: 'Apps',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(
      List<StoreProduct> products, PurchasesProvider purchasesProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: products.map((product) {
          double discount = 0;
          if (product.identifier.contains('month')) {
            // discount in 100
            StoreProduct weekProduct = products
                .firstWhere((element) => element.identifier.contains('week'));
            discount = (weekProduct.price / product.price) * 100;
          }
          return _buildSubscriptionOption(
            product: product,
            isSelected: selectedProduct?.identifier == product.identifier,
            isPopular: product.identifier.contains('week'),
            discount: discount,
            onTap: () {
              setState(() => selectedProduct = product);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionOption(
      {required StoreProduct product,
      required bool isSelected,
      bool isPopular = false,
      required VoidCallback onTap,
      double discount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemGreen
                : Colors.black.withOpacity(0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? CupertinoColors.systemGreen.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.title.split(' ').first} Subscription',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.priceString} / ${product.identifier.contains('month') ? 'month' : 'week'}',
                        style: TextStyle(color: Colors.black.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                if (discount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SAVE ${discount.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                if (isSelected) ...[
                  const Icon(CupertinoIcons.checkmark_circle_fill, size: 24),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(PurchasesProvider purchasesProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: MyButton(
            text: 'Get Started',
            onTap: () => purchasesProvider.purchasePremium(selectedProduct!),
            loading: purchasesProvider.processing,
          ),
        ),
        _buildFooterLinks(),
      ],
    );
  }

  Widget _buildFooterLinks() {
    final linkStyle =
        TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
            onPressed: () => launchUrlString(
                "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
            child: Text('Terms', style: linkStyle)),
        CupertinoButton(
            onPressed: () => launchUrlString(
                "https://www.freeprivacypolicy.com/live/1d1202d8-7c4f-4c68-8a99-787465bec8ca"),
            child: Text('Privacy', style: linkStyle)),
        CupertinoButton(
          onPressed: () async {
            try {
              PurchasesProvider purchasesProvider =
                  Provider.of<PurchasesProvider>(context, listen: false);
              purchasesProvider.processing = true;
              purchasesProvider.setState();

              CustomerInfo restoredInfo = await Purchases.restorePurchases();
              await purchasesProvider.getCustomerInfo();

              purchasesProvider.processing = false;
              purchasesProvider.setState();

              if (!mounted) return;

              if (restoredInfo.activeSubscriptions.isNotEmpty) {
                // Başarılı restore - PhotoPermissionScreen'e git
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PhotoPermissionScreen(
                      onPermissionGranted: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const BottomNavBar()),
                          (route) => false,
                        );
                      },
                      onSkip: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const BottomNavBar()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  (route) => false,
                );
              } else {
                // Restore edilecek abonelik bulunamadı
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('No Purchases Found'),
                    content:
                        const Text('No active subscriptions found to restore.'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              PurchasesProvider purchasesProvider =
                  Provider.of<PurchasesProvider>(context, listen: false);
              purchasesProvider.processing = false;
              purchasesProvider.setState();

              if (!mounted) return;

              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Error'),
                  content: Text('Failed to restore purchases: ${e.toString()}'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text('Restore', style: linkStyle),
        ),
      ],
    );
  }
}
