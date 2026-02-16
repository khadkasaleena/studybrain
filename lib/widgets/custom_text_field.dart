import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final double borderRadius;
  final BorderSide? borderSide;
  final bool isDense;
  final Widget? prefix;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.onFieldSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.fillColor,
    this.contentPadding,
    this.borderRadius = 12,
    this.borderSide,
    this.isDense = false,
    this.prefix,
    this.suffix,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.darkTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onSaved: widget.onSaved,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onFieldSubmitted,
            inputFormatters: widget.inputFormatters,
            textAlign: widget.textAlign,
            style: widget.textStyle ?? 
                theme.textTheme.bodyLarge?.copyWith(
                  color: widget.enabled 
                      ? AppTheme.darkTextColor 
                      : AppTheme.lightTextColor,
                ),
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              helperMaxLines: 2,
              filled: true,
              fillColor: widget.enabled
                  ? (widget.fillColor ?? AppTheme.surfaceColor)
                  : Colors.grey.shade100,
              isDense: widget.isDense,
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              
              // Prefix Icon
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused 
                            ? AppTheme.primaryColor
                            : AppTheme.lightTextColor,
                      ),
                    )
                  : null,
              
              // Prefix Widget
              prefix: widget.prefix,
              
              // Suffix Icon
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.suffixIcon,
                    )
                  : null,
              
              // Suffix Widget
              suffix: widget.suffix,

              // Border styles
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: widget.borderSide ?? 
                    BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: widget.borderSide ?? 
                    BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppTheme.errorColor,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),

              // Label and hint styles
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: _isFocused 
                    ? AppTheme.primaryColor 
                    : AppTheme.lightTextColor,
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextColor.withOpacity(0.7),
              ),
              helperStyle: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTextColor,
              ),
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorColor,
              ),

              // Counter style
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Specialized text field variants
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hint: hint ?? 'Search...',
      prefixIcon: Icons.search_rounded,
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              onPressed: () {
                controller?.clear();
                onClear?.call();
                onChanged?.call('');
              },
              icon: const Icon(Icons.clear_rounded),
            )
          : null,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      borderRadius: 25,
    );
  }
}

class OTPTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool autofocus;

  const OTPTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      onChanged: (value) {
        if (value.isNotEmpty) {
          FocusScope.of(context).nextFocus();
        }
        onChanged?.call(value);
      },
      autofocus: autofocus,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}

class MultilineTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final int minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const MultilineTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.maxLines = 5,
    this.minLines = 3,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showStrengthIndicator;

  const PasswordTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.showStrengthIndicator = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: widget.label ?? 'Password',
          hint: widget.hint,
          obscureText: _obscureText,
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.lightTextColor,
            ),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
        ),
        if (widget.showStrengthIndicator && widget.controller != null) ...[
          const SizedBox(height: 8),
          _PasswordStrengthIndicator(password: widget.controller!.text),
        ],
      ],
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  int _calculateStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final strengthText = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong'][strength];
    final strengthColor = [
      AppTheme.errorColor,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.blue,
      AppTheme.successColor,
    ][strength];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < strength ? strengthColor : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          strengthText,
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}