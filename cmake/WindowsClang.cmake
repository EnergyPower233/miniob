# Include before project(): select the compiler before CMake enables languages.
if(CMAKE_HOST_WIN32 AND NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  if(NOT CMAKE_GENERATOR MATCHES "^Ninja")
    message(FATAL_ERROR
      "Windows builds require Clang + Ninja. Use cmake --preset windows-clang-debug "
      "or configure a NEW build directory with -G Ninja. Existing Visual Studio "
      "and GCC caches cannot be reused.")
  endif()

  # Respect an explicit toolchain/compiler, then validate it after project().
  # Resolve C and C++ from the same installation to avoid mixing MSYS2/LLVM.
  if(NOT CMAKE_C_COMPILER AND NOT CMAKE_TOOLCHAIN_FILE)
    find_program(MINIOB_CLANG NAMES clang)
    if(NOT MINIOB_CLANG)
      message(FATAL_ERROR "clang was not found. Put your Clang toolchain bin directory on PATH.")
    endif()
    set(CMAKE_C_COMPILER "${MINIOB_CLANG}" CACHE FILEPATH "C compiler")
  endif()
  if(NOT CMAKE_CXX_COMPILER AND NOT CMAKE_TOOLCHAIN_FILE)
    get_filename_component(_miniob_clang_bin "${CMAKE_C_COMPILER}" DIRECTORY)
    find_program(MINIOB_CLANGXX NAMES clang++ HINTS "${_miniob_clang_bin}" NO_DEFAULT_PATH)
    if(NOT MINIOB_CLANGXX)
      message(FATAL_ERROR "clang++ was not found alongside clang. Specify both CMAKE_C_COMPILER and CMAKE_CXX_COMPILER.")
    endif()
    set(CMAKE_CXX_COMPILER "${MINIOB_CLANGXX}" CACHE FILEPATH "C++ compiler")
  endif()
endif()
