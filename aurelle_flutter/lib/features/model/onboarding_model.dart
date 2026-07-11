/// ─────────────────────────────────────────────────────────────────────────
/// Onboarding option models
/// Plain immutable data classes — no logic, just shape. Keeping these
/// separate from the provider means the option lists can later be fetched
/// from a remote config / CMS without touching any state-management code.
/// ─────────────────────────────────────────────────────────────────────────

/// A single tile option that uses a full-bleed image (Style Identity +
/// Discovery Preference screens both use this shape).
class ImageOption {
  const ImageOption({
    required this.id,
    required this.label,
    required this.imageAsset,
  });

  final String id;
  final String label;
  final String imageAsset;
}

/// A single brand tile (logo + name, no nested container).
class BrandOption {
  const BrandOption({
    required this.id,
    required this.name,
    required this.logoAsset,
  });

  final String id;
  final String name;
  final String logoAsset;
}

/// ── Static option lists ─────────────────────────────────────────────────
/// Swap these for a remote-config fetch later without touching UI code.

const List<ImageOption> styleOptions = [
  ImageOption(
    id: 'minimalist',
    label: 'MINIMALIST',
    imageAsset: 'assets/images/onboarding/mini.png',
  ),
 
  ImageOption(
    id: 'boho',
    label: 'BOHO',
    imageAsset: 'assets/images/onboarding/boho.png',
  ),

   ImageOption(
    id: 'old_money',
    label: 'OLD MONEY',
    imageAsset: 'assets/images/onboarding/old-school.png',
  ),
  ImageOption(
    id: 'streetwear',
    label: 'STREETWEAR',
    imageAsset: 'assets/images/onboarding/jeans.png',
  ),
  ImageOption(
    id: 'romantic',
    label: 'ROMANTIC',
    imageAsset: 'assets/images/onboarding/rom.png',
  ),
  ImageOption(
    id: 'edgy',
    label: 'EDGY',
    imageAsset: 'assets/images/onboarding/edgy.png',
  ),
];



const List<BrandOption> brandOptions = [
  BrandOption(id: 'elvis', name: 'Chanel', logoAsset: 'assets/images/brands/burberry.png'),
  BrandOption(id: 'prada', name: 'Prada', logoAsset: 'assets/images/brands/gucci.png'),
  BrandOption(id: 'celine', name: 'Celine', logoAsset: 'assets/images/brands/chanel.png'),
  BrandOption(id: 'loewe', name: 'Loewe', logoAsset: 'assets/images/brands/ck.png'),
  BrandOption(id: 'gucci', name: 'Gucci', logoAsset: 'assets/images/brands/DG.png'),
  BrandOption(id: 'zara', name: 'Zara', logoAsset: 'assets/images/brands/givenchy.png'),
  BrandOption(id: 'reformation', name: 'Reformation', logoAsset: 'assets/images/brands/LoiueV.png'),
  BrandOption(id: 'dior', name: 'Dior', logoAsset: 'assets/images/brands/Supreme.png'),
  BrandOption(id: 'guccii', name: 'Gucci', logoAsset: 'assets/images/brands/LoiueV.png'),
  BrandOption(id: 'eee', name: 'Zara', logoAsset: 'assets/images/brands/Victoria.png'),
  BrandOption(id: 'chanel', name: 'Chanel', logoAsset: 'assets/images/brands/burberry.png'),
  BrandOption(id: 'pradaa', name: 'Prada', logoAsset: 'assets/images/brands/gucci.png'),
  BrandOption(id: 'celinea', name: 'Celine', logoAsset: 'assets/images/brands/chanel.png'),
  BrandOption(id: 'loewea', name: 'Loewe', logoAsset: 'assets/images/brands/ck.png'),
  BrandOption(id: 'gucciii', name: 'Gucci', logoAsset: 'assets/images/brands/DG.png'),
  BrandOption(id: 'zaraea', name: 'Zara', logoAsset: 'assets/images/brands/givenchy.png'),
];

const List<ImageOption> discoveryOptions = [
  ImageOption(
    id: 'trending',
    label: 'TRENDING NOW',
    imageAsset: 'assets/images/onboarding/trnd.png',
  ),
  ImageOption(
    id: 'new_arrivals',
    label: 'NEW ARRIVALS',
    imageAsset: 'assets/images/onboarding/red.png',
  ),
  ImageOption(
    id: 'editors_picks',
    label: "EDITOR'S PICKS",
    imageAsset: 'assets/images/onboarding/editors.png',
  ),
  ImageOption(
    id: 'following_brands',
    label: 'FOLLOWING BRANDS',
    imageAsset: 'assets/images/onboarding/ups.png',
  ),
];

/// ── Selection limits ────────────────────────────────────────────────────
/// Centralized so the provider and any UI hint text stay in sync.
class OnboardingLimits {
  OnboardingLimits._();
  static const int minStyles = 2;
  static const int maxStyles = 3;
  static const int maxDiscovery = 2;
}