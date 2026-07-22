import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nutriscan/config/app_config.dart';
import 'package:nutriscan/config/firebase_config.dart';
import 'package:nutriscan/providers/auth/cloud_backup_provider.dart';
import 'package:nutriscan/providers/notifications/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProvider with ChangeNotifier {
  NotificationProvider? _notificationProvider;
  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _subscriptionType;
  DateTime? _subscriptionExpiry;
  DateTime? _trialStartDate;
  bool _isInTrial = false;
  bool _hasShownTrialExpiredDialog = false;
  String? _error;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CloudBackupProvider? _backupProvider;

  // Getters
  bool get isSubscribed => _isSubscribed;

  bool get isLoading => _isLoading;

  String? get subscriptionType => _subscriptionType;

  DateTime? get subscriptionExpiry => _subscriptionExpiry;

  DateTime? get trialStartDate => _trialStartDate;

  bool get isInTrial => _isInTrial;

  String? get error => _error;

  // Check if subscription is active
  bool get isSubscriptionActive {
    if (!_isSubscribed || _subscriptionExpiry == null) return false;
    return DateTime.now().isBefore(_subscriptionExpiry!);
  }

  // Check if trial is active
  bool get isTrialActive {
    if (!_isInTrial || _trialStartDate == null) return false;
    final trialEnd = _trialStartDate!.add(const Duration(days: 7));
    return DateTime.now().isBefore(trialEnd);
  }

  // Check if user has premium features (either subscribed or in trial)
  bool get hasPremiumFeatures => isSubscriptionActive || isTrialActive;

  // Check if trial has expired (was in trial but now expired)
  bool get isTrialExpired {
    if (!_isInTrial || _trialStartDate == null) return false;
    final trialEnd = _trialStartDate!.add(const Duration(days: 7));
    return DateTime.now().isAfter(trialEnd);
  }

  // Check if user has used trial
  bool get hasUsedFreeTrial => _isInTrial || _trialStartDate != null;

  SubscriptionProvider() {
    _loadSubscriptionStatus();
  }

  // Set notification provider reference
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  // Set cloud backup provider reference and sync
  void setAuth(CloudBackupProvider provider) {
    _backupProvider = provider;
    if (_backupProvider!.isSignedIn) {
      _syncWithFirestore();
    }
  }

  // Sync subscription status with Firestore
  Future<void> _syncWithFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    try {
      final doc = await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey(FirebaseConfig.subscriptionField)) {
          final sub = data[FirebaseConfig.subscriptionField] as Map<String, dynamic>;
          
          _isSubscribed = sub[FirebaseConfig.isSubscribedField] ?? false;
          _subscriptionType = sub[FirebaseConfig.subscriptionTypeField];
          _isInTrial = sub[FirebaseConfig.isInTrialField] ?? false;
          
          if (sub[FirebaseConfig.subscriptionExpiryField] != null) {
            _subscriptionExpiry = (sub[FirebaseConfig.subscriptionExpiryField] as Timestamp).toDate();
          }
          
          if (sub[FirebaseConfig.trialStartDateField] != null) {
            _trialStartDate = (sub[FirebaseConfig.trialStartDateField] as Timestamp).toDate();
          }

          // Save locally as well
          await _saveSubscriptionStatus(syncToFirestore: false);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Firestore Sync Error: $e');
    }
  }

  // Update subscription in Firestore
  Future<void> _updateFirestoreSubscription() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).set({
        'email': user?.email,
        'displayName': user?.displayName,
        FirebaseConfig.subscriptionField: {
          FirebaseConfig.isSubscribedField: _isSubscribed,
          FirebaseConfig.subscriptionTypeField: _subscriptionType,
          FirebaseConfig.isInTrialField: _isInTrial,
          FirebaseConfig.subscriptionExpiryField: _subscriptionExpiry != null ? Timestamp.fromDate(_subscriptionExpiry!) : null,
          FirebaseConfig.trialStartDateField: _trialStartDate != null ? Timestamp.fromDate(_trialStartDate!) : null,
          FirebaseConfig.updatedAtField: FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore Update Error: $e');
    }
  }

  // Restore subscription manually
  Future<bool> restoreSubscription() async {
    if (_backupProvider == null || !_backupProvider!.isSignedIn) {
      _error = 'Please sign in to restore subscription';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _syncWithFirestore();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to restore: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load subscription status from local storage
  Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSubscribed = prefs.getBool('is_subscribed') ?? false;
      _subscriptionType = prefs.getString('subscription_type');
      _isInTrial = prefs.getBool('is_in_trial') ?? false;
      _hasShownTrialExpiredDialog =
          prefs.getBool('has_shown_trial_expired_dialog') ?? false;

      final expiryString = prefs.getString('subscription_expiry');
      if (expiryString != null) {
        _subscriptionExpiry = DateTime.parse(expiryString);
      }

      final trialStartString = prefs.getString('trial_start_date');
      if (trialStartString != null) {
        _trialStartDate = DateTime.parse(trialStartString);
      }

      // Auto-cleanup expired trial flag
      if (isTrialExpired && _isInTrial) {
        _isInTrial = false;
        await _saveSubscriptionStatus();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load subscription status: $e';
      notifyListeners();
    }
  }

  // Save subscription status to local storage
  Future<void> _saveSubscriptionStatus({bool syncToFirestore = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_subscribed', _isSubscribed);
      await prefs.setString('subscription_type', _subscriptionType ?? '');
      await prefs.setBool('is_in_trial', _isInTrial);
      await prefs.setBool(
        'has_shown_trial_expired_dialog',
        _hasShownTrialExpiredDialog,
      );

      if (_subscriptionExpiry != null) {
        await prefs.setString(
          'subscription_expiry',
          _subscriptionExpiry!.toIso8601String(),
        );
      }

      if (_trialStartDate != null) {
        await prefs.setString(
          'trial_start_date',
          _trialStartDate!.toIso8601String(),
        );
      }

      if (syncToFirestore) {
        await _updateFirestoreSubscription();
      }
    } catch (e) {
      _error = 'Failed to save subscription status: $e';
      notifyListeners();
    }
  }

  // Start free trial
  Future<bool> startFreeTrial(String planType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user has already used trial
      final prefs = await SharedPreferences.getInstance();
      final hasUsedTrial = prefs.getBool('has_used_trial') ?? false;

      if (hasUsedTrial) {
        _error = 'Trial already used';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Start trial
      _isInTrial = true;
      _trialStartDate = DateTime.now();
      _subscriptionType = planType;
      await prefs.setBool('has_used_trial', true);

      await _saveSubscriptionStatus();

      // Cancel premium promotion notification when trial starts
      if (_notificationProvider != null) {
        await _notificationProvider!.cancelPremiumPromotionForPremiumUser();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to start trial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Subscribe to monthly plan
  Future<bool> subscribeMonthly() async {
    return await _processSubscription('monthly', AppConfig.monthlyPrice);
  }

  // Subscribe to yearly plan
  Future<bool> subscribeYearly() async {
    return await _processSubscription('yearly', AppConfig.yearlyPrice);
  }

  // Process subscription payment
  Future<bool> _processSubscription(String type, double price) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Basic validation
      if (price <= 0 || price > 999999.99) {
        _error = 'Invalid payment amount. Please contact support.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Process payment through Stripe
      // final success = await StripeService.instance.makePayment(price);
      
      final success = true;
      if (success) {
        // Update subscription status
        _isSubscribed = true;
        _subscriptionType = type;
        _isInTrial = false; // End trial when subscription starts

        // Set expiry date based on subscription type
        if (type == 'monthly') {
          _subscriptionExpiry = DateTime.now().add(const Duration(days: 30));
        } else if (type == 'yearly') {
          _subscriptionExpiry = DateTime.now().add(const Duration(days: 365));
        }

        // Save to local storage
        await _saveSubscriptionStatus();

        // Cancel premium promotion notification when subscription is successful
        if (_notificationProvider != null) {
          await _notificationProvider!.cancelPremiumPromotionForPremiumUser();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Payment failed
        _error = 'Payment failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Subscription failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would call your backend API to cancel the subscription
      // For now, we'll just update the local status
      _isSubscribed = false;
      _isInTrial = false;
      _subscriptionType = null;
      _subscriptionExpiry = null;

      await _saveSubscriptionStatus();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to cancel subscription: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reload subscription status (public method for external use)
  Future<void> reloadSubscriptionStatus() async {
    await _loadSubscriptionStatus();
  }

  // Check if user has used trial
  Future<bool> hasUsedTrial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('has_used_trial') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get remaining trial days
  int getRemainingTrialDays() {
    if (!_isInTrial || _trialStartDate == null) return 0;
    final trialEnd = _trialStartDate!.add(const Duration(days: 7));
    final remaining = trialEnd.difference(DateTime.now());
    return remaining.inDays > 0 ? remaining.inDays : 0;
  }

  // Get subscription info for display
  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'isSubscribed': _isSubscribed,
      'subscriptionType': _subscriptionType,
      'subscriptionExpiry': _subscriptionExpiry?.toIso8601String(),
      'isActive': isSubscriptionActive,
      'hasPremiumFeatures': hasPremiumFeatures,
      'isInTrial': _isInTrial,
      'isTrialActive': isTrialActive,
      'trialStartDate': _trialStartDate?.toIso8601String(),
      'remainingTrialDays': getRemainingTrialDays(),
      'isTrialExpired': isTrialExpired,
    };
  }

  // Check if should show trial expired dialog
  bool shouldShowTrialExpiredDialog() {
    return isTrialExpired &&
        !_hasShownTrialExpiredDialog &&
        !isSubscriptionActive;
  }

  // Mark trial expired dialog as shown
  Future<void> markTrialExpiredDialogShown() async {
    _hasShownTrialExpiredDialog = true;
    await _saveSubscriptionStatus();
    notifyListeners();
  }
}
