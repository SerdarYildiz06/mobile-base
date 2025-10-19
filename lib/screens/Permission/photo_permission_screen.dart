import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:cleaner_app/widgets/my_button.dart';

class PhotoPermissionScreen extends StatelessWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback? onSkip;

  const PhotoPermissionScreen({
    super.key,
    required this.onPermissionGranted,
    this.onSkip,
  });

  Future<void> _requestPermission(BuildContext context) async {
    // iOS'un native photo library permission popup'ını açar
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      // İzin verildi, callback'i çağır
      onPermissionGranted();
    } else if (permission.hasAccess) {
      // Limited access verildi, yine de devam et
      onPermissionGranted();
    } else {
      // İzin reddedildi veya kısıtlı
      if (context.mounted) {
        _showPermissionDeniedDialog(context);
      }
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Photo Access Required'),
        content: const Text(
          'This app needs access to your photo library to find and clean similar photos. Please enable photo access in Settings.',
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Başlık
                const Text(
                  'Access Your Photo Library',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Alt başlık
                Text(
                  'Photo library access is required to fetch photos and find similar photos.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.5),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // İkon
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Lottie.asset(
                    'lib/assets/animation/permisson-1.json',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 40),

                // Özellikler listesi
                _buildFeatureItem(
                  icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                  title: 'Find Similar Photos',
                  description: 'Automatically detect and group similar photos',
                ),

                const SizedBox(height: 20),

                _buildFeatureItem(
                  icon: CupertinoIcons.trash,
                  title: 'Clean Storage',
                  description: 'Free up space by removing duplicates',
                ),

                const SizedBox(height: 20),

                _buildFeatureItem(
                  icon: CupertinoIcons.lock_shield,
                  title: 'Privacy Protected',
                  description: 'All processing happens on your device',
                ),

                const SizedBox(height: 40),

                // Footer with button
                _buildFooter(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          MyButton(
            text: 'Allow Access',
            onTap: () => _requestPermission(context),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: onSkip,
            child: Text(
              'Skip for Now',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: CupertinoColors.systemGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
