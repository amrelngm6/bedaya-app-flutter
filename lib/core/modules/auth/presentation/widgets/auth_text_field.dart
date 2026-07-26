import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';

/// A branded text-input used exclusively on auth screens.
///
/// Handles password visibility toggling automatically when [obscureText]
/// is true. All other behaviour is delegated to [TextFormField].
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int maxLines;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1D4E5F),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primaryTeal, size: 20)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: widget.enabled
            ? const Color(0xFFF0F7F8)
            : Colors.grey.shade100,
        border: _border(Colors.grey.shade300),
        enabledBorder: _border(Colors.grey.shade300),
        focusedBorder: _border(AppColors.primaryTeal, width: 1.8),
        errorBorder: _border(Colors.red.shade400),
        focusedErrorBorder: _border(Colors.red.shade400, width: 1.8),
        disabledBorder: _border(Colors.grey.shade200),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorStyle: const TextStyle(fontSize: 11.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}
