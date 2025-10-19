import 'package:flutter/material.dart';

class StorageOnboardingPage extends StatefulWidget {
  final String title;
  final String description;

  const StorageOnboardingPage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<StorageOnboardingPage> createState() => _StorageOnboardingPageState();
}

class _StorageOnboardingPageState extends State<StorageOnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _photosAnimation;
  late Animation<double> _appsAnimation;
  late Animation<double> _iosAnimation;
  late Animation<double> _systemAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Her segment için farklı animasyon tanımları
    _photosAnimation = Tween<double>(begin: 0.0, end: 0.65).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _appsAnimation = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _iosAnimation = Tween<double>(begin: 0.0, end: 0.10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _systemAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Animasyonu başlat
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Storage Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Header
                const Text(
                  'iPhone',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final totalUsed = (_photosAnimation.value +
                            _appsAnimation.value +
                            _iosAnimation.value +
                            _systemAnimation.value) *
                        128;
                    return Text(
                      '${totalUsed.toStringAsFixed(0)} of 128 GB used',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Storage Bar
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade800,
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
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            // Apps
                            if (_appsAnimation.value > 0)
                              Expanded(
                                flex: (_appsAnimation.value * 1000).toInt(),
                                child: Container(
                                  color: const Color(0xFFFFD93D),
                                ),
                              ),
                            // iOS
                            if (_iosAnimation.value > 0)
                              Expanded(
                                flex: (_iosAnimation.value * 1000).toInt(),
                                child: Container(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            // System Data
                            if (_systemAnimation.value > 0)
                              Expanded(
                                flex: (_systemAnimation.value * 1000).toInt(),
                                child: Container(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            // Empty space
                            Expanded(
                              flex: ((1.0 -
                                          _photosAnimation.value -
                                          _appsAnimation.value -
                                          _iosAnimation.value -
                                          _systemAnimation.value) *
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
                const SizedBox(height: 32),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem(
                      color: const Color(0xFFFF6B6B),
                      label: 'Photos',
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFFFD93D),
                      label: 'Applications',
                    ),
                    _buildLegendItem(
                      color: Colors.grey.shade600,
                      label: 'iOS',
                    ),
                    _buildLegendItem(
                      color: Colors.grey.shade700,
                      label: 'System Data',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
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

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
