import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'NutriScan';
  static const String appVersion = '1.0.0';

  static const String buildNumber = '1';

  // Stripe Configuration from .env
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static const double monthlyPrice = 0.0;
  static const double yearlyPrice = 0.0;
}
