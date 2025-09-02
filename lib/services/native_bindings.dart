import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// llama.cpp C 함수 시그니처 정의 (libllama.so에서 직접 호출)
typedef LlamaBackendInitC = Void Function();
typedef LlamaBackendInitDart = void Function();

typedef LlamaModelDefaultParamsC = Pointer Function();
typedef LlamaModelDefaultParamsDart = Pointer Function();

typedef LlamaContextDefaultParamsC = Pointer Function();
typedef LlamaContextDefaultParamsDart = Pointer Function();

typedef LlamaModelLoadFromFileC = Pointer Function(Pointer<Utf8> path, Pointer params);
typedef LlamaModelLoadFromFileDart = Pointer Function(Pointer<Utf8> path, Pointer params);

typedef LlamaInitFromModelC = Pointer Function(Pointer model, Pointer params);
typedef LlamaInitFromModelDart = Pointer Function(Pointer model, Pointer params);

typedef LlamaTokenizeC = Int32 Function(Pointer vocab, Pointer<Utf8> text, Int32 textLen, Pointer<Int32> tokens, Int32 nMaxTokens, Bool addBos, Bool special);
typedef LlamaTokenizeDart = int Function(Pointer vocab, Pointer<Utf8> text, int textLen, Pointer<Int32> tokens, int nMaxTokens, bool addBos, bool special);

typedef LlamaVocabGetTextC = Pointer<Utf8> Function(Pointer vocab, Int32 token);
typedef LlamaVocabGetTextDart = Pointer<Utf8> Function(Pointer vocab, int token);

typedef LlamaFreeC = Void Function(Pointer ctx);
typedef LlamaFreeDart = void Function(Pointer ctx);

typedef LlamaModelFreeC = Void Function(Pointer model);
typedef LlamaModelFreeDart = void Function(Pointer model);

typedef LlamaModelDescC = Int32 Function(Pointer model, Pointer<Utf8> buf, Uint64 bufSize);
typedef LlamaModelDescDart = int Function(Pointer model, Pointer<Utf8> buf, int bufSize);

typedef LlamaModelGetVocabC = Pointer Function(Pointer model);
typedef LlamaModelGetVocabDart = Pointer Function(Pointer model);

/// llama.cpp 네이티브 라이브러리와의 FFI 바인딩
class NativeBindings {
  static NativeBindings? _instance;
  static NativeBindings get instance => _instance ??= NativeBindings._();
  
  NativeBindings._();
  
  DynamicLibrary? _lib;
  bool _isInitialized = false;
  Pointer? _model;
  Pointer? _context;
  
  // llama.cpp 함수 포인터들
  late LlamaBackendInitDart _llamaBackendInit;
  late LlamaModelDefaultParamsDart _llamaModelDefaultParams;
  late LlamaContextDefaultParamsDart _llamaContextDefaultParams;
  late LlamaModelLoadFromFileDart _llamaModelLoadFromFile;
  late LlamaInitFromModelDart _llamaInitFromModel;
  late LlamaTokenizeDart _llamaTokenize;
  late LlamaVocabGetTextDart _llamaVocabGetText;
  late LlamaFreeDart _llamaFree;
  late LlamaModelFreeDart _llamaModelFree;
  late LlamaModelDescDart _llamaModelDesc;
  late LlamaModelGetVocabDart _llamaModelGetVocab;
  
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
      
      // llama.cpp 백엔드 초기화
      _llamaBackendInit();
      
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
      if (Platform.isAndroid) {
        // Android에서 libllama.so 로드
        return DynamicLibrary.open('libllama.so');
      } else if (Platform.isIOS) {
        // iOS에서는 정적 링크된 라이브러리 사용
        return DynamicLibrary.process();
      } else {
        throw UnsupportedError('지원되지 않는 플랫폼: ${Platform.operatingSystem}');
      }
    } catch (e) {
      print('네이티브 라이브러리 로드 실패: $e');
      print('플랫폼: ${Platform.operatingSystem}');
      return null;
    }
  }
  
  /// 네이티브 함수들을 Dart 함수로 바인딩
  void _bindNativeFunctions() {
    if (_lib == null) throw Exception('라이브러리가 로드되지 않았습니다');
    
    try {
      // llama.cpp 함수들 바인딩
      _llamaBackendInit = _lib!
          .lookup<NativeFunction<LlamaBackendInitC>>('llama_backend_init')
          .asFunction();
      
      _llamaModelDefaultParams = _lib!
          .lookup<NativeFunction<LlamaModelDefaultParamsC>>('llama_model_default_params')
          .asFunction();
      
      _llamaContextDefaultParams = _lib!
          .lookup<NativeFunction<LlamaContextDefaultParamsC>>('llama_context_default_params')
          .asFunction();
      
      _llamaModelLoadFromFile = _lib!
          .lookup<NativeFunction<LlamaModelLoadFromFileC>>('llama_model_load_from_file')
          .asFunction();
      
      _llamaInitFromModel = _lib!
          .lookup<NativeFunction<LlamaInitFromModelC>>('llama_init_from_model')
          .asFunction();
      
      _llamaTokenize = _lib!
          .lookup<NativeFunction<LlamaTokenizeC>>('llama_tokenize')
          .asFunction();
      
      _llamaVocabGetText = _lib!
          .lookup<NativeFunction<LlamaVocabGetTextC>>('llama_vocab_get_text')
          .asFunction();
      
      _llamaFree = _lib!
          .lookup<NativeFunction<LlamaFreeC>>('llama_free')
          .asFunction();
      
      _llamaModelFree = _lib!
          .lookup<NativeFunction<LlamaModelFreeC>>('llama_model_free')
          .asFunction();
      
      _llamaModelDesc = _lib!
          .lookup<NativeFunction<LlamaModelDescC>>('llama_model_desc')
          .asFunction();
      
      _llamaModelGetVocab = _lib!
          .lookup<NativeFunction<LlamaModelGetVocabC>>('llama_model_get_vocab')
          .asFunction();
      
      print('llama.cpp 함수 바인딩 완료');
    } catch (e) {
      print('함수 바인딩 실패: $e');
      rethrow;
    }
  }
  
  /// llama.cpp 백엔드 초기화 (이미 initialize()에서 호출됨)
  Future<bool> initializeLlama() async {
    return _isInitialized;
  }
  
  /// 모델 파일 로드
  Future<bool> loadModel(String modelPath) async {
    if (!_isInitialized) return false;
    
    try {
      // 기존 모델/컨텍스트 정리
      _cleanup();
      
      // 모델 파라미터 가져오기
      final modelParams = _llamaModelDefaultParams();
      
      // 모델 로드
      final pathPtr = modelPath.toNativeUtf8();
      _model = _llamaModelLoadFromFile(pathPtr, modelParams);
      malloc.free(pathPtr);
      
      if (_model == nullptr) {
        print('모델 로드 실패: $_model');
        return false;
      }
      
      // 컨텍스트 파라미터 가져오기
      final contextParams = _llamaContextDefaultParams();
      
      // 컨텍스트 초기화
      _context = _llamaInitFromModel(_model!, contextParams);
      
      if (_context == nullptr) {
        print('컨텍스트 초기화 실패');
        _llamaModelFree(_model!);
        _model = null;
        return false;
      }
      
      print('모델 로드 성공: $modelPath');
      return true;
    } catch (e) {
      print('모델 로드 실패: $e');
      return false;
    }
  }
  
  /// 텍스트 생성 (간단한 구현)
  Future<String> generateText(String prompt, {int maxTokens = 100}) async {
    if (!_isInitialized || _model == null || _context == null) {
      return 'FFI가 초기화되지 않았거나 모델이 로드되지 않았습니다';
    }
    
    try {
      // vocab 가져오기
      final vocab = _llamaModelGetVocab(_model!);
      if (vocab == nullptr) {
        return 'vocab을 가져올 수 없습니다';
      }
      
      // 프롬프트 토큰화
      final promptPtr = prompt.toNativeUtf8();
      final tokens = malloc<Int32>(1024); // 최대 1024 토큰
      
      final tokenCount = _llamaTokenize(
        vocab,
        promptPtr,
        prompt.length,
        tokens,
        1024,
        true, // add_bos
        false, // special
      );
      
      if (tokenCount < 0) {
        malloc.free(promptPtr);
        malloc.free(tokens);
        return '토큰화 실패';
      }
      
      // 간단한 응답 생성 (실제로는 더 복잡한 추론 과정이 필요)
      final response = StringBuffer();
      response.write('안녕하세요! ');
      response.write(prompt.length > 10 ? '긴 질문' : '짧은 질문');
      response.write('에 대한 답변입니다. ');
      response.write('현재는 간단한 테스트 응답을 제공하고 있습니다.');
      
      // 메모리 해제
      malloc.free(promptPtr);
      malloc.free(tokens);
      
      return response.toString();
    } catch (e) {
      print('텍스트 생성 실패: $e');
      return '텍스트 생성 중 오류가 발생했습니다: $e';
    }
  }
  
  /// 모델 정보 조회
  Future<String> getModelInfo() async {
    if (!_isInitialized) return 'FFI가 초기화되지 않았습니다';
    if (_model == null) return '모델이 로드되지 않았습니다';
    
    try {
      // 모델 설명 가져오기
      final buffer = malloc<Uint8>(1024);
      final result = _llamaModelDesc(_model!, buffer.cast<Utf8>(), 1024);
      
      String modelDesc = 'llama.cpp 모델 로드됨';
      if (result > 0) {
        modelDesc = buffer.cast<Utf8>().toDartString();
      }
      
      malloc.free(buffer);
      return modelDesc;
    } catch (e) {
      print('모델 정보 조회 실패: $e');
      return 'llama.cpp 모델이 성공적으로 로드되었습니다.';
    }
  }
  
  /// 내부 정리 함수
  void _cleanup() {
    if (_context != null) {
      _llamaFree(_context!);
      _context = null;
    }
    if (_model != null) {
      _llamaModelFree(_model!);
      _model = null;
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