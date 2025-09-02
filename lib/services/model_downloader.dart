import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static const String modelUrl = 'https://huggingface.co/google/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-q4_k_m.gguf';
  static const String fileName = 'gemma-3n-E2B-it-Q4_K_M.gguf';
  
  /// 다운로드 진행률 콜백
  typedef ProgressCallback = void Function(int downloaded, int total);
  
  /// 모델 다운로드
  static Future<String> downloadModel({
    ProgressCallback? onProgress,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    try {
      // 저장 경로 설정
      final documentsDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${documentsDir.path}/models');
      
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }
      
      final filePath = '${modelsDir.path}/$fileName';
      final file = File(filePath);
      
      // 이미 파일이 있으면 건너뛰기
      if (await file.exists()) {
        final stat = await file.stat();
        if (stat.size > 100000000) { // 100MB 이상이면 유효한 파일로 간주
          onComplete?.call();
          return filePath;
        }
      }
      
      // HTTP 요청
      final request = http.Request('GET', Uri.parse(modelUrl));
      final response = await request.send();
      
      if (response.statusCode != 200) {
        throw Exception('다운로드 실패: HTTP ${response.statusCode}');
      }
      
      final contentLength = response.contentLength ?? 0;
      int downloadedBytes = 0;
      
      // 파일 쓰기
      final sink = file.openWrite();
      
      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          downloadedBytes += chunk.length;
          onProgress?.call(downloadedBytes, contentLength);
        },
        onDone: () async {
          await sink.close();
          onComplete?.call();
        },
        onError: (error) async {
          await sink.close();
          onError?.call(error.toString());
        },
      ).asFuture();
      
      return filePath;
    } catch (e) {
      onError?.call(e.toString());
      rethrow;
    }
  }
  
  /// 다운로드 진행률을 퍼센트로 변환
  static double getProgressPercentage(int downloaded, int total) {
    if (total <= 0) return 0.0;
    return (downloaded / total * 100).clamp(0.0, 100.0);
  }
  
  /// 파일 크기를 사용자 친화적으로 표시
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
  
  /// 다운로드 속도 계산
  static String calculateSpeed(int bytes, Duration elapsed) {
    if (elapsed.inSeconds == 0) return '0 B/s';
    final bytesPerSecond = bytes / elapsed.inSeconds;
    return '${formatBytes(bytesPerSecond.round())}/s';
  }
  
  /// 예상 남은 시간 계산
  static String estimateTimeRemaining(int downloaded, int total, Duration elapsed) {
    if (downloaded == 0 || elapsed.inSeconds == 0) return '계산 중...';
    
    final bytesPerSecond = downloaded / elapsed.inSeconds;
    final remainingBytes = total - downloaded;
    final remainingSeconds = (remainingBytes / bytesPerSecond).round();
    
    if (remainingSeconds < 60) return '${remainingSeconds}초';
    if (remainingSeconds < 3600) return '${(remainingSeconds / 60).round()}분';
    return '${(remainingSeconds / 3600).round()}시간';
  }
}