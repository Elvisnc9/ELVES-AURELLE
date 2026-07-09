/// ─────────────────────────────────────────────────────────────────────────────
/// brand_profile_model.dart
/// Minimal brand data shown in the bottom sheet.
/// Add this to ReelModel so each reel carries its brand's profile.
/// ─────────────────────────────────────────────────────────────────────────────

class BrandProfile {
  const BrandProfile({
    required this.id,
    required this.name,
    required this.followers,
    required this.rating,
    required this.reviewCount,
    this.avatarUrl,
    this.tagline,
  });

  final String id;
  final String name;
  final int followers;
  final double rating;
  final int reviewCount;
  final String? avatarUrl;
  final String? tagline;

  /// e.g. 12400 → "12.4K"
  String get followersFormatted {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}