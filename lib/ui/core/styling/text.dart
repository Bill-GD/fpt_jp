import 'package:flutter/material.dart';

const TextStyle bottomSheetTitle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
);

const TextStyle bottomSheetText = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w600,
);

// InputDecoration textFieldDecoration(
//     BuildContext context, {
//       Color? fillColor,
//       String? hintText,
//       String? labelText,
//       String? errorText,
//       InputBorder? border,
//       Widget? prefixIcon,
//       Widget? suffixIcon,
//       EdgeInsetsGeometry? contentPadding,
//       BoxConstraints? constraints,
//     }) =>
//     InputDecoration(
//       filled: true,
//       fillColor: fillColor,
//       hintText: hintText,
//       hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
//       labelText: labelText,
//       labelStyle: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
//       errorText: errorText,
//       prefixIcon: prefixIcon,
//       suffixIcon: suffixIcon,
//       suffixIconConstraints: const BoxConstraints(minHeight: 2, minWidth: 2),
//       contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 20),
//       border: border,
//       constraints: constraints,
//     );

Text leadingText(BuildContext context, String text, [bool bold = true, double size = 18]) => Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
