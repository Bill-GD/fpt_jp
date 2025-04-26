import 'package:flutter/material.dart';

import '../../data/repositories/about_repository.dart';
import '../../data/repositories/kanji_repository.dart';
import '../../data/repositories/vocab_repository.dart';
import '../../utils/extensions/number_duration.dart';
import '../../utils/handlers/log_handler.dart';
import '../../utils/helpers/globals.dart';
import '../../utils/helpers/helper.dart';
import '../core/styling/text.dart';
import '../core/ui/action_dialog.dart';
import '../core/ui/drawer.dart';
import '../kanji/view_model/kanji_view_model.dart';
import '../kanji/widgets/kanji_lesson_list_screen.dart';
import '../vocab/vocab_screen.dart';

class HomeScreen extends StatefulWidget {
  final AboutRepository aboutRepo;

  const HomeScreen({super.key, required this.aboutRepo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (Globals.newestVersion.isEmpty) {
      widget.aboutRepo.getNewestVersion().then((value) {
        Globals.newestVersion = value.substring(1);
        if (isVersionNewer(Globals.newestVersion)) {
          LogHandler.log('New version found: ${Globals.newestVersion}');
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [EndDrawerButton()],
        title: const Text('Review FPT Japanese'),
        centerTitle: true,
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    getGlobalContext(),
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) {
                        return KanjiLessonListScreen(viewModel: KanjiViewModel(kanjiRepo: KanjiRepository()));
                      },
                      transitionsBuilder: (context, anim1, _, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: const Offset(0, 0),
                          ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text('Kanji'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      getGlobalContext(),
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) {
                          return VocabScreen(vocabRepo: VocabRepository());
                        },
                        transitionsBuilder: (context, anim1, _, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: const Offset(0, 0),
                            ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('Vocabulary'),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Not yet implemented.'),
                  ));
                },
                child: const Text('Grammar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
