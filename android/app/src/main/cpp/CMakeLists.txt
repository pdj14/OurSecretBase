# CMakeLists.txt for simple native library
cmake_minimum_required(VERSION 3.22.1)

project(our_secret_base_native)

# C++17 표준 사용
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 네이티브 라이브러리 소스
set(NATIVE_SOURCES
    native_bridge.cpp
)

# 기본 컴파일 정의
add_definitions(-DANDROID)

# 공유 라이브러리 생성
add_library(
    our_secret_base_native
    SHARED
    ${NATIVE_SOURCES}
)

# 링크할 라이브러리들
target_link_libraries(
    our_secret_base_native
    android
    log
)

# 컴파일러 플래그
target_compile_options(our_secret_base_native PRIVATE
    -O2
    -Wall
    -Wextra
)