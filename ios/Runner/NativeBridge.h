#ifndef NativeBridge_h
#define NativeBridge_h

#import <Foundation/Foundation.h>

/**
 * iOS용 llama.cpp 네이티브 브리지
 * Dart FFI에서 호출할 C 함수들을 제공합니다.
 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * llama.cpp 백엔드 초기화
 * @return 성공 시 1, 실패 시 0
 */
int64_t initialize_llama_ios(void);

/**
 * GGUF 모델 파일 로드
 * @param model_path 모델 파일 경로
 * @return 모델 핸들 (성공 시), 0 (실패 시)
 */
int64_t load_model_ios(const char* model_path);

/**
 * 텍스트 생성
 * @param prompt 입력 프롬프트
 * @param max_tokens 최대 생성 토큰 수
 * @return 생성된 텍스트 (호출자가 free해야 함)
 */
char* generate_text_ios(const char* prompt, int max_tokens);

/**
 * 모델 정보 조회
 * @return 모델 정보 문자열 (호출자가 free해야 함)
 */
char* get_model_info_ios(void);

/**
 * 리소스 정리
 */
void cleanup_ios(void);

/**
 * 메모리 해제 (generate_text_ios, get_model_info_ios 결과용)
 */
void free_string_ios(char* str);

#ifdef __cplusplus
}
#endif

#endif /* NativeBridge_h */