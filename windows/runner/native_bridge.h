#ifndef NATIVE_BRIDGE_H
#define NATIVE_BRIDGE_H

#include <stdint.h>

/**
 * Windows용 llama.cpp 네이티브 브리지
 * Dart FFI에서 호출할 C 함수들을 제공합니다.
 */

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

/**
 * llama.cpp 백엔드 초기화
 * @return 성공 시 1, 실패 시 0
 */
EXPORT int64_t initialize_llama_windows(void);

/**
 * GGUF 모델 파일 로드
 * @param model_path 모델 파일 경로
 * @return 모델 핸들 (성공 시), 0 (실패 시)
 */
EXPORT int64_t load_model_windows(const char* model_path);

/**
 * 텍스트 생성
 * @param prompt 입력 프롬프트
 * @param max_tokens 최대 생성 토큰 수
 * @return 생성된 텍스트 (호출자가 free해야 함)
 */
EXPORT char* generate_text_windows(const char* prompt, int max_tokens);

/**
 * 모델 정보 조회
 * @return 모델 정보 문자열 (호출자가 free해야 함)
 */
EXPORT char* get_model_info_windows(void);

/**
 * 리소스 정리
 */
EXPORT void cleanup_windows(void);

/**
 * 메모리 해제 (generate_text_windows, get_model_info_windows 결과용)
 */
EXPORT void free_string_windows(char* str);

#ifdef __cplusplus
}
#endif

#endif /* NATIVE_BRIDGE_H */