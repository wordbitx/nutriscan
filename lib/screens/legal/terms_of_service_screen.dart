import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:nutriscan/config/app_colors.dart';
import 'package:nutriscan/providers/theme/theme_provider.dart';
import 'package:nutriscan/widgets/policy/policy_header.dart';
import 'package:nutriscan/widgets/policy/policy_section.dart';
import 'package:provider/provider.dart';


class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
              'Terms of Service',
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
                  title: 'Terms of Service',
                  subtitle: 'Last updated: Recently',
                  icon: Icons.description,
                ),
                const SizedBox(height: 24),

                // Content Sections
                PolicySection(
                  title: 'Acceptance of Terms',
                  content:
                      'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
                  icon: Icons.check_circle,
                ),

                PolicySection(
                  title: 'Use License',
                  content:
                      'Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.',
                  icon: Icons.verified_user,
                ),

                PolicySection(
                  title: 'Disclaimer',
                  content:
                      'The materials on the app are provided on an \'as is\' basis. We make no warranties, expressed or implied, and hereby disclaim all other warranties.',
                  icon: Icons.warning,
                ),

                PolicySection(
                  title: 'Limitations',
                  content:
                      'In no event shall we or our suppliers be liable for any damages arising out of the use or inability to use the materials on the app.',
                  icon: Icons.block,
                ),

                PolicySection(
                  title: 'Accuracy of Materials',
                  content:
                      'The materials appearing on the app could include technical, typographical, or photographic errors. We do not warrant that any materials are accurate, complete, or current.',
                  icon: Icons.info,
                ),

                PolicySection(
                  title: 'Links',
                  content:
                      'We have not reviewed all of the sites linked to the app and are not responsible for the contents of any such linked site.',
                  icon: Icons.link,
                ),

                PolicySection(
                  title: 'Modifications',
                  content:
                      'We may revise these terms of service at any time without notice. By using this app, you are agreeing to be bound by the current version of these terms.',
                  icon: Icons.edit,
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
