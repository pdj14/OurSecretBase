@echo off
chcp 65001 >nul
echo 🔧 llama.cpp 네이티브 라이브러리 빌드 스크립트
echo.

REM 환경 변수 설정
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set LLAMA_CPP_DIR=%PROJECT_ROOT%\native\llama.cpp

echo 📁 프로젝트 루트: %PROJECT_ROOT%
echo 📁 llama.cpp 경로: %LLAMA_CPP_DIR%
echo.

REM llama.cpp 디렉토리 존재 확인
if not exist "%LLAMA_CPP_DIR%" (
    echo ❌ llama.cpp 디렉토리가 없습니다: %LLAMA_CPP_DIR%
    echo    다음 명령어로 서브모듈을 초기화하세요:
    echo    git submodule update --init --recursive
    pause
    exit /b 1
)

echo ✅ llama.cpp 디렉토리 확인됨
echo.

REM 빌드 디렉토리 생성
set BUILD_DIR=%PROJECT_ROOT%\build\native
if not exist "%BUILD_DIR%" (
    mkdir "%BUILD_DIR%"
    echo 📁 빌드 디렉토리 생성: %BUILD_DIR%
)

cd /d "%BUILD_DIR%"

echo 🔨 CMake 구성 중...
cmake "%LLAMA_CPP_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLLAMA_BUILD_TESTS=OFF ^
    -DLLAMA_BUILD_EXAMPLES=OFF ^
    -DLLAMA_BUILD_SERVER=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    -DLLAMA_NATIVE=ON

if errorlevel 1 (
    echo ❌ CMake 구성 실패
    pause
    exit /b 1
)

echo ✅ CMake 구성 완료
echo.

echo 🔨 빌드 중...
cmake --build . --config Release --parallel

if errorlevel 1 (
    echo ❌ 빌드 실패
    pause
    exit /b 1
)

echo ✅ 빌드 완료
echo.

REM 빌드된 라이브러리 파일 확인
echo 📋 빌드 결과:
if exist "Release\llama.dll" (
    echo ✅ llama.dll 생성됨
) else if exist "libllama.so" (
    echo ✅ libllama.so 생성됨
) else (
    echo ❓ 라이브러리 파일을 찾을 수 없습니다
)

echo.
echo 🎉 네이티브 라이브러리 빌드 완료!
echo    빌드 결과는 다음 위치에 있습니다: %BUILD_DIR%
echo.

pause