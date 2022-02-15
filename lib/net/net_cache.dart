
import 'package:dio/dio.dart';
import 'package:flutter_github_app/common/global.dart';
import 'package:flutter_github_app/net/cache_object.dart';

/// net cache处理
/// 通过拦截器处理
class NetCache extends Interceptor{

  // cache map数据结果
  var cache = <String, CacheObject>{};

  /// 处理请求
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!Global.profile.cache!.enable) { // 全局配置不缓存
      return handler.next(options);
    }

    // 是否是下拉刷新, 如果不使用 == true的方式，则可能是 null 转 bool，会有异常
    bool refresh = options.extra["refresh"] == true;
    if (refresh) {
      if (options.extra["list"]) {
        // 如果是刷新列表，则只要url中包含当前path的缓存全部删除
        cache.removeWhere((key, value) => key.contains(options.path));
      } else { // 否则删除该uri的缓存
        delete(options.uri.toString());
      }
      // 清除缓存后，发起请求
      return handler.next(options);
    }

    // 使用缓存
    if (options.extra["cache"] == true && options.method.toLowerCase() == "get") {
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      var cacheObject = cache[key];
      if (cacheObject != null) {
        // 如果缓存没有过期，则返回缓存内容
        if (DateTime.now().millisecondsSinceEpoch - cacheObject.timeStamp / 1000 < Global.profile.cache!.maxAge) {
          return handler.resolve(cacheObject.response);
        } else {
          // 缓存过期删除
          delete(key);
        }
      }
    }
    // 正常请求
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 如果启用了缓存，将返回结果缓存
    if (Global.profile.cache!.enable) {
      _saveCache(response);
    }
    handler.next(response);
  }

  void _saveCache(Response response) {
    RequestOptions options = response.requestOptions;
    if (options.extra["cache"] == true && options.method.toLowerCase() == "get") {
      // 如果缓存数超过最大数量限制，则先移除最早的一条记录
      if (cache.length >= Global.profile.cache!.maxCount) {
        delete(cache.keys.first);
      }

      String key = options.extra["cacheKey"] ?? options.uri.toString();
      cache[key] = CacheObject(response);
    }
  }

  void delete(String uri) {
    cache.remove(uri);
  }
}