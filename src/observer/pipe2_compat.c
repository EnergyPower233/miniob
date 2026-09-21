/* Copyright (c) 2021 OceanBase and/or its affiliates. All rights reserved.
miniob is licensed under Mulan PSL v2.
You can use this software according to the terms and conditions of the Mulan PSL v2.
You may obtain a copy of Mulan PSL v2 at:
         http://license.coscl.org.cn/MulanPSL2
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
See the Mulan PSL v2 for more details. */

/*
 * pipe2() compatibility shim for macOS.
 *
 * Recent Xcode SDKs declare pipe2() as
 *     __API_AVAILABLE(macos(27.0), ...)
 * When libevent is configured against such an SDK, CMake's symbol check only
 * takes the address of the symbol. That compiles (it just emits a
 * -Wunguarded-availability warning), so EVENT__HAVE_PIPE2 is set to 1 and the
 * prebuilt libevent archive ends up with a call to pipe2(). However, pipe2()
 * is not present in libSystem on current macOS releases (26.x and earlier),
 * so linking miniob fails with:
 *
 *     Undefined symbols for architecture arm64:
 *       "_pipe2", referenced from:
 *           _evutil_make_internal_pipe_ in libevent_core.a[11](evutil.c.o)
 *
 * This file provides a portable implementation on top of pipe(2) + fcntl(2),
 * so the libevent reference is always resolved, regardless of the SDK or
 * deployment target used to build libevent.
 *
 * It is compiled directly into the observer executable (see CMakeLists.txt)
 * so that it is loaded before libevent_core.a is scanned by the linker.
 */

#if defined(__APPLE__)

#include <fcntl.h>
#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif

int pipe2(int pipefd[2], int flags)
{
    if (pipe(pipefd) != 0) {
        return -1;
    }

    if ((flags & O_CLOEXEC) != 0) {
        if (fcntl(pipefd[0], F_SETFD, FD_CLOEXEC) == -1 || fcntl(pipefd[1], F_SETFD, FD_CLOEXEC) == -1) {
            close(pipefd[0]);
            close(pipefd[1]);
            return -1;
        }
    }

    if ((flags & O_NONBLOCK) != 0) {
        int flags0 = fcntl(pipefd[0], F_GETFL);
        int flags1 = fcntl(pipefd[1], F_GETFL);
        if (flags0 == -1 || flags1 == -1 || fcntl(pipefd[0], F_SETFL, flags0 | O_NONBLOCK) == -1 ||
            fcntl(pipefd[1], F_SETFL, flags1 | O_NONBLOCK) == -1) {
            close(pipefd[0]);
            close(pipefd[1]);
            return -1;
        }
    }

    return 0;
}

#ifdef __cplusplus
}
#endif

#endif /* __APPLE__ */
