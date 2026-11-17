cmake_minimum_required(VERSION 3.16)
project(nyachi_flutter)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Flutter Engine native library will be linked here.
# The flutter_ohos package provides the engine .so files.
# This CMakeLists.txt is a placeholder for any additional
# native code that needs to be compiled for the HarmonyOS platform.

# Add native source files here if needed for platform channel plugins
# add_library(nyachi_native SHARED
#   src/main/cpp/native_plugin.cpp
# )

# target_link_libraries(nyachi_native
#   ${OHOS_LIB_DIR}/libflutter_engine.so
# )