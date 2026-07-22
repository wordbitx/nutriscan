import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:nutriscan/config/app_colors.dart';
import 'package:nutriscan/providers/theme/theme_provider.dart';
import 'package:nutriscan/widgets/policy/policy_header.dart';
import 'package:nutriscan/widgets/policy/policy_section.dart';
import 'package:provider/provider.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(IconlyLight.arrow_left, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                PolicyHeader(
                  title: 'Privacy Policy',
                  subtitle: 'Last updated: Recently',
                  icon: Icons.privacy_tip,
                ),
                const SizedBox(height: 24),

                // Content Sections
                PolicySection(
                  title: 'Information We Collect',
                  content:
                      'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support. This policy was last updated recently.',
                  icon: Icons.collections,
                ),

                PolicySection(
                  title: 'How We Use Your Information',
                  content:
                      'We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to develop new features. This policy is effective as of recently.',
                  icon: Icons.analytics,
                ),

                PolicySection(
                  title: 'Information Sharing',
                  content:
                      'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy. Last revised: recently.',
                  icon: Icons.share,
                ),

                PolicySection(
                  title: 'Data Security',
                  content:
                      'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Security protocols updated recently.',
                  icon: Icons.security,
                ),

                PolicySection(
                  title: 'Your Rights',
                  content:
                      'You have the right to access, update, or delete your personal information. You can also opt out of certain data collection and use. Rights effective recently.',
                  icon: Icons.person,
                ),

                PolicySection(
                  title: 'Contact Us',
                  content:
                      'If you have any questions about this Privacy Policy, please contact us at privacy@calorietracker.com. This policy was last updated recently.',
                  icon: Icons.contact_support,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
