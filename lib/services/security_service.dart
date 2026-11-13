import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة أمنية: تخزين آمن + كشف root/debug + تحقق سلامة
class SecurityService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// تخزين آمن (EncryptedSharedPreferences على Android)
  static Future<void> secureWrite(String key, String value) =>
      _storage.write(key: key, value: value);
  static Future<String?> secureRead(String key) => _storage.read(key: key);
  static Future<void> secureDelete(String key) => _storage.delete(key: key);

  /// كشف بيئة debug (لتعطيل logs في release)
  static bool get isDebug => kDebugMode;

  /// كشف root ( heuristic ) — للتنبيه فقط (لا حظر صارم)
  static Future<bool> isRooted() async {
    if (!Platform.isAndroid) return false;
    final suspicious = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
    ];
    for (final p in suspicious) {
      if (await File(p).exists()) return true;
    }
    return false;
  }

  /// تحقق سلامة (checksum بسيط لملف تقدم) — للتوسع لاحقاً
  static String checksum(String data) {
    int h = 0;
    for (final c in data.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h.toRadixString(16);
  }
}
