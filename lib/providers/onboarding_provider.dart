import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cleaner_app/services/secure_storage_service.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  final int _autoAdvanceDuration = 5; // saniye
  Function? _onCompleteCallback;
  Function? _onNextPageCallback;

  int get currentPage => _currentPage;

  void startAutoAdvance(Function onComplete, {Function? onNextPage}) {
    _onCompleteCallback = onComplete;
    _onNextPageCallback = onNextPage;
    _cancelAutoAdvance();
    _autoAdvanceTimer = Timer(Duration(seconds: _autoAdvanceDuration), () {
      if (_currentPage < 2) {
        nextPage();
        // Bir sonraki sayfa için timer'ı yeniden başlat
        if (_onNextPageCallback != null) {
          _onNextPageCallback!();
        }
        startAutoAdvance(onComplete, onNextPage: onNextPage);
      } else {
        if (_onCompleteCallback != null) {
          _onCompleteCallback!();
        }
      }
    });
  }

  void _cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  void nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await SecureStorageService()
        .set(key: 'onboarding_completed', value: 'true');
    _cancelAutoAdvance();
  }

  Future<bool> isOnboardingCompleted() async {
    String? completed =
        await SecureStorageService().get(key: 'onboarding_completed');
    return completed == 'true';
  }

  void reset() {
    _currentPage = 0;
    _cancelAutoAdvance();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelAutoAdvance();
    super.dispose();
  }
}
