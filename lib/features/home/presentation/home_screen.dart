import 'package:flutter/material.dart';

import 'package:mbe_ui/features/home/presentation/home_welcome.dart';

/// The Home destination body, rendered inside the shell (the shell owns the
/// `Scaffold`/app bar). Shows the branded welcome (spec 010 US3, FR-015/017).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeWelcome();
  }
}
