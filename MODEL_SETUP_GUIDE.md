# AI 모델 설정 가이드

이 가이드는 우리들의아지트 앱에서 사용자가 직접 AI 모델을 선택하고 사용하는 방법을 설명합니다.

## 📁 모델 파일 배치

### Android
앱이 모델 파일을 찾는 폴더:
```
/storage/emulated/0/AiModels/
```

### iOS
```
Documents/AiModels/
```

## 🔧 설정 방법

### 1. 모델 파일 준비
- GGUF 형식의 모델 파일 (.gguf)
- 지원 모델: Gemma, Llama, Qwen, Mistral, Phi 등
- 권장 양자화: Q4_K_M (성능과 품질의 균형)

### 2. 파일 복사
**Android:**
- 파일 관리자에서 `/storage/emulated/0/AiModels/` 폴더 생성
- PC에서 USB로 전송
- 클라우드 저장소에서 다운로드
- 내장 저장소 루트에 있어서 접근 쉬움

**iOS:**
- iTunes 파일 공유
- 파일 앱 사용
- AirDrop으로 전송

### 3. 앱에서 모델 선택
1. 앱 실행
2. 프로필 탭 → "AI 모델 선택"
3. 사용할 모델 선택
4. "선택한 모델 사용하기" 버튼 클릭

## 🚀 사용법

### 모델 선택 화면
- 사용 가능한 모든 모델 표시
- 파일 크기, 아키텍처 정보 제공
- 현재 사용 중인 모델 표시

### 채팅 사용
1. 홈 화면 → "지키미와 대화하기"
2. 또는 프로필 → "지키미와 채팅"
3. 선택한 모델로 AI와 대화

### 디버그 정보
- 프로필 → "AI 모델 정보"
- 모델 로드 상태 확인
- FFI 연결 상태 확인
- 성능 정보 확인

## 🔧 기술 구조

### 네이티브 연동
- **Android**: libllama.so (arm64-v8a 폴더)
- **FFI**: Dart ↔ C++ 바인딩
- **llama.cpp**: 실제 AI 추론 엔진

### 모델 관리
- `ModelManager`: 모델 스캔 및 선택
- `AIService`: AI 서비스 통합
- `NativeBindings`: llama.cpp FFI 바인딩

### 파일 구조
```
lib/
├── services/
│   ├── model_manager.dart      # 모델 관리
│   ├── ai_service.dart         # AI 서비스
│   └── native_bindings.dart    # FFI 바인딩
├── screens/
│   ├── model_selection_screen.dart  # 모델 선택
│   ├── chat_screen.dart            # AI 채팅
│   └── ai_debug_screen.dart        # 디버그 정보
android/app/src/main/
├── cpp/
│   ├── CMakeLists.txt          # 빌드 설정
│   └── native_bridge.cpp       # C++ 브릿지
└── jniLibs/
    ├── llama.h                 # llama.cpp 헤더
    └── arm64-v8a/
        └── libllama.so         # llama.cpp 라이브러리
```

## 📋 지원 모델 예시

### 작은 모델 (< 1GB)
- `gemma-2b-it-q4_k_m.gguf` (1.6GB)
- `phi-3-mini-4k-instruct-q4_k_m.gguf` (2.4GB)

### 중간 모델 (1-5GB)
- `gemma-7b-it-q4_k_m.gguf` (4.1GB)
- `llama-3.2-3b-instruct-q4_k_m.gguf` (1.9GB)

### 큰 모델 (5GB+)
- `llama-3.1-8b-instruct-q4_k_m.gguf` (4.9GB)
- `qwen2.5-7b-instruct-q4_k_m.gguf` (4.4GB)

## ⚠️ 주의사항

### 성능
- 큰 모델일수록 더 많은 메모리와 시간 필요
- 배터리 소모량 증가
- 기기 성능에 따라 응답 속도 차이

### 저장공간
- 모델 파일은 앱 삭제 시 함께 삭제됨
- 충분한 저장공간 확보 필요
- 백업 권장

### 호환성
- GGUF 형식만 지원
- llama.cpp 호환 모델만 사용 가능
- 일부 특수 모델은 지원하지 않을 수 있음

## 🔍 문제 해결

### 모델이 인식되지 않는 경우
1. 파일 확장자가 .gguf인지 확인
2. 파일이 올바른 폴더에 있는지 확인
3. 앱에서 새로고침 버튼 클릭
4. 앱 재시작

### 모델 로드 실패
1. 파일이 손상되지 않았는지 확인
2. 충분한 메모리가 있는지 확인
3. 다른 모델로 테스트
4. 앱 재시작 후 재시도

### 응답이 느린 경우
1. 더 작은 모델 사용
2. 다른 앱 종료로 메모리 확보
3. 기기 재부팅

## 📞 지원

문제가 지속되면:
1. 프로필 → "AI 모델 정보"에서 상태 확인
2. 로그 정보 수집
3. 개발팀에 문의

---

**마지막 업데이트**: 2025-01-31  
**버전**: 1.0.0