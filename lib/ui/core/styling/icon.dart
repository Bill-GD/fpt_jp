import 'package:flutter/material.dart';

Color? iconColor(BuildContext context, [double opacity = 1]) => Theme.of(context).iconTheme.color?.withOpacity(opacity);
