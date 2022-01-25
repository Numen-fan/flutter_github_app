import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/Global.dart';
import 'package:flutter_github_app/states/profile_view_model.dart';

class ThemeViewModel extends ProfileViewModel {

  // 获取当前主题，如果未设置主题，则默认使用蓝色主题, firstWhere查找第一个满足条件的元素
  MaterialColor get theme => Global.themes.firstWhere(
          (element) => element.value == profile.theme, orElse: () => Colors.blue);

  set theme(MaterialColor color) {
    profile.theme = color.value;
    notifyListeners();
  }

}