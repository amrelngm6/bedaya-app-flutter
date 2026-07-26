import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/colors.dart';

/// A row of [count] individual digit boxes for OTP entry.
///
/// Internally uses a single hidden [TextField] that fills the whole row;
/// the tappable boxes are decorative overlays drawn on top.
class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({
    super.key,
    this.count = 6,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  final int count;
  final void Function(String otp) onCompleted;
  final void Function(String otp)? onChanged;
  final bool enabled;

  @override
  OtpInputWidgetState createState() => OtpInputWidgetState();
}

// Expose state publicly so callers can hold a [GlobalKey<OtpInputWidgetState>]
// and call [clear()] from outside (e.g., on OTP resend).
class OtpInputWidgetState extends State<OtpInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String get _value => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_value);
    if (_value.length == widget.count) {
      _focusNode.unfocus();
      widget.onCompleted(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.enabled) _focusNode.requestFocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Hidden text field ───────────────────────────────────────────
          SizedBox(
            height: 1,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.count),
                ],
                enabled: widget.enabled,
              ),
            ),
          ),
          // ── Digit boxes ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.count, (i) {
              final isFocused = _focusNode.hasFocus && i == _value.length;
              final isFilled = i < _value.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 46,
                height: 54,
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.primaryTeal.withValues(alpha: 0.08)
                      : const Color(0xFFF0F7F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused
                        ? AppColors.primaryTeal
                        : isFilled
                        ? AppColors.primaryTeal.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                    width: isFocused ? 2 : 1.3,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  isFilled ? _value[i] : '',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isFilled ? AppColors.darkTeal : Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Clears the OTP field (called externally when resend fires).
  void clear() => _controller.clear();
}
