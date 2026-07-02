/// ─────────────────────────────────────────────────────────────────────────────
/// reels_actions_sidebar.dart
/// Right-side action column: share (top), then like, comment, save.
/// Floats on top of the video, vertically centred.
/// Zero logic — callbacks and state passed from parent.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ReelsActionsSidebar extends StatelessWidget {
  const ReelsActionsSidebar({
    super.key,
    required this.isLiked,
    required this.isSaved,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
  });

  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share — top, standalone
        _ActionButton(
          icon: Icons.share_outlined,
          onTap: onShare,
        ),

        SizedBox(height: 3.h),

        // Like
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          iconColor: isLiked ? const Color(0xFFFF4D6D) : AppColors.white,
          label: _formatCount(likeCount),
          onTap: onLike,
        ),

        SizedBox(height: 2.5.h),

        // Comment
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: _formatCount(commentCount),
          onTap: onComment,
        ),

        SizedBox(height: 2.5.h),

        // Save
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
          iconColor: isSaved ? AppColors.gold : AppColors.white,
          onTap: onSave,
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: iconColor ?? AppColors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 8),
            ],
          ),
          if (label != null) ...[
            SizedBox(height: 0.4.h),
            Text(
              label!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                shadows: const [
                  Shadow(color: Colors.black38, blurRadius: 6),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}