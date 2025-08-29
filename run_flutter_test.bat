@echo off
echo ========================================
echo    우리들의 비밀기지 Flutter 앱 실행
echo ========================================
echo.

REM Flutter PATH 설정
set PATH=%PATH%;C:\flutter\bin

REM Flutter 버전 확인
echo [1/4] Flutter 버전 확인 중...
flutter --version
if %errorlevel% neq 0 (
    echo ❌ Flutter가 설치되지 않았거나 PATH에 추가되지 않았습니다.
    echo    Flutter 설치: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)
echo ✅ Flutter 설치 확인 완료
echo.

REM 의존성 설치
echo [2/4] 의존성 설치 중...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 의존성 설치 실패
    pause
    exit /b 1
)
echo ✅ 의존성 설치 완료
echo.

REM Flutter Doctor 실행 (간단 체크)
echo [3/4] Flutter 환경 체크 중...
flutter doctor
echo.

REM 실행 옵션 선택
echo [4/4] 실행 플랫폼을 선택하세요:
echo 1. 웹 브라우저 (Chrome) - 추천
echo 2. Windows 데스크톱
echo 3. Android 에뮬레이터
echo 4. 연결된 디바이스 확인만
echo.
set /p choice="선택 (1-4): "

if "%choice%"=="1" (
    echo.
    echo 🌐 Chrome 브라우저에서 앱을 실행합니다...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo.
    echo 🖥️ Windows 데스크톱에서 앱을 실행합니다...
    flutter run -d windows
) else if "%choice%"=="3" (
    echo.
    echo 📱 Android 에뮬레이터에서 앱을 실행합니다...
    flutter run -d android
) else if "%choice%"=="4" (
    echo.
    echo 📋 연결된 디바이스 목록:
    flutter devices
) else (
    echo.
    echo ❌ 잘못된 선택입니다. 기본값으로 Chrome에서 실행합니다.
    flutter run -d chrome
)

echo.
echo ========================================
echo 실행이 완료되었습니다!
echo 앱을 종료하려면 터미널에서 'q'를 입력하세요.
echo ========================================
pause