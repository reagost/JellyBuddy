cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "jelly_llm")
project(${PROJECT_NAME} LANGUAGES CXX)

# Flutter plugin boilerplate
set(PLUGIN_NAME "jelly_llm_plugin")
add_library(${PLUGIN_NAME} SHARED
  "jelly_llm_plugin.cpp"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# Phase 5: Add llama.cpp via FetchContent
# include(FetchContent)
# FetchContent_Declare(
#   llama_cpp
#   GIT_REPOSITORY https://github.com/ggerganov/llama.cpp.git
#   GIT_TAG        b4000
# )
# FetchContent_MakeAvailable(llama_cpp)
# target_link_libraries(${PLUGIN_NAME} PRIVATE llama)

set(jelly_llm_bundled_libraries "" PARENT_SCOPE)
