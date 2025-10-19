import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';

/// Global uygulama lifecycle yöneticisi
/// Permission değişikliklerini dinler ve callback'leri tetikler
class AppLifecycleManager with WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  bool _hasPhotoAccess = false;
  final List<VoidCallback> _permissionGrantedCallbacks = [];

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionGrantedCallbacks.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kullanıcı uygulamaya geri döndüğünde permission'ı tekrar kontrol et
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    final bool hadAccess = _hasPhotoAccess;
    final bool hasAccessNow = permission.isAuth || permission.hasAccess;

    _hasPhotoAccess = hasAccessNow;

    // Permission yeni verilmişse callback'leri tetikle
    if (!hadAccess && hasAccessNow) {
      for (var callback in _permissionGrantedCallbacks) {
        callback();
      }
    }
  }

  /// Permission verildiğinde çağrılacak callback ekle
  void addPermissionGrantedCallback(VoidCallback callback) {
    if (!_permissionGrantedCallbacks.contains(callback)) {
      _permissionGrantedCallbacks.add(callback);
    }
  }

  /// Callback'i kaldır
  void removePermissionGrantedCallback(VoidCallback callback) {
    _permissionGrantedCallbacks.remove(callback);
  }

  /// Mevcut permission durumunu döndür
  bool get hasPhotoAccess => _hasPhotoAccess;
}
