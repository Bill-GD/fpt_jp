import 'package:flutter/material.dart';

import '../../../utils/helpers/helper.dart';

const TextStyle titleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
);

const TextStyle bodyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

InputDecoration textFieldDecoration({
  Color? fillColor,
  String? hintText,
  String? labelText,
  String? errorText,
  InputBorder? border,
  Widget? prefixIcon,
  Widget? suffixIcon,
  EdgeInsetsGeometry? contentPadding,
  BoxConstraints? constraints,
}) {
  final context = getGlobalContext();
  return InputDecoration(
    filled: true,
    fillColor: fillColor,
    hintText: hintText,
    hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
    labelText: labelText,
    labelStyle: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minHeight: 2, minWidth: 2),
    contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 20),
    border: border,
    constraints: constraints,
  );
}
