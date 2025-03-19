import 'package:flutter/material.dart';

import '../../../utils/extensions/number_duration.dart';
import '../../../utils/helpers/globals.dart';
import '../../core/styling/text.dart';
import '../../core/ui/action_dialog.dart';
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
  void initState() {
    super.initState();
    widget.viewModel.load.addListener(onLoad);
  }

  void onLoad() {
    ActionDialog.static<void>(
      context,
      title: 'New version available',
      titleFontSize: titleTextStyle.fontSize!,
      textContent: 'Current version: v${Globals.appVersion}\n'
          'New version: v${Globals.newestVersion}\n\n'
          'Check the about page for more details.',
      contentFontSize: bodyTextStyle.fontSize!,
      time: 200.ms,
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('OK'),
        )
      ],
    );
  }

  @override
  void dispose() {
    widget.viewModel.load.removeListener(onLoad);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: const [EndDrawerButton()],
          title: const Text('Review FPT Japanese'),
          centerTitle: true,
        ),
        endDrawer: const MainDrawer(),
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
