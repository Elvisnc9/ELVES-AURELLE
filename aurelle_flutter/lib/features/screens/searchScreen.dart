/// ─────────────────────────────────────────────────────────────────────────────
/// search_screen.dart
/// SSENSE-style search screen.
///
/// Empty state (no query):
///   CLOSE · search field · category tabs · SALE ONLY ·
///   SUGGESTED SEARCHES (big stacked brand names) · RECENTLY VIEWED row
///
/// Active state (query entered):
///   Same header + 3-column results grid (or empty state message)
///
/// Opens with keyboard immediately via autofocus on the TextField.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:aurelle_flutter/features/model/search_model.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:aurelle_flutter/features/provider/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode  = FocusNode();
    // Clear stale search state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).clear();
      _focusNode.requestFocus(); // keyboard up immediately
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchProvider.notifier).updateQuery(value);
  }

  void _applySuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    ref.read(searchProvider.notifier).applySuggestion(suggestion);
  }

  void _clear() {
    _controller.clear();
    ref.read(searchProvider.notifier).clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── CLOSE ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'CLOSE',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 11.sp,
                    letterSpacing: 1.6,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 1.5.h),

            // ── Search field ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      onChanged: _onQueryChanged,
                      textInputAction: TextInputAction.search,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'SEARCH BY DESIGNER OR PRODUCT',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                          color: AppColors.lightTextSecondary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: AppColors.lightTextPrimary,
                      cursorWidth: 1.5,
                    ),
                  ),
                  // Clear button — only visible when there's a query
                  if (state.hasQuery)
                    GestureDetector(
                      onTap: _clear,
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Bottom line under search field
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 1,
              color: AppColors.lightTextPrimary,
            ),

            SizedBox(height: 1.5.h),

            // ── Category tabs ────────────────────────────────────────────
            _CategoryTabs(
              selected: state.selectedCategory,
              onSelect: notifier.selectCategory,
            ),

            Container(height: 0.5, color: AppColors.divider),

            SizedBox(height: 0.5.h),

            // ── SALE ONLY ────────────────────────────────────────────────
            _SaleOnlyRow(
              value: state.saleOnly,
              onToggle: notifier.toggleSaleOnly,
            ),

            Container(height: 0.5, color: AppColors.divider),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: state.hasQuery
                  ? _ResultsView(
                      results: state.results,
                      isSearching: state.isSearching,
                      query: state.query,
                    )
                  : _EmptyStateView(
                      onSuggestionTap: _applySuggestion,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category tabs
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onSelect});
  final SearchCategory selected;
  final ValueChanged<SearchCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 5.h,
      child: Row(
        children: SearchCategory.values.map((cat) {
          final isActive = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? AppColors.lightTextPrimary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat.label,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.6,
                  color: isActive
                      ? AppColors.lightTextPrimary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sale only row
// ─────────────────────────────────────────────────────────────────────────────
class _SaleOnlyRow extends StatelessWidget {
  const _SaleOnlyRow({required this.value, required this.onToggle});
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.black,
                side: const BorderSide(color: AppColors.lightTextPrimary, width: 1),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'SALE ONLY',
              style: textTheme.labelLarge?.copyWith(
                fontSize: 11.sp,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — suggested searches + recently viewed
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView({required this.onSuggestionTap});
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          // ── SUGGESTED SEARCHES label ────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'SUGGESTED SEARCHES',
              style: textTheme.titleSmall?.copyWith(
                fontSize: 10.sp,
                letterSpacing: 1.4,
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // ── Suggestion rows ─────────────────────────────────────────
          ...suggestedSearches.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => onSuggestionTap(entry.value),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.2.h),
                    Text(
                      entry.value,
                      style: GoogleFonts.inter(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    Container(height: 0.5, color: AppColors.divider),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 40 * entry.key),
                    duration: 300.ms,
                  )
                  .slideX(begin: -0.03, end: 0, duration: 280.ms),
            );
          }),

          SizedBox(height: 3.h),

          // ── RECENTLY VIEWED label ───────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'RECENTLY VIEWED',
              style: textTheme.titleSmall?.copyWith(
                fontSize: 10.sp,
                letterSpacing: 1.4,
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // ── Recently viewed horizontal scroll ───────────────────────
          SizedBox(
            height: (40.w * 1.35) + 6.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: mockRecentlyViewed.length,
              separatorBuilder: (_, __) => SizedBox(width: 3.w),
              itemBuilder: (context, i) {
                final p = mockRecentlyViewed[i];
                return MiniProductCard(product: p);
              },
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results view — 3-column grid when query is active
// ─────────────────────────────────────────────────────────────────────────────
class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.results,
    required this.isSearching,
    required this.query,
  });

  final List<ShopProductModel> results;
  final bool isSearching;
  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.black,
          strokeWidth: 1.5,
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No results for',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '"$query"',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(0, 1.h, 0, 4.h),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final p = results[i];
        return _SearchResultCard(product: p)
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 30 * i),
              duration: 250.ms,
            );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini product card — recently viewed horizontal scroll
// ─────────────────────────────────────────────────────────────────────────────
class MiniProductCard extends StatelessWidget {
  const MiniProductCard({super.key, required this.product});
  final HomeProductModel product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = 40.w;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: width * 1.35,
            color: AppColors.productPlaceholder,
            child: Center(
              child: Icon(
                Icons.person_outline,
                size: 28,
                color: AppColors.lightTextSecondary.withOpacity(0.25),
              ),
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            product.brand,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 10.sp,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.2.h),
          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              if (product.isOnSale) ...[
                SizedBox(width: 1.w),
                Text(
                  '\$${product.originalPrice!.toStringAsFixed(0)}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 9.sp,
                    color: AppColors.priceStrike,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.priceStrike,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search result card — 3-column grid
// ─────────────────────────────────────────────────────────────────────────────
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.product});
  final ShopProductModel product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: AppColors.productPlaceholder,
            child: Center(
              child: Icon(
                Icons.person_outline,
                size: 24,
                color: AppColors.lightTextSecondary.withOpacity(0.25),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(2.w, 0.8.h, 2.w, 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.brand,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.2.h),
              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (product.isOnSale) ...[
                    SizedBox(width: 1.w),
                    Text(
                      '\$${product.originalPrice!.toStringAsFixed(0)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 9.sp,
                        color: AppColors.priceStrike,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.priceStrike,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}