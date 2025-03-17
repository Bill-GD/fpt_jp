import 'package:flutter/material.dart';

import '../view_model/kanji_view_model.dart';

class KanjiScreen extends StatefulWidget {
  final KanjiViewModel viewModel;

  const KanjiScreen({super.key, required this.viewModel});

  @override
  State<KanjiScreen> createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
