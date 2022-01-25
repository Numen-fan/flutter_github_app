import 'dart:ui';

import 'package:flutter_github_app/states/profile_view_model.dart';

class LocaleViewModel extends ProfileViewModel {

  Locale? getLocale() {
    if (profile.locale == null) {
      return null;
    }

    List<String>? t = profile.locale?.split("_");

    return Locale(t![0], t[1]);

  }

}