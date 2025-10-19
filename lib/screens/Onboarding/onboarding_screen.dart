import 'package:cleaner_app/screens/Onboarding/storage_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cleaner_app/providers/onboarding_provider.dart';
import 'package:cleaner_app/screens/Subscription/subscription_screen.dart';
import 'package:cleaner_app/widgets/my_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoAdvance();
    });
  }

  void _startAutoAdvance() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    _progressController.reset();
    _progressController.forward();

    provider.startAutoAdvance(
      () {
        _completeOnboarding();
      },
      onNextPage: () {
        // Sayfa değiştiğinde animasyonu resetle
        if (mounted) {
          _progressController.reset();
          _progressController.forward();
        }
      },
    );
  }

  void _onPageChanged(int page) {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.setPage(page);
    _progressController.reset();
    _startAutoAdvance();
  }

  void _completeOnboarding() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.completeOnboarding();
    if (mounted) {
      // Subscription ekranına yönlendir
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const SubscriptionsScreen()),
      );
    }
  }

  void _onContinue() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    _progressController.stop();

    if (provider.currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Progress indicator
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            double progress = 0.0;

                            if (index < provider.currentPage) {
                              // Önceki sayfalar - tamamen dolu
                              progress = 1.0;
                            } else if (index == provider.currentPage) {
                              // Aktif sayfa - animasyonlu dolma
                              progress = _progressAnimation.value;
                            } else {
                              // Sonraki sayfalar - boş
                              progress = 0.0;
                            }

                            return Container(
                              height: 4,
                              margin: EdgeInsets.only(
                                right: index < 2 ? 8 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGreen,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      const OnboardingPage(
                        title: 'Delete Duplicate Photos',
                        description:
                            'Eliminate duplicate photos instantly and reclaim your storage!',
                        imagePath: 'lib/assets/images/ss-1.png',
                      ),
                      const OnboardingPage(
                        title: 'Organize Your Gallery',
                        description:
                            'Keep your photos organized and easy to find with smart categorization.',
                        imagePath: 'lib/assets/images/ss-2.png',
                      ),
                      StorageOnboardingPage(
                        title: 'Space',
                        description:
                            'Delete unwanted photos and videos to valuable storage space.',
                      ),
                    ],
                  ),
                ),

                // Continue button & Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      MyButton(
                        text: 'Continue',
                        onTap: _onContinue,
                      ),
                      _buildFooterLinks(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    final linkStyle =
        TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // CupertinoButton(
        //     onPressed: () => launchUrlString(
        //         "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
        //     child: Text('Terms', style: linkStyle)),
        // CupertinoButton(
        //     onPressed: () => launchUrlString(
        //         "https://www.freeprivacypolicy.com/live/1d1202d8-7c4f-4c68-8a99-787465bec8ca"),
        //     child: Text('Privacy', style: linkStyle)),
        // CupertinoButton(
        //     onPressed: () => launchUrlString(
        //         "https://www.freeprivacypolicy.com/live/1d1202d8-7c4f-4c68-8a99-787465bec8ca"),
        //     child: Text('Restore', style: linkStyle)),
      ],
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Image with beautiful shadow and rounded corners
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.photo_library,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
