import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';

// llama.cpp 구조체 정의 (간단한 버전)
final class LlamaModelParams extends Struct {
  external Pointer devices;
  external Pointer tensorBuftOverrides;
  @Int32()
  external int nGpuLayers;
  @Int32()
  external int splitMode;
  @Int32()
  external int mainGpu;
  external Pointer tensorSplit;
  external Pointer progressCallback;
  external Pointer progressCallbackUserData;
  external Pointer kvOverrides;
  @Int8()
  external int vocabOnly;
  @Int8()
  external int useMemoryMapping;
  @Int8()
  external int useMemoryLocking;
  @Int8()
  external int checkTensors;
  @Int8()
  external int useExtraBufts;
}

// llama_batch 구조체 정의 (정확한 C 구조체와 일치)
final class LlamaBatch extends Struct {
  @Int32() external int nTokens;           // int32_t n_tokens
  external Pointer<Int32> token;           // llama_token * token
  external Pointer<Float> embd;            // float * embd
  external Pointer<Int32> pos;             // llama_pos * pos
  external Pointer<Int32> nSeqId;          // int32_t * n_seq_id
  external Pointer<Pointer<Int32>> seqId;  // llama_seq_id ** seq_id
  external Pointer<Int8> logits;           // int8_t * logits
}

// llama_candidates 구조체 정의
final class LlamaCandidates extends Struct {
  @Int32() external int nCandidates;       // int32_t n_candidates
  external Pointer<Int32> token;           // llama_token * token
  external Pointer<Float> logit;           // float * logit
  external Pointer<Float> p;               // float * p
  external Pointer<Float> logitRescored;   // float * logit_rescored
  external Pointer<Float> pRescored;       // float * p_rescored
  external Pointer<Int8> logits;           // int8_t * logits
  external Pointer<Int8> allLogits;        // int8_t all_logits
}

// llama_context_params 구조체 정의 (실제 C 구조체와 일치)
final class LlamaContextParams extends Struct {
  @Uint32()
  external int nCtx;                    // uint32_t n_ctx
  @Uint32()
  external int nBatch;                  // uint32_t n_batch
  @Uint32()
  external int nUbatch;                 // uint32_t n_ubatch
  @Uint32()
  external int nSeqMax;                 // uint32_t n_seq_max
  @Int32()
  external int nThreads;                // int32_t n_threads
  @Int32()
  external int nThreadsBatch;           // int32_t n_threads_batch
  
  @Int32()
  external int ropeScalingType;         // enum llama_rope_scaling_type rope_scaling_type
  @Int32()
  external int poolingType;             // enum llama_pooling_type pooling_type
  @Int32()
  external int attentionType;           // enum llama_attention_type attention_type
  @Int32()
  external int flashAttnType;           // enum llama_flash_attn_type flash_attn_type
  
  @Float()
  external double ropeFreqBase;         // float rope_freq_base
  @Float()
  external double ropeFreqScale;        // float rope_freq_scale
  @Float()
  external double yarnExtFactor;        // float yarn_ext_factor
  @Float()
  external double yarnAttnFactor;       // float yarn_attn_factor
  @Float()
  external double yarnBetaFast;         // float yarn_beta_fast
  @Float()
  external double yarnBetaSlow;         // float yarn_beta_slow
  @Uint32()
  external int yarnOrigCtx;             // uint32_t yarn_orig_ctx
  @Float()
  external double defragThold;          // float defrag_thold
  
  external Pointer cbEval;              // ggml_backend_sched_eval_callback cb_eval
  external Pointer cbEvalUserData;      // void * cb_eval_user_data
  
  @Int32()
  external int typeK;                   // enum ggml_type type_k
  @Int32()
  external int typeV;                   // enum ggml_type type_v
  
  external Pointer abortCallback;       // ggml_abort_callback abort_callback
  external Pointer abortCallbackData;   // void * abort_callback_data
  
  @Int8()
  external int embeddings;              // bool embeddings
  @Int8()
  external int offloadKqv;              // bool offload_kqv
  @Int8()
  external int noPerf;                  // bool no_perf
  @Int8()
  external int opOffload;               // bool op_offload
  @Int8()
  external int swaFull;                 // bool swa_full
  @Int8()
  external int kvUnified;               // bool kv_unified
}

// llama.cpp C 함수 시그니처 정의 (libllama.so에서 직접 호출)
typedef LlamaBackendInitC = Void Function();
typedef LlamaBackendInitDart = void Function();

typedef LlamaModelDefaultParamsC = LlamaModelParams Function();
typedef LlamaModelDefaultParamsDart = LlamaModelParams Function();

typedef LlamaContextDefaultParamsC = LlamaContextParams Function();
typedef LlamaContextDefaultParamsDart = LlamaContextParams Function();

typedef LlamaModelLoadFromFileC = Pointer Function(Pointer<Utf8> path, LlamaModelParams params);
typedef LlamaModelLoadFromFileDart = Pointer Function(Pointer<Utf8> path, LlamaModelParams params);

typedef LlamaInitFromModelC = Pointer Function(Pointer model, LlamaContextParams params);
typedef LlamaInitFromModelDart = Pointer Function(Pointer model, LlamaContextParams params);

typedef LlamaTokenizeC = Int32 Function(Pointer vocab, Pointer<Utf8> text, Int32 textLen, Pointer<Int32> tokens, Int32 nMaxTokens, Bool addBos, Bool special);
typedef LlamaTokenizeDart = int Function(Pointer vocab, Pointer<Utf8> text, int textLen, Pointer<Int32> tokens, int nMaxTokens, bool addBos, bool special);

typedef LlamaVocabGetTextC = Pointer<Utf8> Function(Pointer vocab, Int32 token);
typedef LlamaVocabGetTextDart = Pointer<Utf8> Function(Pointer vocab, int token);

typedef LlamaFreeC = Void Function(Pointer ctx);
typedef LlamaFreeDart = void Function(Pointer ctx);

typedef LlamaModelFreeC = Void Function(Pointer model);
typedef LlamaModelFreeDart = void Function(Pointer model);

typedef LlamaModelDescC = Int32 Function(Pointer model, Pointer<Utf8> buf, IntPtr bufSize);
typedef LlamaModelDescDart = int Function(Pointer model, Pointer<Utf8> buf, int bufSize);

typedef LlamaModelGetVocabC = Pointer Function(Pointer model);
typedef LlamaModelGetVocabDart = Pointer Function(Pointer model);

// 실제 추론을 위한 추가 함수들
typedef LlamaDecodeC = Int32 Function(Pointer ctx, LlamaBatch batch);
typedef LlamaDecodeDart = int Function(Pointer ctx, LlamaBatch batch);

typedef LlamaBatchInitC = LlamaBatch Function(Int32 nTokens, Int32 embd, Int32 nSeqMax);
typedef LlamaBatchInitDart = LlamaBatch Function(int nTokens, int embd, int nSeqMax);

typedef LlamaBatchGetOneC = LlamaBatch Function(Pointer<Int32> tokens, Int32 nTokens);
typedef LlamaBatchGetOneDart = LlamaBatch Function(Pointer<Int32> tokens, int nTokens);

typedef LlamaBatchFreeC = Void Function(LlamaBatch batch);
typedef LlamaBatchFreeDart = void Function(LlamaBatch batch);

typedef LlamaSamplerInitC = Pointer Function(Pointer ctx);
typedef LlamaSamplerInitDart = Pointer Function(Pointer ctx);

typedef LlamaSamplerSampleC = Int32 Function(Pointer sampler, Pointer ctx, Int32 idx);
typedef LlamaSamplerSampleDart = int Function(Pointer sampler, Pointer ctx, int idx);

typedef LlamaSamplerFreeC = Void Function(Pointer sampler);
typedef LlamaSamplerFreeDart = void Function(Pointer sampler);

typedef LlamaGetLogitsIthC = Pointer<Float> Function(Pointer ctx, Int32 i);
typedef LlamaGetLogitsIthDart = Pointer<Float> Function(Pointer ctx, int i);

typedef LlamaGetLogitsC = Pointer<Float> Function(Pointer ctx);
typedef LlamaGetLogitsDart = Pointer<Float> Function(Pointer ctx);

typedef LlamaVocabNTokensC = Int32 Function(Pointer vocab);
typedef LlamaVocabNTokensDart = int Function(Pointer vocab);

typedef LlamaVocabIsEogC = Uint8 Function(Pointer vocab, Int32 token);
typedef LlamaVocabIsEogDart = int Function(Pointer vocab, int token);

typedef LlamaDetokenizeC = Int32 Function(Pointer vocab, Pointer<Int32> tokens, Int32 nTokens, Pointer<Utf8> text, Int32 textLenMax, Uint8 removeSpecial, Uint8 unparseSpecial);
typedef LlamaDetokenizeDart = int Function(Pointer vocab, Pointer<Int32> tokens, int nTokens, Pointer<Utf8> text, int textLenMax, int removeSpecial, int unparseSpecial);

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
  
  // 실제 추론을 위한 함수 포인터들
  late LlamaDecodeDart _llamaDecode;
  late LlamaBatchInitDart _llamaBatchInit;
  late LlamaBatchGetOneDart _llamaBatchGetOne;
  late LlamaBatchFreeDart _llamaBatchFree;
  late LlamaSamplerInitDart _llamaSamplerInit;
  late LlamaSamplerSampleDart _llamaSamplerSample;
  late LlamaSamplerFreeDart _llamaSamplerFree;
  late LlamaGetLogitsIthDart _llamaGetLogitsIth;
  late LlamaGetLogitsDart _llamaGetLogits;
  late LlamaVocabNTokensDart _llamaVocabNTokens;
  late LlamaVocabIsEogDart _llamaVocabIsEog;
  late LlamaDetokenizeDart _llamaDetokenize;
  
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
      
      // llama.cpp 백엔드 초기화 (안전하게)
      try {
        _llamaBackendInit();
        print('llama.cpp 백엔드 초기화 성공');
      } catch (e) {
        print('llama.cpp 백엔드 초기화 실패: $e');
        return false;
      }
      
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
      
      // 실제 추론을 위한 함수들 바인딩
      _llamaDecode = _lib!
          .lookup<NativeFunction<LlamaDecodeC>>('llama_decode')
          .asFunction();
      
      _llamaBatchInit = _lib!
          .lookup<NativeFunction<LlamaBatchInitC>>('llama_batch_init')
          .asFunction();
      
      _llamaBatchGetOne = _lib!
          .lookup<NativeFunction<LlamaBatchGetOneC>>('llama_batch_get_one')
          .asFunction();
      
      _llamaBatchFree = _lib!
          .lookup<NativeFunction<LlamaBatchFreeC>>('llama_batch_free')
          .asFunction();
      
      _llamaSamplerInit = _lib!
          .lookup<NativeFunction<LlamaSamplerInitC>>('llama_sampler_init')
          .asFunction();
      
      _llamaSamplerSample = _lib!
          .lookup<NativeFunction<LlamaSamplerSampleC>>('llama_sampler_sample')
          .asFunction();
      
      _llamaSamplerFree = _lib!
          .lookup<NativeFunction<LlamaSamplerFreeC>>('llama_sampler_free')
          .asFunction();
      
      _llamaGetLogitsIth = _lib!
          .lookup<NativeFunction<LlamaGetLogitsIthC>>('llama_get_logits_ith')
          .asFunction();
      
      _llamaGetLogits = _lib!
          .lookup<NativeFunction<LlamaGetLogitsC>>('llama_get_logits')
          .asFunction();
      
      _llamaVocabNTokens = _lib!
          .lookup<NativeFunction<LlamaVocabNTokensC>>('llama_vocab_n_tokens')
          .asFunction();

      _llamaVocabIsEog = _lib!
          .lookup<NativeFunction<LlamaVocabIsEogC>>('llama_vocab_is_eog')
          .asFunction();

      _llamaDetokenize = _lib!
          .lookup<NativeFunction<LlamaDetokenizeC>>('llama_detokenize')
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
      
      // 모델 로드 (params를 by-value로 전달)
      final pathPtr = modelPath.toNativeUtf8();
      final modelParams = _llamaModelDefaultParams();
      _model = _llamaModelLoadFromFile(pathPtr, modelParams);
      malloc.free(pathPtr);
      
      if (_model == nullptr) {
        print('모델 로드 실패: $_model');
        return false;
      }
      
      // 컨텍스트 초기화 (params를 by-value로 전달)
      final contextParams = _llamaContextDefaultParams();
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
  
  /// 텍스트 생성 (greedy decoding)
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
      final tokens = malloc<Int32>(512); // 최대 512 토큰
      
      final textLenBytes = utf8.encode(prompt).length;
      final tokenCount = _llamaTokenize(
        vocab,
        promptPtr,
        textLenBytes,
        tokens,
        512,
        true, // add_bos
        false, // special
      );
      
      if (tokenCount < 0) {
        malloc.free(promptPtr);
        malloc.free(tokens);
        return '토큰화 실패';
      }
      
      // 실제 AI 추론 시도 (llama_batch_get_one 사용 - 더 안전한 방법)
      String response;
      try {
        print('실제 AI 추론 시작 - llama_batch_get_one 사용');
        
        // 1. 안전한 토큰 처리 (메모리 오류 방지)
        print('안전한 토큰 처리 시작 (토큰 수: $tokenCount)');
        
        // 4. 안전한 토큰 처리 (메모리 오류 방지)
        bool allTokensProcessed = true;
        int lastDecodeResult = 0;
        
        // 프롬프트 배치: helper 사용 (llama_batch_get_one)
        print('프롬프트 배치 구성 시작 (get_one)...');
        final promptTokensPtr = malloc<Int32>(tokenCount);
        for (int i = 0; i < tokenCount; i++) {
          promptTokensPtr[i] = tokens[i];
        }
        final promptBatch = _llamaBatchGetOne(promptTokensPtr, tokenCount);
        if (promptBatch.logits != nullptr) {
          // 마지막 토큰만 logits 요청
          for (int i = 0; i < tokenCount; i++) {
            promptBatch.logits[i] = (i == tokenCount - 1) ? 1 : 0;
          }
        }
        print('llama_decode 호출 시작 (프롬프트)...');
        final decodeResult = _llamaDecode(_context!, promptBatch);
        malloc.free(promptTokensPtr);
        print('llama_decode 결과: $decodeResult');
        if (decodeResult != 0) {
          allTokensProcessed = false;
          lastDecodeResult = decodeResult;
        } else {
          allTokensProcessed = true;
        }
        
        print('모든 토큰 처리 시뮬레이션 완료');

        if (allTokensProcessed) {
          final vocab = _llamaModelGetVocab(_model!);
          final generated = <int>[];
          int steps = 0;

          while (steps < maxTokens) {
            final logitsPtr = _llamaGetLogitsIth(_context!, -1);
            if (logitsPtr == nullptr) {
              break;
            }

            final nVocab = _llamaVocabNTokens(vocab);
            int bestId = 0;
            double bestLogit = -double.maxFinite;
            for (int i = 0; i < nVocab; i++) {
              final v = logitsPtr.elementAt(i).value;
              if (v > bestLogit) {
                bestLogit = v.toDouble();
                bestId = i;
              }
            }

            if (_llamaVocabIsEog(vocab, bestId) != 0) {
              break;
            }

            generated.add(bestId);

            final oneToken = malloc<Int32>(1);
            oneToken[0] = bestId;
            final stepBatch = _llamaBatchGetOne(oneToken, 1);
            if (stepBatch.logits != nullptr) {
              stepBatch.logits[0] = 1;
            }
            final r = _llamaDecode(_context!, stepBatch);
            malloc.free(oneToken);
            if (r != 0) {
              break;
            }
            steps++;
          }

          // detokenize로 UTF-8 문자열 생성
          String detok = '';
          if (generated.isNotEmpty) {
            final genPtr = malloc<Int32>(generated.length);
            for (int i = 0; i < generated.length; i++) {
              genPtr[i] = generated[i];
            }
            final outBuf = malloc<Uint8>(8192);
            final wrote = _llamaDetokenize(
              vocab,
              genPtr,
              generated.length,
              outBuf.cast<Utf8>(),
              8192,
              1, // remove_special
              1, // unparse_special
            );
            if (wrote > 0) {
              detok = outBuf.cast<Utf8>().toDartString();
            }
            malloc.free(outBuf);
            malloc.free(genPtr);
          }
          response = detok.trim();
        } else {
          response = 'llama_decode 실패 (코드: $lastDecodeResult)';
        }
        
        print('AI 추론 완료: $response');
      } catch (e) {
        print('AI 추론 중 오류: $e');
        response = '죄송합니다. AI 추론 중 오류가 발생했습니다: $e';
      }
      
      // 메모리 해제
      malloc.free(promptPtr);
      malloc.free(tokens);
      
      return response;
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