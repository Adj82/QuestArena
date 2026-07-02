import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/avatars.dart';
import '../../providers/user_providers.dart';
import '../../providers/avatar_providers.dart';
import '../../data/models/user_model.dart';

class AvatarSelectionScreen extends ConsumerWidget {
  const AvatarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('User not found')));

        return Scaffold(
          backgroundColor: AppColors.bgBase,
          appBar: AppBar(
            title: Text('AVATAR GALLERY', style: AppTextStyles.display.copyWith(fontSize: 18)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildCurrentSelection(user),
              const Divider(color: AppColors.surface, height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: AppAvatars.avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = AppAvatars.avatars[index];
                    final isUnlocked = user.unlockedAvatars.contains(avatar.url);
                    final isSelected = user.avatarUrl == avatar.url;

                    return _AvatarGridTile(
                      avatar: avatar,
                      isUnlocked: isUnlocked,
                      isSelected: isSelected,
                      onTap: () => _onAvatarTap(context, ref, user, avatar, isUnlocked),
                    ).animate().fadeIn(delay: (index * 30).ms).scale(delay: (index * 30).ms);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentSelection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Row(
        children: [
          Hero(
            tag: 'selected_avatar',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: SmartAvatar(
                avatarUrl: user.avatarUrl,
                size: 80,
                showBorder: false,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT SELECTION', style: AppTextStyles.label.copyWith(color: AppColors.gold, fontSize: 10)),
                const SizedBox(height: 4),
                Text(user.username, style: AppTextStyles.headline.copyWith(fontSize: 20)),
                Text(user.rank, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onAvatarTap(BuildContext context, WidgetRef ref, UserModel user, AvatarModel avatar, bool isUnlocked) async {
    debugPrint('Tapping avatar: ${avatar.name}, Unlocked: $isUnlocked');
    
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reach ${avatar.requiredLeague} League to unlock ${avatar.name}!'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (user.avatarUrl == avatar.url) {
      debugPrint('Avatar already selected');
      return;
    }

    try {
      debugPrint('Updating avatar for ${user.uid} to ${avatar.url}');
      await ref.read(avatarServiceProvider).selectAvatar(user.uid, avatar.url, user.unlockedAvatars);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${avatar.name} selected!'),
            backgroundColor: AppColors.teal,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error selecting avatar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
        );
      }
    }
  }
}

class _AvatarGridTile extends StatelessWidget {
  final AvatarModel avatar;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarGridTile({
    required this.avatar,
    required this.isUnlocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection Border
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isSelected ? 3 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.gold : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.surface,
                    child: ClipOval(
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: avatar.url,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            color: isUnlocked ? null : Colors.grey,
                            colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                          ),
                          if (!isUnlocked)
                            Positioned.fill(
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    child: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Selected Checkmark
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, color: Colors.black, size: 12),
                    ).animate().scale(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            avatar.name,
            style: AppTextStyles.bodyMd.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? Colors.white : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            isUnlocked ? avatar.style : avatar.requiredLeague,
            style: AppTextStyles.label.copyWith(
              fontSize: 8,
              color: isUnlocked ? AppColors.teal : AppColors.neonPink,
            ),
          ),
        ],
      ),
    );
  }
}
