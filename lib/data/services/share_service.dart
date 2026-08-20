import 'package:flutter/services.dart';
import '../models/song.dart';

class ShareService {
  ShareService._();
  static const MethodChannel _channel = MethodChannel('com.tunex.app/share');

  static Future<bool> shareSong(Song song) async {
    try {
      return await _channel.invokeMethod<bool>('shareFile', {'path': song.filePath}) ?? false;
    } on PlatformException {
      return false;
    }
  }
}
