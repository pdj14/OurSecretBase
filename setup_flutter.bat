@echo off
echo ========================================
echo    Flutter 환경 설정 도우미
echo ========================================
echo.

REM Flutter PATH 설정
set PATH=%PATH%;C:\flutter\bin

echo Flutter 환경을 확인하고 설정합니다...
echo.

REM Flutter Doctor 실행
echo [1/3] Flutter Doctor 실행 중...
flutter doctor -v
echo.

REM 의존성 업데이트
echo [2/3] 프로젝트 의존성 업데이트 중...
flutter pub get
flutter pub upgrade
echo.

REM 플랫폼별 설정 확인
echo [3/3] 플랫폼별 설정 확인...
echo.
echo 📱 Android 설정:
flutter doctor --android-licenses
echo.
echo 🌐 Web 설정:
flutter config --enable-web
echo.
echo 🖥️ Windows 설정:
flutter config --enable-windows-desktop
echo.

echo ========================================
echo Flutter 환경 설정이 완료되었습니다!
echo 이제 run_flutter_test.bat을 실행하여 앱을 테스트하세요.
echo ========================================
pause