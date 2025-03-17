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
    return const Scaffold(
      drawer: MainDrawer(),
    );
  }
}
