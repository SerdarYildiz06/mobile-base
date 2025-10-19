import 'package:cleaner_app/services/telegram_service.dart';
import 'package:cleaner_app/utils/snackbar.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesProvider extends ChangeNotifier {
  Offerings? offerings;
  CustomerInfo? customerInfo;
  List<StoreProduct> products = [];
  bool processing = false;

  bool isPremium() {
    if (customerInfo == null) {
      return false;
    }
    if (customerInfo!.activeSubscriptions.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> initPurchases() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration purchasesConfiguration = PurchasesConfiguration(
      'appl_DLcPkWeszbLBLTQAXgHTXiEGVfK',
    );
    await Purchases.configure(purchasesConfiguration);
    debugPrint('Purchases setup done');
    getData();
    await getCustomerInfo();
  }

  Future<void> getData() async {
    await Future.wait([getOfferings(), getProducts()]);
  }

  Future<void> getOfferings() async {
    offerings = await Purchases.getOfferings();
    // debugPrint('offerings: $offerings');
    notifyListeners();
  }

  Future<void> getCustomerInfo() async {
    customerInfo = await Purchases.getCustomerInfo();
    notifyListeners();
  }

  Future<void> getProducts() async {
    List subs = [];
    subs = await Purchases.getProducts([
      "cleaner_weekly_premium",
      "cleaner_annual_premium",
    ], productCategory: ProductCategory.subscription);

    products = [];

    for (var element in subs) {
      products.add(element);
    }
    print(products.length);

    notifyListeners();
  }

  Future<void> purchasePremium(StoreProduct storeProduct) async {
    try {
      customerInfo = await Purchases.purchaseStoreProduct(storeProduct);
      TelegramService().premiumLog(product: storeProduct);

      processing = false;
      notifyListeners();

      // İzin kontrolü yap

      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        MySnackbar.show(message: 'Premium purchased successfully.');
      });
      getCustomerInfo();
    } catch (e) {
      processing = false;
      notifyListeners();
    }
  }

  void setState() {
    notifyListeners();
  }
}
