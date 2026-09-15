---
status: complete
phase: quick-260829-gj4
plan: 01
subsystem: AsyncIOManager
requirement: GJ4-UAF-01
submodule_commit: 6f4f5ce
submodule_branch: dev_ipfsdevice_retry_uaf
base_commit: 36e0dd1
started: 2026-08-29T19:05:59Z
completed: 2026-08-29T19:22:19Z
duration: ~16 min
tags: [ipfs, use-after-free, async, boost-asio, regression-test]
---

# Quick Task 260829-gj4: Fix use-after-free in IPFSDevice::StartFindingPeersWithRetry

One-liner: The 10s `dhtretry_` timer handler in `StartFindingPeersWithRetry` now captures `shared_from_this()` (mirroring the `RequestBlockMain` pattern), the dead local timer is removed, and a new gated regression test proves it: pre-fix code segfaults, post-fix code passes 2/2.

## Result

**Status: COMPLETE.** All three tasks executed; single atomic commit `6f4f5ce` on branch `dev_ipfsdevice_retry_uaf` (off `36e0dd1`) inside the AsyncIOManager submodule; nothing pushed; no superproject commit made by the executor.

## What Changed

### 1. `AsyncIOManager/src/IPFSCommon.cpp` — the fix (lines 154-180, single diff hunk)

Four surgical changes inside `IPFSDevice::StartFindingPeersWithRetry`, nothing else in the file (verified: `git diff 36e0dd1..HEAD -- src/IPFSCommon.cpp` is one hunk, `@@ -159,21 +159,22 @@`):

- DELETED line 162: dead local `boost::asio::deadline_timer dhtretry( *ioc.get() );` (constructed, never used).
- INSERTED after `dhtretry_.expires_from_now( timeout );`: `auto self = shared_from_this();` with the house comment "Capture shared_ptr to keep this object alive during callback" (mirrors lines 192-196 in `RequestBlockMain`).
- Lambda capture list: trailing `this` replaced with `self`.
- Both branches routed through `self->` (`self->StartFindingPeers(...)` in the timeout branch; `self->m_logger->error(...)` in the error branch).

No destructor `dhtretry_.cancel()` added (per plan rationale: with self-capture the destructor cannot run while a handler is pending; member destruction already cancels outstanding waits). Pre-existing `10000` ms literal left untouched per scope guard.

### 2. `AsyncIOManager/test/src/ipfs_device_test.cpp` — new regression tests (136 lines)

- Fixture `IPFSDeviceRetryTest : public ::testing::Test` with one client-only `BitswapNode` (suite-static, `GTEST_SKIP()` on construction failure, no `FileManagerTestFixture` base, no disk access).
- `RetryTimerKeepsDeviceAlive`: arms the timer, drops the last external `shared_ptr`, asserts `EXPECT_NE(watch.lock(), nullptr)`, then deterministically waits out the timer via `pollUntil(watch.expired(), 20s)`.
- `RetryChainCompletesAfterReferenceDropped`: arms first, drops the reference, asserts the completion callback fires within 20s via `pollUntil` and that the result is the expected failure (`Error::CANNOT_DECODE` path), then confirms `watch.expired()`.
- All waits via `pollUntil` (project wait-condition template); zero `sleep_for`; Allman braces; `kNeverPublishedCid` named constant.

### 3. `AsyncIOManager/test/src/CMakeLists.txt` — target registration (lines 168-200)

`addtest(ipfs_device_test ...)` block inside the `if(ASYNC_IO_MANAGER_NETWORK_TESTS)` gate, after the `ipfs_saver_test` block; link libraries byte-identical to `ipfs_loader_test`; plus one `target_compile_options` addition (see Deviation 7).

## Test Results

| Test | Result |
|---|---|
| `ipfs_device_test` (new) | **2/2 PASSED** (`RetryTimerKeepsDeviceAlive` 10010 ms, `RetryChainCompletesAfterReferenceDropped` 10046 ms) |
| `ctest -R "mnn_loader_test\|mnn_saver_test\|filemanager_test"` | **3/3 Passed, 0 failed** (8.47s total) |

**TDD RED/GREEN evidence** (Task 1 was `tdd="true"` but the plan commits fix+tests atomically, so the RED gate was demonstrated post-hoc by temporarily restoring `36e0dd1`'s `IPFSCommon.cpp` and rebuilding):

- RED (pre-fix): `./test_bin/ipfs_device_test --gtest_filter=IPFSDeviceRetryTest.RetryTimerKeepsDeviceAlive` → **Segmentation fault: 11 (exit 139)** — the actual use-after-free, matching the crash reports (fault in the timer handler on freed memory).
- GREEN (post-fix): same test → `[ PASSED ] 1 test` (10024 ms); full binary 2/2. The fixed source was then restored via `git checkout -- src/IPFSCommon.cpp` and rebuilt; tracked tree clean.

## Build Results

Both build dirs use the plan's prescribed entry point (`build/OSX/CMakeLists.txt`, Ninja, Debug, x86_64 pin at line 22) plus the workspace's own cache args (see Deviations 2-4):

- **`build/OSX/Debug` (canonical)**: configured, `ninja AsyncIOManager` → `[15/15] Linking CXX static library AsyncIOManager/lib/libAsyncIOManager.a` (~80 MB), `ninja install` installed headers + `lib/cmake/Async/*` into the build prefix. CONFIRMED.
- **`build/OSX/DebugTests`**: configured with `-DASYNC_IO_MANAGER_NETWORK_TESTS=ON`; built `ipfs_device_test`, `mnn_loader_test`, `mnn_saver_test`, `filemanager_test` — all four compile and link clean.

## Submodule Git State

- Commit: `6f4f5ce` — "Fix use-after-free in IPFSDevice::StartFindingPeersWithRetry: capture shared_from_this in dhtretry_ timer handler and remove dead local timer"
- Branch: `dev_ipfsdevice_retry_uaf`, created off `36e0dd1` (guard verified before branching: HEAD `36e0dd1`, detached, clean)
- Files: exactly `src/IPFSCommon.cpp`, `test/src/ipfs_device_test.cpp`, `test/src/CMakeLists.txt` (175 insertions, 4 deletions)
- Not pushed. No `git add`/`commit` in the thirdparty superproject. Working tree: zero tracked modifications; `?? build/OSX/DebugTests/` untracked as expected (not gitignored, not committed, no `git clean` run).

## Deviations from Plan

**1. [Rule 1 - test bug] `s_clientNode` access section.** Plan specified `private static std::unique_ptr<BitswapNode> s_clientNode;`, but gtest `TEST_F` subclasses cannot access private base members — compile error `'s_clientNode' is a private member of 'IPFSDeviceRetryTest'`. Changed the section to `protected:`, matching the reference fixture (`IPFSIntegrationTest` keeps its statics accessible). Files: `test/src/ipfs_device_test.cpp`.

**2. [Rule 3 - blocking env issue] `-DTHIRDPARTY_DIR=<superproject root>` required.** The plan's bare `cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug` fails: `CommonCompilerOptions.CMake:67 Cannot find thirdparty directory required to build`. The script's default only auto-resolves when a sibling `thirdparty/` exists next to the checkout (standalone layout) — not this workspace's layout (AsyncIOManager is nested inside the superproject named `thirdparty`). `THIRDPARTY_DIR` is the script's own first-class cache knob (`if (NOT DEFINED THIRDPARTY_DIR)`), and the value chosen (superproject root) is exactly what the superproject itself sets for the same variable (`build/CommonCompilerOptions.cmake:123`). `THIRDPARTY_BUILD_DIR` then auto-defaults to `<super>/build/OSX/Debug`, where every dependency is installed. No change to generator, toolchain, arch, or entry point.

**3. [Rule 3 - blocking env issue] OpenSSL cache args required (`-DOpenSSL_DIR`, `-DOPENSSL_ROOT_DIR`, `-DOPENSSL_USE_STATIC_LIBS`).** Without them, `find_package(OpenSSL)` in CONFIG mode (the script sets `CMAKE_FIND_PACKAGE_PREFER_CONFIG ON`) fell through to Homebrew's OpenSSL (`OpenSSL_DIR=/opt/homebrew/lib/cmake/OpenSSL`), which leaked `-isystem /opt/homebrew/include` onto every compile line — ahead of the thirdparty `fmt/include` — so `#include <fmt/...>` resolved to Homebrew fmt 12.1.0, breaking spdlog 1.12 (`spdlog/common.h:373: no template named 'basic_format_string' in namespace 'fmt'`). The three flags are copied verbatim from the superproject's own `_OPENSSL_CACHE_ARGS` (`build/OSX/CMakeLists.txt:125-129`) that it passes to AsyncIOManager via ExternalProject. With them, no `/opt/homebrew` path appears on any compile line.

**4. [Rule 3 - pre-existing out-of-scope failure] `-DBUILD_EXAMPLES=OFF`.** `ninja install` builds the example target, and `example/MNNExample.cpp:168` fails under the installed Xcode 26.2 clang (`-Wmissing-template-arg-list-after-template-kw`, error by default) — a pre-existing conformance issue unrelated to this fix (the library itself compiled 15/15 clean). The superproject's `_CMAKE_COMMON_CACHE_ARGS` already builds AsyncIOManager with `-DBUILD_EXAMPLES:BOOL=OFF`, so this mirrors existing workspace wiring. The example file itself was NOT modified (out of scope; logged here for the verifier).

**5. [Rule 3 - plan command bug] DebugTests configured without `-DBUILD_TESTING=ON`.** The plan's DebugTests configure command trips a latent double-add in the existing build files: `src/CMakeLists.txt:52` (`if(BUILD_TESTING) add_subdirectory(../test ${CMAKE_BINARY_DIR}/test)`) AND `build/CommonBuildParameters.cmake:323` (`if (TESTING)` — default ON — `add_subdirectory(${PROJECT_ROOT}/test ${CMAKE_BINARY_DIR}/test)`) both claim the same binary dir → CMake fatal error "The binary directory .../DebugTests/test is already used". Since editing the build files is out of scope (three-file commit limit), DebugTests was configured with `BUILD_TESTING` left at its default OFF: the `TESTING` option (default ON) is what adds the test subdir and calls `enable_testing()`, so all four prescribed targets build and ctest registers everything (`Test #1/#2/#3/#8`). No behavioral difference for the plan's verification steps.

**6. [verify-script quirk] Task 1's verify one-liner.** `grep -n ... | wc -l | grep -x 2` can never match on macOS because `wc -l` pads output with spaces. Re-ran the same assertions with `grep -c` — all three underlying assertions pass (dead local gone: 0; `self = shared_from_this`: 2; `handle_read, this]`: 0). Task 2's and Task 3's verify one-liners ran as written (Task 3's `git status --short | wc -l | grep -x 0` is satisfied in spirit: zero tracked modifications; the `?? build/OSX/DebugTests/` untracked entry is expected per orchestrator instructions).

**7. [Rule 3 - pre-existing toolchain drift] `-Wno-missing-template-arg-list-after-template-kw` on the new target.** Shared header `test/testutil/bitswap_node.hpp:99` (Boost.DI `TEMPLATE_TO` macro) trips the same newer-clang default-error conformance warning as Deviation 4's example file — affecting all bitswap-node-based tests on this toolchain, not just the new one. Added `target_compile_options(ipfs_device_test PRIVATE -Wno-missing-template-arg-list-after-template-kw)` in `test/src/CMakeLists.txt` (within the allowed file set), scoped to the new target only, consistent with the project's existing `-Wno-*` handling of toolchain noise in `CommonCompilerOptions.CMake`. The shared header itself was NOT modified.

## Authentication Gates

None.

## Known Stubs

None — no stub patterns in the new/modified files; the failure chain asserted by Test 2 is fully wired end-to-end.

## Threat Flags

None. The plan's `<threat_model>` mitigation T-GJ4-01 is implemented and verified (armed handler holds a strong reference; regression test proves it). No new trust-boundary surface introduced.

## Self-Check: PASSED

All three committed files exist on disk; commit `6f4f5ce` exists at HEAD of `dev_ipfsdevice_retry_uaf`, exactly 1 commit ahead of `36e0dd1` (ancestor check OK); zero tracked modifications in the submodule; no superproject commits made by the executor; SUMMARY.md present.
