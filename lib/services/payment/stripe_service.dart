import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:nutriscan/config/app_config.dart';

class StripeService {
  StripeService._() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  static final StripeService instance = StripeService._();
  late final Dio _dio;

  Future<bool> makePayment(double totalPrice) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(
        totalPrice,
        "usd",
      );

      if (paymentIntentClientSecret == null) {
        return false;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: AppConfig.appName,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final response = await _dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: {
          "amount": _calculateAmount(amount),
          "currency": currency,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${AppConfig.stripeSecretKey}",
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data["client_secret"];
      }
    } catch (e) {
      // Payment intent creation error
    }
    return null;
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }
}
