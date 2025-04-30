// lib/features/categories/widgets/file_item.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FileItem extends StatelessWidget {
  final Receipt receipt;
  final Color categoryColor;
  final VoidCallback? onTap;

  const FileItem({
    Key? key,
    required this.receipt,
    required this.categoryColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar siempre el color primario de la app independientemente del color de categoría pasado
    final Color standardColor = AppColors.primary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingM),
            child: Row(
              children: [
                // Icono o miniatura
                _buildThumbnail(standardColor),
                
                const SizedBox(width: AppDimens.paddingM),
                
                // Información del recibo (ocupa todo el espacio restante)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: AppDimens.iconXS,
                            color: standardColor,
                          ),
                          const SizedBox(width: AppDimens.paddingXS),
                          Text(
                            receipt.formattedDate,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimens.paddingXS),
                      
                      // Monto
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: AppDimens.iconXS,
                            color: standardColor,
                          ),
                          const SizedBox(width: AppDimens.paddingXS),
                          Text(
                            receipt.formattedAmount,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: standardColor,
                            ),
                          ),
                        ],
                      ),
                      
                      // Nombre del archivo (opcional, según tu UI)
                      if (receipt.fileName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppDimens.paddingXS),
                          child: Row(
                            children: [
                              Icon(
                                receipt.isPdf ? Icons.picture_as_pdf : Icons.image,
                                size: AppDimens.iconXS,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppDimens.paddingXS),
                              Expanded(
                                child: Text(
                                  receipt.displayName,
                                  style: AppTextStyles.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Flecha para indicar navegación
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: AppDimens.iconM,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(Color standardColor) {
    final double thumbnailSize = 50; // Tamaño fijo para la miniatura
    
    return Container(
      width: thumbnailSize,
      height: thumbnailSize,
      decoration: BoxDecoration(
        color: standardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: receipt.isPdf
          ? Center(
              child: Icon(
                Icons.picture_as_pdf,
                size: 32,
                color: standardColor,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              child: CachedNetworkImage(
                imageUrl: receipt.fileUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: standardColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
            ),
    );
  }
}