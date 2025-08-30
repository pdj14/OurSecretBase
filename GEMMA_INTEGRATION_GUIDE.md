# Gemma OnDevice AI 통합 가이드

이 문서는 우리들의아지트 앱에 Google Gemma 모델을 OnDevice로 통합하는 방법을 설명합니다.

## 🎯 개요

- **모델**: Gemma 3 270M IT (4-bit quantized)
- **파일**: `model/gemma3-270m-it-q4_k_m.gguf`
- **용도**: 채팅 화면에서 AI 어시스턴트 "지키미"로 활용
- **특징**: 완전한 오프라인 동작, 개인정보 보호

## 📁 프로젝트 구조

```
lib/
├── services/
│   └── ai_service.dart          # AI 서비스 메인 클래스
├── screens/
│   └── chat_screen.dart         # AI와 채팅하는 화면
└── main.dart

model/
└── gemma3-270m-it-q4_k_m.gguf  # Gemma 모델 파일
```

## 🚀 현재 구현 상태

### ✅ 완료된 기능
- ✅ AI 서비스 클래스 구조 설계
- ✅ 채팅 UI 완성 (지키미 캐릭터)
- ✅ 모델 파일 assets 등록
- ✅ 시뮬레이션된 AI 응답 시스템
- ✅ 한국어 패턴 매칭 기반 대화
- ✅ GGUF 파일 검증 시스템
- ✅ AI 디버그 화면 구현
- ✅ 웹/네이티브 환경 분리 처리
- ✅ 추론 엔진 인터페이스 설계

### 🔄 진행 중인 작업
- 🔄 실제 GGUF 모델 로더 구현
- 🔄 C/C++ 라이브러리 연동 (FFI)
- 🔄 성능 최적화 및 메모리 관리

### 📋 테스트 방법
1. 앱 실행 후 "프로필" 탭으로 이동
2. "AI 모델 정보" 클릭하여 디버그 화면 확인
3. "지키미와 채팅" 또는 홈 화면의 채팅 카드 클릭
4. 다양한 메시지로 AI 응답 테스트

## 🛠️ 기술 스택

### Flutter 패키지
```yaml
dependencies:
  path_provider: ^2.1.1  # 파일 시스템 접근
  ffi: ^2.1.0            # C/C++ 라이브러리 연동
  path: ^1.8.3           # 경로 처리
```

### AI 모델 정보
- **모델명**: Gemma 3 270M Instruction Tuned
- **양자화**: 4-bit (Q4_K_M)
- **파일 크기**: 약 150MB
- **메모리 사용량**: 약 200-300MB
- **추론 속도**: 모바일에서 실시간 대화 가능

## 💡 AI 서비스 사용법

### 기본 사용
```dart
// AI 서비스 초기화
await AIService.instance.initialize();

// AI에게 질문하고 응답 받기
String response = await AIService.instance.generateResponse("안녕하세요!");
```

### 채팅 화면에서 사용
```dart
// 사용자 메시지를 AI에게 전달
final response = await AIService.instance.generateResponse(userMessage);

// 응답을 채팅 목록에 추가
setState(() {
  _messages.add(ChatMessage(
    text: response,
    isUser: false,
    timestamp: DateTime.now(),
  ));
});
```

## 🎨 지키미 캐릭터 설정

### 성격
- 친근하고 활발한 AI 친구
- 한국어로 자연스럽게 대화
- 이모지를 적절히 사용하여 감정 표현
- 사용자의 아지트를 지키는 수호자 역할

### 대화 패턴
- 인사: "안녕하세요! 저는 키미예요! 성은 '지'! '지 키미' 입니다.😊"
- 자기소개: "저는 여러분의 아지트를 지키는 AI 친구랍니다! ✨"
- 일반 대화: 호기심 많고 친근한 톤으로 응답

## 🔧 실제 모델 통합을 위한 다음 단계

### 1. GGUF 로더 구현
```dart
// 실제 구현 시 필요한 기능들
class GGUFLoader {
  static Future<ModelHandle> loadModel(String modelPath) async {
    // GGUF 파일 로드 및 파싱
    // 모델 가중치 메모리 로드
    // 추론 엔진 초기화
  }
}
```

### 2. 추론 엔진 연결
```dart
class InferenceEngine {
  Future<String> generate(String prompt, ModelHandle model) async {
    // 토크나이저로 텍스트를 토큰으로 변환
    // 모델 추론 실행
    // 결과 토큰을 텍스트로 변환
  }
}
```

### 3. 성능 최적화
- 모델 로딩 시간 최적화
- 메모리 사용량 관리
- 배터리 효율성 개선
- 응답 속도 향상

## 📱 플랫폼별 고려사항

### Android
- NDK를 통한 네이티브 라이브러리 연동
- ARM64/x86_64 아키텍처 지원
- 메모리 제한 고려

### iOS
- Metal Performance Shaders 활용 가능
- iOS 앱 크기 제한 고려
- App Store 정책 준수

### Web
- WebAssembly를 통한 브라우저 실행
- 파일 크기 및 로딩 시간 최적화
- 브라우저 메모리 제한 고려

## 🔒 보안 및 개인정보

### 장점
- 완전한 오프라인 동작
- 사용자 데이터가 외부로 전송되지 않음
- 개인정보 보호 완벽 보장

### 주의사항
- 모델 파일 무결성 검증
- 앱 내 모델 파일 보호
- 사용자 대화 내용 로컬 저장 시 암호화

## 🚀 실행 방법

### Windows에서 빠른 실행
```batch
# 배치 파일로 간편 실행
quick_run.bat
```

### 수동 실행
```bash
# 의존성 설치
flutter pub get

# 웹에서 실행 (현재 시뮬레이션 모드)
flutter run -d chrome

# Windows 데스크톱에서 실행
flutter run -d windows
```

### 모델 파일 확인
```bash
# 모델 파일 존재 확인
dir model\gemma3-270m-it-q4_k_m.gguf

# 파일 크기 확인 (약 150MB 예상)
```

### 실제 모델 통합 후 (향후)
```bash
# 릴리즈 빌드
flutter build apk --release
flutter build windows --release

# 설치 및 실행
flutter install
```

## 📈 향후 개선 계획

1. **실제 GGUF 모델 통합** - C/C++ 라이브러리 연동
2. **대화 컨텍스트 관리** - 이전 대화 기억 기능
3. **개인화 기능** - 사용자별 대화 스타일 학습
4. **다국어 지원** - 영어, 일본어 등 추가 언어
5. **음성 인식/합성** - 음성으로 대화하는 기능

## 🤝 기여 방법

1. 이슈 등록 또는 기능 제안
2. 코드 리뷰 및 테스트
3. 문서 개선 및 번역
4. 성능 최적화 아이디어 제공

---

**참고**: 현재 버전은 시뮬레이션 모드로 동작하며, 실제 Gemma 모델 통합은 추가 개발이 필요합니다.

## 🔧 실제 GGUF 모델 통합 로드맵

### Phase 1: 기반 구조 완성 ✅
- [x] Flutter 프로젝트 설정
- [x] AI 서비스 아키텍처 설계
- [x] 시뮬레이션 추론 엔진 구현
- [x] UI/UX 완성 (채팅, 디버그 화면)
- [x] GGUF 파일 검증 시스템

### Phase 2: 네이티브 라이브러리 통합 ✅
```yaml
# pubspec.yaml에 추가할 의존성 (이미 추가됨)
dependencies:
  ffi: ^2.1.0                    # C/C++ 라이브러리 연동
  path_provider: ^2.1.1          # 파일 시스템 접근
  path: ^1.8.3                   # 경로 처리
```

#### ✅ 완료된 네이티브 라이브러리 설정
1. **llama.cpp 서브모듈** - `native/llama.cpp`에 추가됨
2. **Android CMake 설정** - NDK 빌드 구성 완료
3. **JNI 브리지** - Java/Kotlin ↔ C++ 연동 구현
4. **플랫폼별 헤더** - iOS, Windows 지원 준비

#### 플랫폼별 빌드 설정 완료
```cmake
# android/app/src/main/cpp/CMakeLists.txt
cmake_minimum_required(VERSION 3.22.1)
project(our_secret_base_native)

# llama.cpp 소스 파일들 포함
# ARM NEON 최적화 지원
# Android NDK 연동 완료
```

#### 빌드 스크립트
```batch
# Windows에서 네이티브 라이브러리 빌드
scripts\build_native.bat
```

### Phase 3: 실제 추론 엔진 구현 📋
```dart
// lib/services/native_inference_engine.dart
class NativeInferenceEngine implements InferenceEngine {
  late DynamicLibrary _lib;
  Pointer<Void>? _model;
  Pointer<Void>? _context;
  
  @override
  Future<void> loadModel(String modelPath) async {
    // 1. 네이티브 라이브러리 로드
    _lib = DynamicLibrary.open('libllama.so');
    
    // 2. 모델 파일 로드
    final loadModel = _lib.lookupFunction<
        Pointer<Void> Function(Pointer<Utf8>),
        Pointer<Void> Function(Pointer<Utf8>)>('llama_load_model');
    
    final pathPtr = modelPath.toNativeUtf8();
    _model = loadModel(pathPtr);
    malloc.free(pathPtr);
    
    // 3. 컨텍스트 생성
    final createContext = _lib.lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>('llama_new_context');
    
    _context = createContext(_model!);
  }
  
  @override
  Future<String> generate(String prompt, {int maxTokens = 100}) async {
    // Isolate에서 추론 실행하여 UI 블로킹 방지
    return await compute(_generateInIsolate, {
      'prompt': prompt,
      'maxTokens': maxTokens,
      'model': _model,
      'context': _context,
    });
  }
}

// 백그라운드에서 실행될 추론 함수
String _generateInIsolate(Map<String, dynamic> params) {
  // 실제 llama.cpp API 호출
  // 1. 프롬프트 토크나이징
  // 2. 모델 추론 실행
  // 3. 결과 토큰을 텍스트로 변환
  // 4. 결과 반환
}
```

### Phase 4: 성능 최적화 🚀
1. **메모리 관리**
   - 모델 로딩 시 메모리 사용량 모니터링
   - 불필요한 텐서 데이터 해제
   - 메모리 풀 사용으로 할당/해제 최적화

2. **추론 속도 향상**
   - GPU 가속 (Metal/OpenCL/Vulkan)
   - 양자화 최적화 (INT4, INT8)
   - 배치 처리 지원

3. **배터리 효율성**
   - CPU 사용률 제한
   - 백그라운드 처리 최적화
   - 절전 모드 지원

### Phase 5: 프로덕션 준비 📦
1. **보안 강화**
   - 모델 파일 암호화
   - 메모리 덤프 방지
   - 디버깅 정보 제거

2. **배포 최적화**
   - 앱 크기 최소화
   - 모델 파일 압축
   - 점진적 다운로드 지원

3. **모니터링 및 분석**
   - 성능 메트릭 수집
   - 크래시 리포팅
   - 사용자 피드백 시스템

## 🛠️ 개발자를 위한 실습 가이드

### 1단계: 현재 시뮬레이션 모드 테스트
```bash
# 앱 실행
quick_run.bat

# 테스트 시나리오
1. 홈 화면 → "지키미와 대화하기" 클릭
2. 다양한 메시지 입력해보기
3. 프로필 → "AI 모델 정보" → 테스트 버튼들 클릭
4. 응답 시간 및 품질 확인
```

### 2단계: 모델 파일 검증
```dart
// AI 디버그 화면에서 확인할 수 있는 정보
- 파일 크기: ~150MB
- GGUF 매직 넘버: 0x46554747
- 플랫폼: web/native
- 상태: 유효/무효
```

### 3단계: 커스텀 응답 패턴 추가
```dart
// lib/services/gguf_loader.dart의 _generateSimulatedResponse 수정
if (lowerPrompt.contains('새로운키워드')) {
  return "새로운 응답 패턴을 추가했어요! 🎉";
}
```

### 4단계: 실제 모델 통합 준비
1. llama.cpp 라이브러리 컴파일
2. Flutter FFI 바인딩 생성
3. 네이티브 추론 엔진 구현
4. 성능 테스트 및 최적화

---

**현재 상태**: Phase 1 완료, Phase 2 준비 중
**다음 목표**: 실제 GGUF 모델 로더 구현 및 네이티브 라이브러리 통합