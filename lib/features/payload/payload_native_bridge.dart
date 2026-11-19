import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// H5 与 Flutter 原生桥接能力处理器
///
/// 封装拍照/相册选图、录音、音频播放与触感反馈等原生功能。
class PayloadNativeBridgeHandler {
  PayloadNativeBridgeHandler({
    required this.webViewController,
    ImagePicker? picker,
    AudioRecorder? recorder,
    AudioPlayer? player,
  })  : _picker = picker ?? ImagePicker(),
        _recorder = recorder ?? AudioRecorder(),
        _player = player ?? AudioPlayer();

  final WebViewController? webViewController;
  final ImagePicker _picker;
  final AudioRecorder _recorder;
  final AudioPlayer _player;

  String? _recordingPath;
  bool _isRecording = false;

  /// 处理从 H5 发送过来的桥接消息
  Future<void> handleMessage(String jsonStr) async {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final action = map['action'] as String?;
      final callbackId = map['callbackId'] as String?;

      switch (action) {
        case 'pickImage':
          await _handlePickImage(map, callbackId);
          break;
        case 'startRecord':
          await _handleStartRecord(callbackId);
          break;
        case 'stopRecord':
          await _handleStopRecord(callbackId);
          break;
        case 'playAudio':
          await _handlePlayAudio(map, callbackId);
          break;
        case 'stopAudio':
          await _handleStopAudio(callbackId);
          break;
        case 'haptic':
          await _handleHaptic(map, callbackId);
          break;
      }
    } catch (e) {
      // 容错处理
    }
  }

  Future<void> _handlePickImage(
    Map<String, dynamic> map,
    String? callbackId,
  ) async {
    final sourceStr = map['source'] as String? ?? 'gallery';
    final source = sourceStr == 'camera' ? ImageSource.camera : ImageSource.gallery;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Str = base64Encode(bytes);
        final mime = picked.mimeType ?? 'image/jpeg';
        final dataUrl = 'data:$mime;base64,$base64Str';

        _respond(callbackId, success: true, data: {'dataUrl': dataUrl});
      } else {
        _respond(callbackId, success: false, error: '用户取消选择');
      }
    } catch (e) {
      _respond(callbackId, success: false, error: e.toString());
    }
  }

  Future<void> _handleStartRecord(String? callbackId) async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/sirc_receipt_memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordingPath = filePath;
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );
        _isRecording = true;
        _respond(callbackId, success: true);
      } else {
        _respond(callbackId, success: false, error: '未授予麦克风权限');
      }
    } catch (e) {
      _respond(callbackId, success: false, error: e.toString());
    }
  }

  Future<void> _handleStopRecord(String? callbackId) async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _isRecording = false;
        final finalPath = path ?? _recordingPath;
        if (finalPath != null && File(finalPath).existsSync()) {
          final file = File(finalPath);
          final bytes = await file.readAsBytes();
          final base64Str = base64Encode(bytes);
          final dataUrl = 'data:audio/m4a;base64,$base64Str';
          _respond(callbackId, success: true, data: {
            'dataUrl': dataUrl,
            'path': finalPath,
          });
        } else {
          _respond(callbackId, success: false, error: '录音文件未找到');
        }
      } else {
        _respond(callbackId, success: false, error: '当前不在录音状态');
      }
    } catch (e) {
      _respond(callbackId, success: false, error: e.toString());
    }
  }

  Future<void> _handlePlayAudio(
    Map<String, dynamic> map,
    String? callbackId,
  ) async {
    final dataUrl = map['dataUrl'] as String?;
    final path = map['path'] as String?;
    try {
      await _player.stop();
      if (path != null && File(path).existsSync()) {
        await _player.play(DeviceFileSource(path));
      } else if (dataUrl != null && dataUrl.startsWith('data:audio/')) {
        final commaIdx = dataUrl.indexOf(',');
        if (commaIdx != -1) {
          final base64Part = dataUrl.substring(commaIdx + 1);
          final bytes = base64Decode(base64Part);
          await _player.play(BytesSource(bytes));
        }
      }
      _respond(callbackId, success: true);
    } catch (e) {
      _respond(callbackId, success: false, error: e.toString());
    }
  }

  Future<void> _handleStopAudio(String? callbackId) async {
    try {
      await _player.stop();
      _respond(callbackId, success: true);
    } catch (e) {
      _respond(callbackId, success: false, error: e.toString());
    }
  }

  Future<void> _handleHaptic(Map<String, dynamic> map, String? callbackId) async {
    try {
      final type = map['type'] as String? ?? 'light';
      if (type == 'heavy') {
        await HapticFeedback.heavyImpact();
      } else if (type == 'medium') {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.lightImpact();
      }
      _respond(callbackId, success: true);
    } catch (e) {
      _respond(callbackId, success: false, error: e.toString());
    }
  }

  void _respond(
    String? callbackId, {
    required bool success,
    Map<String, dynamic>? data,
    String? error,
  }) {
    if (callbackId == null || webViewController == null) return;
    final payload = <String, dynamic>{
      'callbackId': callbackId,
      'success': success,
      ...?data != null ? {'data': data} : null,
      ...?error != null ? {'error': error} : null,
    };
    final jsCode =
        'window.sircNativeBridgeCallback && window.sircNativeBridgeCallback(${jsonEncode(payload)})';
    webViewController?.runJavaScript(jsCode);
  }

  /// 释放相关资源
  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
