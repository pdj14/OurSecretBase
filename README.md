# 우리들의아지트 (Our Secret Base)

친구들과 함께하는 특별한 공간을 만들어주는 Flutter 앱입니다.

## 기능

- 🏠 **아지트 관리**: 나만의 특별한 공간 생성 및 관리
- 👥 **친구 초대**: 친구들을 아지트에 초대하여 함께 활동
- 💬 **실시간 채팅**: 아지트 멤버들과 실시간 소통
- 👤 **프로필 관리**: 개인 프로필 설정 및 관리

## 시작하기

### 필요 조건

- Flutter SDK (3.0.0 이상)
- Dart SDK
- Chrome 브라우저 (웹 실행용)
- Android Studio / Xcode (모바일 개발용, 선택사항)

### 🚀 빠른 실행 방법

#### Windows 사용자 (추천)
1. 저장소 클론
```bash
git clone https://github.com/pdj14/OurSecretBase.git
cd OurSecretBase
```

2. **배치 파일로 간편 실행**
```bash
# 옵션 1: 대화형 실행 (플랫폼 선택 가능)
run_flutter_test.bat

# 옵션 2: Chrome에서 바로 실행
quick_run.bat

# 옵션 3: Flutter 환경 설정 (최초 1회)
setup_flutter.bat
```

#### 수동 실행 방법
1. 의존성 설치
```bash
flutter pub get
```

2. 앱 실행
```bash
# 웹 브라우저 (추천)
flutter run -d chrome

# Windows 데스크톱
flutter run -d windows

# Android 에뮬레이터
flutter run -d android

# 연결된 디바이스 확인
flutter devices
```

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── screens/               # 화면 위젯들
│   └── home_screen.dart   # 홈 화면
├── widgets/               # 재사용 가능한 위젯들
│   ├── custom_app_bar.dart
│   └── hideout_card.dart
└── theme/                 # 앱 테마 설정
    └── app_theme.dart
```

## 개발 환경

- **언어**: Dart
- **프레임워크**: Flutter
- **플랫폼**: Android, iOS
- **상태 관리**: Provider (추후 추가 예정)

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.