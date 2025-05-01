// lib/shared/widgets/user_header.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/services/profile_service.dart';
import 'package:digirecibos/core/constants/app_colors.dart';

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

    // Altura estándar para todos los headers
    final double standardHeight = kToolbarHeight + MediaQuery.of(context).padding.top + 10; // Añadimos 20 unidades más de altura

    // Depuración para verificar la altura
    debugPrint('UserHeader altura: $standardHeight');

    return Container(
      width: double.infinity,
      height: standardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight, // Color claro (B0D1E9)
            AppColors.primary,      // Color principal (95B8D1)
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimens.paddingL,
          right: AppDimens.paddingL,
          top: MediaQuery.of(context).padding.top, // Incluye el padding del sistema
        ),
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
                        color: Colors.white,
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
            Expanded(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "${AppStrings.greeting} ${widget.username}!",
                      style: AppTextStyles.greeting.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}