# CMakeLists.txt for llama.cpp integration
cmake_minimum_required(VERSION 3.22.1)

project(our_secret_base_native)

# C++17 표준 사용
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# llama.cpp 경로 설정
set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../../native/llama.cpp")

# llama.cpp 소스 파일들
set(LLAMA_SOURCES
    ${LLAMA_CPP_DIR}/src/llama.cpp
    ${LLAMA_CPP_DIR}/src/llama-vocab.cpp
    ${LLAMA_CPP_DIR}/src/llama-grammar.cpp
    ${LLAMA_CPP_DIR}/src/llama-sampling.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-alloc.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-backend.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-quants.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-aarch64.c
)

# 헤더 파일 경로
include_directories(
    ${LLAMA_CPP_DIR}/include
    ${LLAMA_CPP_DIR}/ggml/include
    ${LLAMA_CPP_DIR}/src
)

# 컴파일 정의
add_definitions(
    -DGGML_USE_LLAMAFILE
    -DGGML_USE_OPENMP=0
    -DNDEBUG
)

# Android 특화 설정
if(ANDROID)
    add_definitions(-DGGML_USE_ANDROID)
    
    # ARM NEON 지원 (ARM64/ARMv7에서)
    if(ANDROID_ABI STREQUAL "arm64-v8a" OR ANDROID_ABI STREQUAL "armeabi-v7a")
        add_definitions(-DGGML_USE_NEON)
    endif()
endif()

# 공유 라이브러리 생성
add_library(
    our_secret_base_native
    SHARED
    ${LLAMA_SOURCES}
    native_bridge.cpp
)

# 링크할 라이브러리들
target_link_libraries(
    our_secret_base_native
    android
    log
)

# 컴파일러 플래그
target_compile_options(our_secret_base_native PRIVATE
    -O3
    -ffast-math
    -funroll-loops
    -Wall
    -Wextra
    -Wpedantic
    -Wcast-qual
    -Wno-unused-function
)

# ARM NEON 최적화 (ARM 아키텍처에서만)
if(ANDROID_ABI STREQUAL "arm64-v8a")
    target_compile_options(our_secret_base_native PRIVATE -march=armv8-a+fp+simd)
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
    target_compile_options(our_secret_base_native PRIVATE -march=armv7-a -mfpu=neon)
endif()