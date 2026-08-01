import 'package:dio/dio.dart';

class ErrorHandler {
  static bool _looksLikeInfo(Map<String, dynamic> map) {
    return map.containsKey('code') &&
        (map.containsKey('title') ||
            map.containsKey('description') ||
            map.containsKey('infoType'));
  }

  /// Parses API info payloads.
  /// Supports: bare info list, nested `infos` on a domain object (e.g. Order 409),
  /// or a single info map. Does **not** treat arbitrary domain maps as infos.
  static List<Map<String, dynamic>>? parseInfoList(dynamic data) {
    if (data is List && data.isNotEmpty) {
      final infos = <Map<String, dynamic>>[];
      for (final item in data) {
        Map<String, dynamic>? map;
        if (item is Map<String, dynamic>) {
          map = item;
        } else if (item is Map) {
          map = Map<String, dynamic>.from(item);
        }
        if (map != null && _looksLikeInfo(map)) {
          infos.add(map);
        }
      }
      return infos.isEmpty ? null : infos;
    }
    if (data is Map) {
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data);
      final nested = map['infos'];
      if (nested is List && nested.isNotEmpty) {
        return parseInfoList(nested);
      }
      if (_looksLikeInfo(map)) {
        return [map];
      }
    }
    return null;
  }

  /// Business success codes are typically 1000+ (e.g. 1001).
  /// HTTP-style client/server errors (400–599, e.g. 409) mean failure.
  static bool isSuccessInfo(Map<String, dynamic> info) {
    final code = info['code'];
    if (code is int) {
      if (code >= 400 && code <= 599) {
        return false;
      }
      return true;
    }
    return true;
  }

  static String? messageFromBadResponse(DioException error) {
    final infos = parseInfoList(error.response?.data);
    if (infos != null && infos.isNotEmpty) {
      final description = infos.first['description'];
      if (description != null && description.toString().isNotEmpty) {
        return description.toString();
      }
    }
    return null;
  }

  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'اتصال به سرور زمان‌بر شد';
        case DioExceptionType.sendTimeout:
          return 'ارسال درخواست زمان‌بر شد';
        case DioExceptionType.receiveTimeout:
          return 'دریافت پاسخ زمان‌بر شد';
        case DioExceptionType.badResponse:
          return messageFromBadResponse(error) ??
              'خطا در دریافت اطلاعات از سرور';
        case DioExceptionType.cancel:
          return 'درخواست لغو شد';
        case DioExceptionType.connectionError:
          return 'عدم اتصال به اینترنت';
        default:
          return 'خطای ناشناخته شبکه';
      }
    }
    return 'خطای غیرمنتظره رخ داد';
  }
}
