import 'package:flutter_test/flutter_test.dart';

import 'package:examace/const/const.dart';

void main() {
  test('app constants expose expected startup route', () {
    expect(AppConstants.appName, 'ExamAce');
    expect(AppRoutes.splash, '/');
    expect(AppRoutes.main, '/main');
  });
}
