#include <jni.h>
#include <android/log.h>
#include <string>
#include <memory>
#include <mutex>
#include "llama.h"

#define LOG_TAG "OurSecretBase_Native"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// 전역 변수들
static std::unique_ptr<llama_model> g_model = nullptr;
static std::unique_ptr<llama_context> g_context = nullptr;
static std::mutex g_mutex;

extern "C" {

// JNI 함수들
JNIEXPORT jlong JNICALL
Java_com_example_our_1secret_1base_NativeBridge_initializeLlama(JNIEnv *env, jobject thiz) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    LOGI("Initializing llama.cpp...");
    
    // llama.cpp 백엔드 초기화
    llama_backend_init();
    
    LOGI("llama.cpp initialized successfully");
    return reinterpret_cast<jlong>(1); // 성공 시 1 반환
}

JNIEXPORT jlong JNICALL
Java_com_example_our_1secret_1base_NativeBridge_loadModel(JNIEnv *env, jobject thiz, jstring model_path) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    const char* path = env->GetStringUTFChars(model_path, nullptr);
    LOGI("Loading model from: %s", path);
    
    try {
        // 모델 파라미터 설정
        llama_model_params model_params = llama_model_default_params();
        model_params.n_gpu_layers = 0; // CPU 전용
        model_params.use_mmap = true;
        model_params.use_mlock = false;
        
        // 모델 로드
        g_model.reset(llama_load_model_from_file(path, model_params));
        
        if (!g_model) {
            LOGE("Failed to load model from: %s", path);
            env->ReleaseStringUTFChars(model_path, path);
            return 0;
        }
        
        // 컨텍스트 파라미터 설정
        llama_context_params ctx_params = llama_context_default_params();
        ctx_params.n_ctx = 2048; // 컨텍스트 크기
        ctx_params.n_batch = 512; // 배치 크기
        ctx_params.n_threads = 4; // 스레드 수
        ctx_params.seed = -1; // 랜덤 시드
        
        // 컨텍스트 생성
        g_context.reset(llama_new_context_with_model(g_model.get(), ctx_params));
        
        if (!g_context) {
            LOGE("Failed to create context");
            g_model.reset();
            env->ReleaseStringUTFChars(model_path, path);
            return 0;
        }
        
        LOGI("Model loaded successfully");
        env->ReleaseStringUTFChars(model_path, path);
        return reinterpret_cast<jlong>(g_model.get());
        
    } catch (const std::exception& e) {
        LOGE("Exception while loading model: %s", e.what());
        env->ReleaseStringUTFChars(model_path, path);
        return 0;
    }
}

JNIEXPORT jstring JNICALL
Java_com_example_our_1secret_1base_NativeBridge_generateText(JNIEnv *env, jobject thiz, 
                                                            jstring prompt, jint max_tokens) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (!g_model || !g_context) {
        LOGE("Model or context not initialized");
        return env->NewStringUTF("Error: Model not loaded");
    }
    
    const char* input_text = env->GetStringUTFChars(prompt, nullptr);
    LOGI("Generating text for prompt: %s", input_text);
    
    try {
        // 프롬프트 토크나이징
        std::vector<llama_token> tokens;
        const int n_prompt_tokens = llama_tokenize(g_model.get(), input_text, strlen(input_text), 
                                                  nullptr, 0, true, true);
        
        tokens.resize(n_prompt_tokens);
        llama_tokenize(g_model.get(), input_text, strlen(input_text), 
                      tokens.data(), tokens.size(), true, true);
        
        // 배치 준비
        llama_batch batch = llama_batch_init(tokens.size(), 0, 1);
        
        for (size_t i = 0; i < tokens.size(); i++) {
            llama_batch_add(batch, tokens[i], i, {0}, false);
        }
        
        // 마지막 토큰만 로짓 생성
        batch.logits[batch.n_tokens - 1] = true;
        
        // 추론 실행
        if (llama_decode(g_context.get(), batch) != 0) {
            LOGE("Failed to decode batch");
            llama_batch_free(batch);
            env->ReleaseStringUTFChars(prompt, input_text);
            return env->NewStringUTF("Error: Failed to decode");
        }
        
        std::string result;
        
        // 텍스트 생성 루프
        for (int i = 0; i < max_tokens; i++) {
            // 로짓 가져오기
            float* logits = llama_get_logits_ith(g_context.get(), batch.n_tokens - 1);
            
            // 간단한 그리디 샘플링
            llama_token next_token = 0;
            float max_logit = logits[0];
            
            const int n_vocab = llama_n_vocab(g_model.get());
            for (int j = 1; j < n_vocab; j++) {
                if (logits[j] > max_logit) {
                    max_logit = logits[j];
                    next_token = j;
                }
            }
            
            // EOS 토큰 체크
            if (llama_token_is_eog(g_model.get(), next_token)) {
                break;
            }
            
            // 토큰을 텍스트로 변환
            char token_str[256];
            int token_len = llama_token_to_piece(g_model.get(), next_token, token_str, sizeof(token_str), 0, true);
            
            if (token_len > 0) {
                result.append(token_str, token_len);
            }
            
            // 다음 토큰으로 배치 업데이트
            llama_batch_clear(batch);
            llama_batch_add(batch, next_token, tokens.size() + i, {0}, true);
            
            if (llama_decode(g_context.get(), batch) != 0) {
                LOGE("Failed to decode next token");
                break;
            }
        }
        
        llama_batch_free(batch);
        env->ReleaseStringUTFChars(prompt, input_text);
        
        LOGI("Generated text: %s", result.c_str());
        return env->NewStringUTF(result.c_str());
        
    } catch (const std::exception& e) {
        LOGE("Exception during text generation: %s", e.what());
        env->ReleaseStringUTFChars(prompt, input_text);
        return env->NewStringUTF("Error: Exception occurred");
    }
}

JNIEXPORT void JNICALL
Java_com_example_our_1secret_1base_NativeBridge_cleanup(JNIEnv *env, jobject thiz) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    LOGI("Cleaning up llama.cpp resources...");
    
    g_context.reset();
    g_model.reset();
    
    llama_backend_free();
    
    LOGI("Cleanup completed");
}

JNIEXPORT jstring JNICALL
Java_com_example_our_1secret_1base_NativeBridge_getModelInfo(JNIEnv *env, jobject thiz) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (!g_model) {
        return env->NewStringUTF("No model loaded");
    }
    
    // 모델 정보 수집
    const int n_vocab = llama_n_vocab(g_model.get());
    const int n_ctx_train = llama_n_ctx_train(g_model.get());
    const int n_embd = llama_n_embd(g_model.get());
    
    char info[512];
    snprintf(info, sizeof(info), 
             "Vocabulary size: %d\nTraining context: %d\nEmbedding size: %d", 
             n_vocab, n_ctx_train, n_embd);
    
    return env->NewStringUTF(info);
}

} // extern "C"