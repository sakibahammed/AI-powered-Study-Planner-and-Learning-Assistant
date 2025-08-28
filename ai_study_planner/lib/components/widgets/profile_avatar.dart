import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;
  final BoxShape shape;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    this.size = 60,
    this.shape = BoxShape.circle,
    this.border,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final ProfileService profileService = ProfileService.instance;

    Widget avatarWidget = profileService.getProfileImageWidget(
      size: size,
      shape: shape,
      border: showBorder
          ? (border ??
                Border.all(color: Colors.blue.withOpacity(0.3), width: 2))
          : null,
    );

    if (onTap != null) {
      avatarWidget = GestureDetector(onTap: onTap, child: avatarWidget);
    }

    return avatarWidget;
  }
}
