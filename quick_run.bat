@echo off
chcp 65001 >nul
echo 🚀 우리들의 비밀기지 앱을 Chrome에서 실행합니다...
echo.

REM Flutter 경로 설정
set PATH=C:\flutter\bin;%PATH%

echo [1/2] 의존성 설치 중...
flutter pub get
if errorlevel 1 (
    echo ❌ 의존성 설치 실패
    pause
    exit /b 1
)
echo ✅ 의존성 설치 완료
echo.

echo [2/2] Chrome에서 앱 실행 중...
echo 💡 Chrome 브라우저가 열리고 앱이 로드됩니다.
echo    앱을 종료하려면 이 터미널에서 'q'를 입력하세요.
echo.

flutter run -d chrome
echo.
echo 앱 실행이 종료되었습니다.
pause