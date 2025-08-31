#include <jni.h>
#include <android/log.h>
#include <string>

#define LOG_TAG "OurSecretBase_Native"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" {

// 네이티브 라이브러리 초기화 (시뮬레이션)
JNIEXPORT jlong JNICALL
Java_com_example_our_1secret_1base_NativeBridge_initializeLlama(JNIEnv *env, jobject thiz) {
    LOGI("Initializing native library (simulation mode)...");
    return 1; // 성공 반환
}

// 모델 로드 (시뮬레이션)
JNIEXPORT jlong JNICALL
Java_com_example_our_1secret_1base_NativeBridge_loadModel(JNIEnv *env, jobject thiz, jstring model_path) {
    const char* path = env->GetStringUTFChars(model_path, nullptr);
    LOGI("Loading model from: %s (simulation mode)", path);
    
    env->ReleaseStringUTFChars(model_path, path);
    return 1; // 성공 반환
}

// 텍스트 생성 (시뮬레이션)
JNIEXPORT jstring JNICALL
Java_com_example_our_1secret_1base_NativeBridge_generateText(JNIEnv *env, jobject thiz, 
                                                            jstring prompt, jint max_tokens) {
    const char* input_text = env->GetStringUTFChars(prompt, nullptr);
    LOGI("Generating text for prompt: %s (simulation mode)", input_text);
    
    // 시뮬레이션 응답 생성
    std::string response = "🤖 네이티브 시뮬레이션 응답: ";
    response += input_text;
    response += " (FFI 연동 성공!)";
    
    env->ReleaseStringUTFChars(prompt, input_text);
    return env->NewStringUTF(response.c_str());
}

// 리소스 정리 (시뮬레이션)
JNIEXPORT void JNICALL
Java_com_example_our_1secret_1base_NativeBridge_cleanup(JNIEnv *env, jobject thiz) {
    LOGI("Cleaning up resources (simulation mode)...");
}

// 모델 정보 (시뮬레이션)
JNIEXPORT jstring JNICALL
Java_com_example_our_1secret_1base_NativeBridge_getModelInfo(JNIEnv *env, jobject thiz) {
    return env->NewStringUTF("Simulation Mode\nNo real model loaded\nFFI connection: OK");
}

} // extern "C"