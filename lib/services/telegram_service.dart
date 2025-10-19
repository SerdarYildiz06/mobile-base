import 'package:cleaner_app/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:ip_country_lookup/ip_country_lookup.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TelegramService {
  final String botToken = '';
  final String chatId = ''; // Grubun chat_id

  Dio _getDio() {
    final dio = Dio();
    dio.options.baseUrl = 'https://api.telegram.org/';
    return dio;
  }

  Future<void> registerLog() async {
    bool sent =
        (await SecureStorageService().get(key: 'telegram_log')) == 'true';
    if (sent) return;

    await SecureStorageService().set(key: 'telegram_log', value: 'true');

    final dio = _getDio();
    IpCountryData countryData = await IpCountryLookup().getIpLocationData();

    String text =
        '*New user registered!*\nApp: *Cleaner 🧹*\nCountry: *${countryData.country_name}*\nIP: *${countryData.ip}*';

    await dio.post(
      'bot$botToken/sendMessage',
      queryParameters: {
        'chat_id': chatId,
        'parse_mode': 'markdown',
        'text': text,
      },
    );
  }

  Future<void> premiumLog({
    required StoreProduct product,
  }) async {
    final dio = _getDio();
    IpCountryData countryData = await IpCountryLookup().getIpLocationData();

    String text =
        '*New subscriber!*\nApp: *Cleaner 🧹*\nPlan: ${product.priceString} ${product.title}\nCountry: *${countryData.country_name}*\nIP: *${countryData.ip}*';

    await dio.post(
      'bot$botToken/sendMessage',
      queryParameters: {
        'chat_id': chatId,
        'parse_mode': 'markdown',
        'text': text,
      },
    );
  }

  Future<void> contactLog({
    required String name,
    required String contact,
    required String message,
  }) async {
    final dio = _getDio();
    IpCountryData countryData = await IpCountryLookup().getIpLocationData();

    String text =
        '*New Feedback!*\nApp: *Cleaner 🧹*\nName: $name\nContact: *$contact*\nMessage: *$message*\nCountry: ${countryData.country_name}';

    await dio.post(
      'bot$botToken/sendMessage',
      queryParameters: {
        'chat_id': chatId,
        'parse_mode': 'markdown',
        'text': text,
      },
    );
  }
}
