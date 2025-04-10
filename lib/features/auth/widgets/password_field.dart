import 'package:flutter/material.dart';
import 'package:digirecibos/features/auth/widgets/auth_text_field.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? helperText;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.helperText,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      obscureText: _obscurePassword,
      helperText: widget.helperText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }
}