// lib/view_model/nav_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final navIndexProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);

class NavNotifier extends Notifier<int> {
  @override
  int build() => 0; // default tab: Home

  void setTab(int index) {
    // add any logic here, e.g. auth guard
    state = index;
  }
}
