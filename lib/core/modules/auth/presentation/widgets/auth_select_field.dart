import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';

/// A branded text-input used exclusively on auth screens.
///
/// Handles password visibility toggling automatically when [obscureText]
/// is true. All other behaviour is delegated to [TextFormField].
class AuthSelectField extends StatefulWidget {
  const AuthSelectField({
    super.key,
    required this.label,
    this.hint,
    this.items,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.onFieldSubmitted,
    this.autofillHints,
    this.value,
    this.obscureText = false,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final List<DropdownMenuItem<String>>? items;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final bool obscureText;
  final String? value;

  @override
  State<AuthSelectField> createState() => _AuthSelectFieldState();
}

class _AuthSelectFieldState extends State<AuthSelectField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: widget.value,
      items: widget.items,
      onChanged: (value) {
        widget.enabled ? widget.onChanged!(value!) : () {};
      },

      validator: widget.validator,
      focusNode: widget.focusNode,
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
        prefixIcon: null,
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
