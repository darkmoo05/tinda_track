import '../../../../../core/domain/sync_metadata.dart';

class BusinessProfile {
  final String id;
  final String businessType;
  final String businessName;
  final String defaultCurrency;
  final Map<String, dynamic> preferences;
  final SyncMetadata sync;

  BusinessProfile({
    required this.id,
    required this.businessType,
    required this.businessName,
    required this.defaultCurrency,
    required this.preferences,
    required this.sync,
  });

  bool get showRecipes => preferences['showRecipes'] as bool? ?? false;
  bool get showSerialTracking => preferences['showSerialTracking'] as bool? ?? false;
  bool get showMultiLocation => preferences['showMultiLocation'] as bool? ?? false;
  bool get showBundles => preferences['showBundles'] as bool? ?? false;

  BusinessProfile copyWith({
    String? id,
    String? businessType,
    String? businessName,
    String? defaultCurrency,
    Map<String, dynamic>? preferences,
    SyncMetadata? sync,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      businessType: businessType ?? this.businessType,
      businessName: businessName ?? this.businessName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      preferences: preferences ?? this.preferences,
      sync: sync ?? this.sync,
    );
  }
}
