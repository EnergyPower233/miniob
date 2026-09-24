# 构建配置

要求：CMake 3.21+、Ninja、Clang/clang++。在安装好依赖后，从项目根目录运行：

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

Release 将上述命令中的 debug 换成 release。预设使用 Clang + Ninja，默认关闭
Sanitizer；需要时通过 `cmake --preset debug -DENABLE_ASAN=ON` 启用。

输出目录：

| 环境 | Debug 程序目录 |
| --- | --- |
| Linux / WSL | out/Linux-clang-debug/bin |
| macOS | out/Darwin-clang-debug/bin |
| Windows 原生 | out/Windows-clang-debug/bin |

VS Code 的 build_debug、build_release、test_debug 和 LLDB 调试入口使用同一组预设。
旧构建目录保留，不复用其中的缓存。已有 windows-clang-debug/release 预设继续保留
以兼容之前的命令，它们仍输出到 build/windows-clang-*。

## Linux / WSL

安装 Clang、CMake、Ninja、make、Flex、Bison 和 Git。使用项目现有依赖初始化脚本：

```sh
CC=clang CXX=clang++ bash build.sh init
```

然后运行上面的 CMake 命令。WSL 必须在 Linux 终端中执行；VS Code 必须通过 WSL
扩展打开文件夹。WSL 产物是 Linux 二进制。优先把项目放在 WSL 的 Linux 文件系统。
不能复用 Windows 编译的依赖；若此前初始化过其他平台的依赖，请使用独立检出目录。

## macOS

安装 Xcode Command Line Tools，以及 CMake、Ninja、Flex、Bison。使用 Homebrew
时确保 brew、cmake 和 ninja 位于 PATH；CMake 自动查询 Homebrew 中的 Flex/Bison
路径，兼容 Intel 和 Apple Silicon，也尊重手动指定的工具路径。
使用与 Linux 相同的依赖初始化和预设命令。

## Windows 原生

将 MSYS2 CLANG64 的 bin 放在 PATH 前面，然后重启终端/VS Code。使用该工具链的
Clang、clang++、Ninja。项目拒绝 GCC/MSVC，当前 GNU 风格编译参数不支持 clang-cl。
这只是本项目的策略，不修改系统全局编译器。

Windows 原生源码移植尚未完成；配置好编译器不代表能编出整个项目。
当前验证通过了 Clang 编译器检测，配置仍受缺少 replxx 依赖阻塞。
Windows 的 init 任务会明确提示此限制，避免意外调用系统 bash/WSL 初始化另一平台的依赖。
如需直接使用现有 POSIX 源码，请在 WSL 中构建。

## 自定义依赖

replxx、libevent、jsoncpp，以及单元测试使用的 GTest 必须与目标平台/工具链匹配。
项目默认搜索 deps/3rd/usr/local，也可传入：

```sh
cmake --preset debug -DCMAKE_PREFIX_PATH=/path/to/dependencies
```

自定义前缀优先于项目内默认前缀。不要在 Windows、WSL、macOS 间共享编译后的依赖。
