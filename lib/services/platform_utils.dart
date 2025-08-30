import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// 플랫폼별 유틸리티 함수들
class PlatformUtils {
  
  /// 현재 플랫폼에서 사용할 네이티브 라이브러리 경로 반환
  static String getNativeLibraryPath() {
    if (kIsWeb) {
      throw UnsupportedError('웹에서는 네이티브 라이브러리를 사용할 수 없습니다');
    }
    
    if (Platform.isAndroid) {
      return 'libour_secret_base_native.so';
    } else if (Platform.isIOS) {
      // iOS에서는 프로세스 내에 정적으로 링크됨
      return '';
    } else if (Platform.isWindows) {
      return 'our_secret_base_native.dll';
    } else if (Platform.isLinux) {
      return 'libour_secret_base_native.so';
    } else if (Platform.isMacOS) {
      return 'libour_secret_base_native.dylib';
    }
    
    throw UnsupportedError('지원되지 않는 플랫폼: ${Platform.operatingSystem}');
  }
  
  /// 모델 파일을 앱의 문서 디렉토리로 복사
  static Future<String> copyModelToDocuments() async {
    if (kIsWeb) {
      // 웹에서는 assets에서 직접 사용
      return 'assets://model/gemma3-270m-it-q4_k_m.gguf';
    }
    
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final modelFile = File(path.join(documentsDir.path, 'gemma3-270m-it-q4_k_m.gguf'));
      
      if (!await modelFile.exists()) {
        print('모델 파일을 문서 디렉토리로 복사 중...');
        
        // assets에서 모델 파일 로드
        final byteData = await rootBundle.load('model/gemma3-270m-it-q4_k_m.gguf');
        final bytes = byteData.buffer.asUint8List();
        
        // 문서 디렉토리에 저장
        await modelFile.writeAsBytes(bytes);
        print('모델 파일 복사 완료: ${modelFile.path}');
      } else {
        print('모델 파일이 이미 존재함: ${modelFile.path}');
      }
      
      return modelFile.path;
    } catch (e) {
      print('모델 파일 복사 실패: $e');
      rethrow;
    }
  }
  
  /// 플랫폼별 최적화된 스레드 수 반환
  static int getOptimalThreadCount() {
    if (kIsWeb) return 1;
    
    // 기본적으로 CPU 코어 수의 절반 사용 (배터리 효율성 고려)
    final coreCount = Platform.numberOfProcessors;
    return (coreCount / 2).ceil().clamp(1, 8);
  }
  
  /// 플랫폼별 최적화된 컨텍스트 크기 반환
  static int getOptimalContextSize() {
    if (kIsWeb) return 512;
    
    if (Platform.isAndroid || Platform.isIOS) {
      // 모바일에서는 메모리 제약으로 작은 컨텍스트 사용
      return 1024;
    } else {
      // 데스크톱에서는 더 큰 컨텍스트 사용 가능
      return 2048;
    }
  }
  
  /// 플랫폼별 배치 크기 반환
  static int getOptimalBatchSize() {
    if (kIsWeb) return 128;
    
    if (Platform.isAndroid || Platform.isIOS) {
      return 256;
    } else {
      return 512;
    }
  }
  
  /// 현재 플랫폼의 메모리 정보 (추정치)
  static Map<String, dynamic> getMemoryInfo() {
    final info = <String, dynamic>{
      'platform': Platform.operatingSystem,
      'architecture': _getArchitecture(),
    };
    
    if (Platform.isAndroid || Platform.isIOS) {
      info['estimatedRAM'] = '4-8GB';
      info['recommendedModelSize'] = '< 500MB';
    } else {
      info['estimatedRAM'] = '8GB+';
      info['recommendedModelSize'] = '< 2GB';
    }
    
    return info;
  }
  
  /// CPU 아키텍처 추정
  static String _getArchitecture() {
    if (Platform.isAndroid) {
      // Android에서는 대부분 ARM64
      return 'ARM64 (추정)';
    } else if (Platform.isIOS) {
      return 'ARM64';
    } else if (Platform.isWindows) {
      return 'x86_64 (추정)';
    } else if (Platform.isMacOS) {
      return 'ARM64/x86_64';
    } else {
      return 'Unknown';
    }
  }
  
  /// 플랫폼별 성능 프로파일
  static Map<String, dynamic> getPerformanceProfile() {
    return {
      'threads': getOptimalThreadCount(),
      'contextSize': getOptimalContextSize(),
      'batchSize': getOptimalBatchSize(),
      'memoryInfo': getMemoryInfo(),
      'nativeLibrary': getNativeLibraryPath(),
    };
  }
}