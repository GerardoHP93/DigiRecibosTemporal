// lib/features/settings/widgets/profile_edit_field.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class ProfileEditField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final bool isSaving;

  const ProfileEditField({
    Key? key,
    required this.label,
    required this.controller,
    required this.onSave,
    this.isSaving = false,
  }) : super(key: key);

  @override
  State<ProfileEditField> createState() => _ProfileEditFieldState();
}

class _ProfileEditFieldState extends State<ProfileEditField> {
  bool _isEditing = false;
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    _originalValue = widget.controller.text;
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Si estamos guardando, confirmar cambios
      if (widget.controller.text != _originalValue) {
        widget.onSave();
        _originalValue = widget.controller.text;
      }
    }

    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      widget.controller.text = _originalValue;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.fontM,
              ),
            ),
            if (widget.isSaving)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: AppColors.primary,
                ),
                onPressed: widget.isSaving ? null : _toggleEdit,
                tooltip: _isEditing ? 'Guardar' : 'Editar',
              ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingS),
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingL,
                      vertical: AppDimens.paddingM,
                    ),
                  ),
                  enabled: !widget.isSaving,
                  autofocus: true,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: widget.isSaving ? null : _cancelEdit,
                tooltip: 'Cancelar',
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: AppDimens.paddingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.controller.text,
              style: const TextStyle(fontSize: AppDimens.fontM),
            ),
          ),
      ],
    );
  }
}