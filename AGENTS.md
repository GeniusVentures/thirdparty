# AGENTS Guide (thirdparty)

## Scope and instruction precedence
- This repo is a third-party build orchestrator for SuperGenius, not a single library implementation (`README.md`).
- Treat `build/*/CMakeLists.txt` + `build/CommonTargets.CMake` + `build/CommonCompilerOptions.CMake` as source of truth for build behavior.
- If you work inside `MNN/`, follow its local agent docs first: `MNN/CLAUDE.md` and `MNN/apps/mnncli/AGENTS.md`.

## Big-picture architecture (how this repo is structured)
- Platform entrypoints live in `build/{Linux,OSX,iOS,Android,Windows}/CMakeLists.txt`.
- Each platform file defines platform-specific toolchain/build details (Boost/OpenSSL/MNN variants), then includes `build/CommonTargets.CMake`.
- `build/CommonTargets.CMake` orchestrates dependency builds via `ExternalProject_Add` for the full stack (Boost, protobuf, libp2p, ipfs-lite-cpp, ipfs-pubsub, AsyncIOManager, wallet-core, etc.).
- Cross-component wiring is done by propagating generated package paths (`*_DIR`, include/lib dirs) into downstream projects.
- For cross-compiling, host tools are built separately (`protobuf_host`) and reused by target builds (`PROTOC_EXECUTABLE`, `protobuf-plugin`, then `wallet-core`).

## Dependency/data flow patterns to preserve
- Core network stack order is explicit: `libp2p` -> `ipfs-lite-cpp` -> `ipfs-pubsub`/`ipfs-bitswap-cpp` -> `AsyncIOManager` (`build/CommonTargets.CMake`).
- Logging/config foundations (`fmt`, `spdlog`, `yaml-cpp`, `soralog`) are shared dependencies used across multiple projects.
- Build outputs are consumed from the build tree (`<binary>/<target>/lib/cmake/...`), not from system package managers.
- `CommonCompilerOptions.CMake` enforces C++17, shared cache args, and common flags; keep new targets aligned with `_CMAKE_COMMON_CACHE_ARGS`.

## Critical developer workflows (repo-specific)
- Initialize submodules before any build:
```bash
git submodule update --init --recursive --jobs 4 --depth 1
```
- Preferred configure/build pattern (matches README and CI):
```bash
cd build/<Platform>/<BuildType>
cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=<BuildType>
ninja
```
- macOS uses `-DPLATFORM=MAC_UNIVERSAL` in CI (`.github/workflows/build.yml`).
- iOS uses `-DPLATFORM=OS64`; Android requires `-DANDROID_ABI=<abi>` and `ANDROID_NDK_HOME`.
- Linux CI forces clang via `update-alternatives`; do not assume gcc parity without checking.

## CI and release integration points
- Main validation matrix: `.github/workflows/build.yml` (Android/iOS/OSX/Linux/Windows).
- Release-targeted matrix and toggles: `.github/workflows/build-targets.yml`.
- Status badges reference per-platform workflows (`CICDSTATUS.md`, `README.md`).

## Known gotchas discovered in this repo
- There is a documented dependency-graph issue where some setups may need two `ninja` runs; see `CMAKE_ANALYSIS_README.md` before changing target dependencies/byproducts.
- Many targets depend on explicit `DEPENDS` and `BUILD_BYPRODUCTS` correctness for deterministic one-pass builds.
- Build docs under `build/Android/README.md` and `build/iOS/README.md` are older; prefer root `README.md` + workflow files when instructions conflict.

## Practical editing guidance for agents
- Make minimal, surgical changes in the relevant platform file and/or `build/CommonTargets.CMake`; avoid broad refactors across vendored sources.
- When adding a dependency, update both `DEPENDS` and required `*_DIR`/include cache args for downstream consumers.
- Validate changes by mirroring one CI configure/build path for the affected platform.

