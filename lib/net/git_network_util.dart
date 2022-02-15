
import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_github_app/common/global.dart';
import 'package:flutter_github_app/models/index.dart';
import 'package:flutter_github_app/models/user.dart';

/// Github API 访问工具类

class Git {

  Git([this.context]) {
    _options = Options(extra: {"context": context});
  }

  BuildContext? context; // 有时会来网络请求之后进行页面的跳转，这里个人认为不合适，应该将跳转的操作抛给上层去处理
  Options? _options;

  static Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://api.github.com",
      headers: {
        HttpHeaders.acceptHeader: "application/vnd.github.v3+json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
    ),
  );

  static void init() {
    // 1 设置拦截器，即添加缓存插件
    dio.interceptors.add(Global.netCache);
    // 2 设置用户的token, （null代表没有登录）
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
    // 3 在调试模式下需要抓包调试，所以使用代理，并禁用https证书校验
    if (!Global.isRelease) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        // 设置代理抓包，供调试使用
        // client.findProxy = (uri) => "PROXY 192.168.50.154:8888";
        //
        // 代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      };
    }
  }
  
  // 登录接口，登录成功后返回用户信息
  Future<User> login(String username, String pwd) async {
    String token = 'token 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';
    var resp = await dio.get("/user",
        options: _options?.copyWith(
            headers: {HttpHeaders.authorizationHeader: token},
            extra: {"cache": false}));
    // 登录成功后更新公共头(authorization)， 此后所有的请求都会带上用户身份信息
    // todo 没有 check 是否登录成功啊
    dio.options.headers[HttpHeaders.authorizationHeader] = token;
    // 清空所有的缓存
    Global.netCache.cache.clear();
    // 更新 profile 中的token 信息
    Global.profile.token = token;
    return User.fromJson(resp.data);
  }


  Future<User> getUserInfo(String userName) async {
    var resp = await dio.get('/users/$userName');
    return User.fromJson(resp.data);
  }
}