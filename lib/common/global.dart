import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_github_app/models/index.dart';
import 'package:flutter_github_app/net/git_network_util.dart';
import 'package:flutter_github_app/net/net_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 存储一些全局变量

/// 提供五套可选主题色
const List<MaterialColor> _themes = [
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red
];

class Global {
  static late SharedPreferences _prefs; // 应该把SharedPreferences提出去
  static Profile profile = Profile(); // 登录的用户信息

  static NetCache netCache = NetCache();

  static List<MaterialColor> get themes => _themes;
  
  // 是否是release版本
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  // 初始全局信息
  static Future<void> init() async {
    // 必须在根 widget build中初始化，如果提前到 main 中会出现异常
    _prefs = await SharedPreferences.getInstance();
    String? _profileStr = _prefs.getString("profile");
    if (_profileStr != null) {
      try {
        profile = Profile.fromJson(json.decode(_profileStr));
      } catch (e) {
        print(e);
      }
    }

    // 如果没有缓存策略，设置默认的缓存策略
    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // 初始化网络请求相关配置
    Git.init(); // 这个最好拿出去

  }

  // 持久化Profile信息
  static void saveProfile() => _prefs.setString("profile", jsonEncode(profile.toJson()));

}