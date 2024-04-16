import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ValidateType { normal, phone, email, password, tax, id, none }

String? defaultValidator(String? value, ValidateType validateType) {
  if (value == null) return null;
  switch (validateType) {
    case ValidateType.normal:
      if (value.isEmpty) {
        return 'Field is required';
      }
      return null;
    default:
      return null;
  }
}

class TextCtrl extends TextEditingController {}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      this.labelText,
      this.textCtrl,
      this.obsecureText = false,
      this.readOnly = false,
      this.enable = true,
      this.maxLength,
      this.validateType = ValidateType.none,
      this.keyboardType = TextInputType.text,
      // this.onFinished,
      this.onChanged,
      this.maxLines = 1,
      this.minLines = 1,
      this.style,
      this.onTap,
      this.onSubmited,
      this.textAlign = TextAlign.start,
      this.suffixIcon,
      this.prefixIcon,
      this.hintText,
      this.inputFormatters,
      this.onSaved,
      this.labelStyle,
      this.color,
      this.border,
      this.focusBorder,
      this.errorBorder,
      this.disabledBorder,
      this.validator})
      : super(key: key);
  final TextEditingController? textCtrl;
  final String? labelText;
  final TextInputType keyboardType;
  final ValidateType validateType;
  final bool obsecureText;
  final bool readOnly;
  final bool enable;
  final int? maxLength;
  final Function(String)? onChanged;
  final void Function(String?)? onSaved;
  // final Function? onFinished;
  final int? maxLines;
  final int? minLines;
  final TextStyle? style;
  final Function? onTap;
  final TextAlign textAlign;
  final Function(String text)? onSubmited;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? labelStyle;
  final Color? color;
  final InputBorder? border;
  final InputBorder? focusBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: textCtrl,
      readOnly: readOnly,
      expands: true,
      enabled: enable,
      obscureText: obsecureText,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textAlignVertical: TextAlignVertical.center,
      style: style,
      onSaved: onSaved,
      onChanged: onChanged,
      onTap: () {
        // onTap();
        if (onTap != null) {
          onTap?.call();
        }
      },
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 12),
        labelStyle: labelStyle,
        border: border,
        enabledBorder: border,
        errorBorder: errorBorder,
        disabledBorder: disabledBorder,
        fillColor: color,
        filled: color != null,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      onFieldSubmitted: onSubmited,
      validator: (String? value) =>
          validator?.call(value) ?? defaultValidator(value, validateType),
    );
  }
}
