import 'package:flutter/cupertino.dart';
import 'package:flutter_github_app/common/global.dart';
import 'package:flutter_github_app/models/index.dart';

class ProfileViewModel extends ChangeNotifier {

  // 本身已经全局提供了，感觉没必要再设定get了啊
  final Profile _profile = Global.profile;
  Profile get profile => _profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); // 保存Profile的变更
    super.notifyListeners(); // 通知刷新
  }

}