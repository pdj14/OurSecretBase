package com.example.our_secret_base

import android.util.Log

/**
 * llama.cpp와의 JNI 브리지 클래스
 * Dart FFI에서 호출할 네이티브 함수들을 제공합니다.
 */
class NativeBridge {
    
    companion object {
        private const val TAG = "NativeBridge"
        
        // 네이티브 라이브러리 로드
        init {
            try {
                System.loadLibrary("our_secret_base_native")
                Log.i(TAG, "Native library loaded successfully")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "Failed to load native library", e)
            }
        }
        
        // 싱글톤 인스턴스
        @JvmStatic
        val instance = NativeBridge()
    }
    
    /**
     * llama.cpp 백엔드 초기화
     * @return 성공 시 1, 실패 시 0
     */
    external fun initializeLlama(): Long
    
    /**
     * GGUF 모델 파일 로드
     * @param modelPath 모델 파일 경로
     * @return 모델 핸들 (성공 시), 0 (실패 시)
     */
    external fun loadModel(modelPath: String): Long
    
    /**
     * 텍스트 생성
     * @param prompt 입력 프롬프트
     * @param maxTokens 최대 생성 토큰 수
     * @return 생성된 텍스트
     */
    external fun generateText(prompt: String, maxTokens: Int): String
    
    /**
     * 모델 정보 조회
     * @return 모델 정보 문자열
     */
    external fun getModelInfo(): String
    
    /**
     * 리소스 정리
     */
    external fun cleanup()
    
    // Kotlin 래퍼 함수들
    
    /**
     * 안전한 초기화 (예외 처리 포함)
     */
    fun safeInitialize(): Boolean {
        return try {
            val result = initializeLlama()
            Log.i(TAG, "Initialize result: $result")
            result > 0
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize llama.cpp", e)
            false
        }
    }
    
    /**
     * 안전한 모델 로드 (예외 처리 포함)
     */
    fun safeLoadModel(modelPath: String): Boolean {
        return try {
            val result = loadModel(modelPath)
            Log.i(TAG, "Load model result: $result for path: $modelPath")
            result > 0
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load model: $modelPath", e)
            false
        }
    }
    
    /**
     * 안전한 텍스트 생성 (예외 처리 포함)
     */
    fun safeGenerateText(prompt: String, maxTokens: Int = 100): String {
        return try {
            val result = generateText(prompt, maxTokens)
            Log.i(TAG, "Generated text length: ${result.length}")
            result
        } catch (e: Exception) {
            Log.e(TAG, "Failed to generate text for prompt: $prompt", e)
            "Error: Failed to generate text"
        }
    }
    
    /**
     * 안전한 모델 정보 조회 (예외 처리 포함)
     */
    fun safeGetModelInfo(): String {
        return try {
            getModelInfo()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get model info", e)
            "Error: Failed to get model info"
        }
    }
    
    /**
     * 안전한 리소스 정리 (예외 처리 포함)
     */
    fun safeCleanup() {
        try {
            cleanup()
            Log.i(TAG, "Cleanup completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cleanup resources", e)
        }
    }
}