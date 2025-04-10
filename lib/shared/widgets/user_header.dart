// lib/shared/widgets/user_header.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/services/profile_service.dart';

class UserHeader extends StatefulWidget {
  final String username;
  final bool isLoading;
  final double? avatarRadius;
  final String? profileImageUrl;

  const UserHeader({
    Key? key,
    required this.username,
    this.isLoading = false,
    this.avatarRadius,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  final ProfileService _profileService = ProfileService();
  String? _profileImageUrl;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (widget.profileImageUrl != null) {
      setState(() {
        _profileImageUrl = widget.profileImageUrl;
        _isLoadingImage = false;
      });
      return;
    }

    try {
      final imageUrl = await _profileService.getProfileImageUrl();
      if (mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adaptación a diferentes tamaños de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final double radius = widget.avatarRadius ??
        (screenWidth < 360 ? 16 : AppDimens.avatarRadiusM);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
      child: Row(
        children: [
          _isLoadingImage
              ? CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.grey[300],
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : const AssetImage('assets/profile.jpg'),
                ),
          const SizedBox(width: AppDimens.paddingM),
          widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "${AppStrings.greeting} ${widget.username}!",
                  style: AppTextStyles.greeting,
                ),
        ],
      ),
    );
  }
}