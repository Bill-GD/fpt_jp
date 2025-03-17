import 'package:flutter/material.dart';

import '../../core/ui/drawer.dart';
import '../view_model/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const DrawerButton(),
          title: const Text('Revise FPT Japanese'),
          centerTitle: true,
        ),
        drawer: const MainDrawer(),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => widget.viewModel.openKanji.execute(context),
                child: const Text('Kanji'),
              ),
              OutlinedButton(
                onPressed: () => widget.viewModel.openVocab.execute(context),
                child: const Text('Vocabulary'),
              ),
              OutlinedButton(
                onPressed: () => widget.viewModel.openGrammar.execute(context),
                child: const Text('Grammar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
