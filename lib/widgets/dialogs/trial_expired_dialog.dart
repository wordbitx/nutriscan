import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:nutriscan/config/app_colors.dart';
import 'package:nutriscan/config/app_localizations.dart';
import 'package:nutriscan/providers/theme/language_provider.dart';
import 'package:nutriscan/providers/theme/theme_provider.dart';
import 'package:nutriscan/screens/subscription/subscription_screen.dart';
import 'package:provider/provider.dart';

class TrialExpiredDialog extends StatelessWidget {
  const TrialExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final currentLanguage = languageProvider.currentLanguage;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.15),
                  spreadRadius: 1,
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon with primary background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    IconlyBold.time_square,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  AppLocalizations.getString(
                    'trial_expired_title',
                    currentLanguage,
                  ),
                  style: themeProvider.getFontForCurrentLanguage(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  AppLocalizations.getString(
                    'trial_expired_message',
                    currentLanguage,
                  ),
                  style: themeProvider.getFontForCurrentLanguage(
                    fontSize: 15,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.grey800.withValues(alpha: 0.3)
                        : AppColors.grey200.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: IconlyBold.scan,
                        text: AppLocalizations.getString(
                          'trial_feature_unlimited_scans',
                          currentLanguage,
                        ),
                        themeProvider: themeProvider,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: IconlyBold.upload,
                        text: AppLocalizations.getString(
                          'trial_feature_cloud_backup',
                          currentLanguage,
                        ),
                        themeProvider: themeProvider,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: IconlyBold.chart,
                        text: AppLocalizations.getString(
                          'trial_feature_advanced_analytics',
                          currentLanguage,
                        ),
                        themeProvider: themeProvider,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        icon: IconlyBold.shield_done,
                        text: AppLocalizations.getString(
                          'trial_feature_ad_free',
                          currentLanguage,
                        ),
                        themeProvider: themeProvider,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Column(
                  children: [
                    // Subscribe Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyBold.star,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.getString(
                                'subscribe_now_button',
                                currentLanguage,
                              ),
                              style: themeProvider.getFontForCurrentLanguage(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Maybe Later Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.getString(
                            'maybe_later_button',
                            currentLanguage,
                          ),
                          style: themeProvider.getFontForCurrentLanguage(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required ThemeProvider themeProvider,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: themeProvider.getFontForCurrentLanguage(
              fontSize: 14,
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
