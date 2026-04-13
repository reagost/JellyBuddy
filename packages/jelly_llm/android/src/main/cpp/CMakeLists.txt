cmake_minimum_required(VERSION 3.22)
project(jelly_llm_jni)

# ============================================================
# llama.cpp integration for JellyBuddy Android
# ============================================================
#
# Fetches llama.cpp source and builds it as part of the NDK build.
# The JNI bridge (llama_bridge.cpp) wraps llama.cpp C API for Kotlin.
#
# Build targets:
#   - llama (static lib from llama.cpp)
#   - jelly_llm_jni (shared lib with JNI bridge)
# ============================================================

include(FetchContent)

# Pin llama.cpp to a known release for reproducibility
FetchContent_Declare(
    llama_cpp
    GIT_REPOSITORY https://github.com/ggerganov/llama.cpp.git
    GIT_TAG        b5460
    GIT_SHALLOW    TRUE
)

# Configure llama.cpp build options
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(llama_cpp)

# JNI bridge shared library
add_library(jelly_llm_jni SHARED
    llama_bridge.cpp
)

target_include_directories(jelly_llm_jni PRIVATE
    ${llama_cpp_SOURCE_DIR}/include
    ${llama_cpp_SOURCE_DIR}/ggml/include
)

target_link_libraries(jelly_llm_jni
    llama
    ggml
    log
)

# Strip debug symbols for release
set_target_properties(jelly_llm_jni PROPERTIES
    LINK_FLAGS "-Wl,--gc-sections -Wl,--strip-all"
)
