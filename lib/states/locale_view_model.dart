import 'dart:ui';

import 'package:flutter_github_app/states/profile_view_model.dart';

class LocaleViewModel extends ProfileViewModel {
  /// 获取当前用户的APP语言配置Locale类，如果为null，则语言跟随系统语言
  Locale? getLocale() {
    if (profile.locale == null) {
      return null;
    }
    List<String>? t = profile.locale?.split("_");
    if (t == null || t.isEmpty || t.length < 2) {
      return null;
    }
    return Locale(t[0], t[1]);
  }

  /// 获取当前Locale的字符串表示
  String? get locale => profile.locale;

  set locale(String? locale) {
    if (locale != profile.locale) {
      profile.locale = locale;
      notifyListeners();
    }
  }
}
