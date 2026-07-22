import 'package:flutter/material.dart';
import 'package:nutriscan/config/app_colors.dart';
import 'package:nutriscan/config/app_localizations.dart';
import 'package:nutriscan/providers/ads/admob_provider.dart';
import 'package:nutriscan/providers/auth/cloud_backup_provider.dart';
import 'package:nutriscan/providers/payment/subscription_provider.dart';
import 'package:nutriscan/providers/theme/language_provider.dart';
import 'package:nutriscan/providers/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class RewardedAdButton extends StatelessWidget {
  final Function(int amount, String type) onRewardEarned;
  final String? customText;
  final IconData? customIcon;
  final Color? customColor;

  const RewardedAdButton({
    super.key,
    required this.onRewardEarned,
    this.customText,
    this.customIcon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer5<
      ThemeProvider,
      LanguageProvider,
      AdMobProvider,
      CloudBackupProvider,
      SubscriptionProvider
    >(
      builder:
          (
            context,
            themeProvider,
            languageProvider,
            adMobProvider,
            cloudBackupProvider,
            subscriptionProvider,
            child,
          ) {
            final currentLanguage = languageProvider.currentLanguage;
            final isLoggedIn = cloudBackupProvider.isSignedIn;
            final isPremium = subscriptionProvider.hasPremiumFeatures;

            // Hide button if premium user
            if (isPremium) {
              return const SizedBox.shrink();
            }

            // Hide button if not logged in
            if (!isLoggedIn) {
              return const SizedBox.shrink();
            }

            final canShow = adMobProvider.canShowRewardedAd(isLoggedIn);
            final remaining = adMobProvider.getRemainingRewardedAdsToday();
            final timeUntilNext = adMobProvider.getTimeUntilNextRewardedAd();

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    customColor ?? AppColors.primary,
                    (customColor ?? AppColors.primary).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (customColor ?? AppColors.primary).withValues(
                      alpha: 0.3,
                    ),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canShow
                      ? () => _showRewardedAd(
                          context,
                          adMobProvider,
                          isLoggedIn,
                          currentLanguage,
                          themeProvider,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            customIcon ?? Icons.play_circle_filled,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customText ??
                                    AppLocalizations.getString(
                                      'watch_ad_for_rewards',
                                      currentLanguage,
                                    ),
                                style: themeProvider.getFontForCurrentLanguage(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (timeUntilNext != null)
                                Text(
                                  _formatTime(timeUntilNext, currentLanguage),
                                  style: themeProvider
                                      .getFontForCurrentLanguage(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                )
                              else
                                Text(
                                  '${AppLocalizations.getString('remaining_today', currentLanguage)}: $remaining',
                                  style: themeProvider
                                      .getFontForCurrentLanguage(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                ),
                            ],
                          ),
                        ),

                        // Arrow or loading indicator
                        if (adMobProvider.isLoadingRewardedAd)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withValues(
                              alpha: canShow ? 1.0 : 0.5,
                            ),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }

  String _formatTime(Duration duration, String languageCode) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${AppLocalizations.getString('available_in', languageCode)}: ${minutes}m ${seconds}s';
    } else {
      return '${AppLocalizations.getString('available_in', languageCode)}: ${seconds}s';
    }
  }

  Future<void> _showRewardedAd(
    BuildContext context,
    AdMobProvider adMobProvider,
    bool isLoggedIn,
    String currentLanguage,
    ThemeProvider themeProvider,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.getString('loading_ad', currentLanguage),
                style: themeProvider.getFontForCurrentLanguage(
                  fontSize: 16,
                  color: themeProvider.isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await adMobProvider.showRewardedAd(
        isLoggedIn: isLoggedIn,
        onRewardEarned: (amount, type) {
          if (!context.mounted) return;
          Navigator.of(context).pop(); // Close loading dialog
          onRewardEarned(amount, type);
          if (!context.mounted) return;
          _showRewardSuccessDialog(
            context,
            amount,
            type,
            currentLanguage,
            themeProvider,
          );
        },
      );

      if (!success) {
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, currentLanguage, themeProvider);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog(context, currentLanguage, themeProvider);
    }
  }

  void _showRewardSuccessDialog(
    BuildContext context,
    int amount,
    String type,
    String currentLanguage,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.getString('reward_earned', currentLanguage),
                style: themeProvider.getFontForCurrentLanguage(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.getString(
                  'reward_earned_description',
                  currentLanguage,
                ),
                style: themeProvider.getFontForCurrentLanguage(
                  fontSize: 15,
                  color: themeProvider.isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.getString('ok', currentLanguage),
                    style: themeProvider.getFontForCurrentLanguage(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String currentLanguage,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.getString('ad_not_available', currentLanguage),
                style: themeProvider.getFontForCurrentLanguage(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.getString(
                  'ad_not_available_description',
                  currentLanguage,
                ),
                style: themeProvider.getFontForCurrentLanguage(
                  fontSize: 15,
                  color: themeProvider.isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.getString('ok', currentLanguage),
                    style: themeProvider.getFontForCurrentLanguage(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
