import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'platform_utils.dart';

/// llama.cpp 네이티브 라이브러리와의 FFI 바인딩
class NativeBindings {
  static NativeBindings? _instance;
  static NativeBindings get instance => _instance ??= NativeBindings._();
  
  NativeBindings._();
  
  DynamicLibrary? _lib;
  bool _isInitialized = false;
  
  // 네이티브 함수 포인터들
  late final int Function() _initializeLlama;
  late final int Function(Pointer<Utf8>) _loadModel;
  late final Pointer<Utf8> Function(Pointer<Utf8>, int) _generateText;
  late final Pointer<Utf8> Function() _getModelInfo;
  late final void Function() _cleanup;
  late final void Function(Pointer<Utf8>) _freeString;
  
  /// FFI 바인딩 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _lib = _loadNativeLibrary();
      if (_lib == null) {
        print('네이티브 라이브러리 로드 실패');
        return false;
      }
      
      _bindNativeFunctions();
      _isInitialized = true;
      
      print('FFI 바인딩 초기화 완료');
      return true;
    } catch (e) {
      print('FFI 바인딩 초기화 실패: $e');
      return false;
    }
  }
  
  /// 플랫폼별 네이티브 라이브러리 로드
  DynamicLibrary? _loadNativeLibrary() {
    try {
      final libraryPath = PlatformUtils.getNativeLibraryPath();
      print('네이티브 라이브러리 로드 시도: $libraryPath');
      
      if (Platform.isIOS) {
        // iOS에서는 정적 링크된 라이브러리 사용
        return DynamicLibrary.process();
      } else {
        return DynamicLibrary.open(libraryPath);
      }
    } catch (e) {
      print('네이티브 라이브러리 로드 실패: $e');
      print('플랫폼: ${Platform.operatingSystem}');
      print('성능 프로파일: ${PlatformUtils.getPerformanceProfile()}');
      return null;
    }
  }
  
  /// 네이티브 함수들을 Dart 함수로 바인딩
  void _bindNativeFunctions() {
    if (_lib == null) throw Exception('라이브러리가 로드되지 않았습니다');
    
    // 플랫폼별 함수명 결정
    String suffix = '';
    if (Platform.isAndroid) {
      // Android는 JNI를 통해 호출하므로 별도 처리 필요
      _bindAndroidFunctions();
      return;
    } else if (Platform.isIOS) {
      suffix = '_ios';
    } else if (Platform.isWindows) {
      suffix = '_windows';
    }
    
    // 함수 바인딩
    _initializeLlama = _lib!
        .lookup<NativeFunction<Int64 Function()>>('initialize_llama$suffix')
        .asFunction();
    
    _loadModel = _lib!
        .lookup<NativeFunction<Int64 Function(Pointer<Utf8>)>>('load_model$suffix')
        .asFunction();
    
    _generateText = _lib!
        .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>, Int32)>>('generate_text$suffix')
        .asFunction();
    
    _getModelInfo = _lib!
        .lookup<NativeFunction<Pointer<Utf8> Function()>>('get_model_info$suffix')
        .asFunction();
    
    _cleanup = _lib!
        .lookup<NativeFunction<Void Function()>>('cleanup$suffix')
        .asFunction();
    
    _freeString = _lib!
        .lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('free_string$suffix')
        .asFunction();
  }
  
  /// Android 전용 함수 바인딩 (JNI 통합 필요)
  void _bindAndroidFunctions() {
    // Android에서는 JNI를 통해 호출해야 하므로
    // 향후 구현에서는 MethodChannel을 사용하거나
    // 직접 JNI 바인딩을 구현해야 함
    
    throw UnsupportedError('Android FFI 바인딩은 아직 구현되지 않았습니다');
  }
  
  /// llama.cpp 백엔드 초기화
  Future<bool> initializeLlama() async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return false;
    }
    
    try {
      final result = _initializeLlama();
      return result > 0;
    } catch (e) {
      print('llama.cpp 초기화 실패: $e');
      return false;
    }
  }
  
  /// 모델 파일 로드
  Future<bool> loadModel(String modelPath) async {
    if (!_isInitialized) return false;
    
    try {
      final pathPtr = modelPath.toNativeUtf8();
      final result = _loadModel(pathPtr);
      malloc.free(pathPtr);
      
      return result > 0;
    } catch (e) {
      print('모델 로드 실패: $e');
      return false;
    }
  }
  
  /// 텍스트 생성
  Future<String> generateText(String prompt, {int maxTokens = 100}) async {
    if (!_isInitialized) return 'FFI가 초기화되지 않았습니다';
    
    try {
      final promptPtr = prompt.toNativeUtf8();
      final resultPtr = _generateText(promptPtr, maxTokens);
      
      final result = resultPtr.toDartString();
      
      // 메모리 해제
      malloc.free(promptPtr);
      _freeString(resultPtr);
      
      return result;
    } catch (e) {
      print('텍스트 생성 실패: $e');
      return '텍스트 생성 중 오류가 발생했습니다: $e';
    }
  }
  
  /// 모델 정보 조회
  Future<String> getModelInfo() async {
    if (!_isInitialized) return 'FFI가 초기화되지 않았습니다';
    
    try {
      final resultPtr = _getModelInfo();
      final result = resultPtr.toDartString();
      
      _freeString(resultPtr);
      
      return result;
    } catch (e) {
      print('모델 정보 조회 실패: $e');
      return '모델 정보 조회 중 오류가 발생했습니다: $e';
    }
  }
  
  /// 리소스 정리
  void dispose() {
    if (!_isInitialized) return;
    
    try {
      _cleanup();
      _isInitialized = false;
      _lib = null;
      print('FFI 리소스 정리 완료');
    } catch (e) {
      print('FFI 리소스 정리 실패: $e');
    }
  }
  
  /// 현재 플랫폼 정보
  String get platformInfo {
    return '${Platform.operatingSystem} (${Platform.operatingSystemVersion})';
  }
  
  /// FFI 사용 가능 여부
  bool get isFFISupported {
    return _lib != null;
  }
}