message(FATAL_ERROR
  "build.sh init is a POSIX dependency bootstrap. For WSL, reopen the folder "
  "in VS Code's WSL environment and run init there. Native Windows dependencies "
  "must be built with MSYS2 CLANG64 and supplied through CMAKE_PREFIX_PATH; "
  "the MiniOB POSIX sources still require a native Windows port.")
