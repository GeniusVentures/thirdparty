# GNUS Third-Party Submodule Security Scanning and Anthropic Enrollment Plan

Status: proposed implementation plan; inventory/CI audit completed 2026-10-12; no new security scans executed by this document.
Owner: GeniusVentures thirdparty workstream. Scope: `thirdparty` plus dependent `SuperGenius`, `zkLLVM`, `GeniusSDK`, `GeniusCognitiveSystem`, `GeniusWallet`, and contracts.

## Decision and rationale

**Two independent tracks:**
1. **Internal full coverage:** build and scan the GNUS-owned/maintained code and pinned external dependencies in existing AlmaLinux 8 CI, irrespective of Anthropic acceptance.
2. **Selective Anthropic OSS Scanner enrollment:** propose only projects with demonstrated critical infrastructure/security impact, substantial real-world downstream usage, and exposure to untrusted input. No speculative enrollment flood.

Anthropic closed GNUS app enrollments despite valid scanner configurations. The `gnus-ai` triage cited OpenSSF criticality 0.38, <100 stars, no license detected at triage time, no SECURITY.md, and insufficient evidence of independent downstream adoption. MIT files added on `develop` may not yet be visible to GitHub's default-branch license detector; do **not** claim a license warning is cured until checking default branch/API. No SECURITY.md should be invented to improve scores: add a genuine coordinated-disclosure policy with a monitored contact. A scanner passing `tools/validate.py` does not imply eligibility.

## Verified inventory and ownership

Source of truth: `thirdparty/.gitmodules` and `.planning/SUBREPOS.md` on `develop`. Relative `../` GitHub URLs mean a GeniusVentures-hosted repository, **not necessarily original authorship or unrestricted licensing**.

| Component | Relationship | Security surface | Scan track | Priority |
|---|---|---|---|---|
| libp2p | GNUS-hosted fork of eigendude/libp2p | remote peer parsing, transport, protocol negotiation | independent fork diff + integration | P0 |
| ipfs-lite-cpp | GNUS-hosted project | IPFS block/DAG inputs, remote content | independent + integration | P0 |
| ipfs-bitswap-cpp | GNUS-hosted project | remote block exchange | independent + integration | P0 |
| ipfs-pubsub | GNUS-hosted project | untrusted pubsub messages | independent + integration | P0 |
| wallet-core | fork of trustwallet/wallet-core | signing, keys, address parsing | fork diff + integration | P0 |
| rocksdb | fork of facebook/rocksdb | persistence, crafted records | fork diff + integration | P1 |
| rapidjson | GNUS-hosted upstream-derived library | untrusted JSON parsing | fork diff + integration | P1 |
| MNN | fork of alibaba/MNN | model file/tensor parsing, native inference | fork diff + integration | P1 |
| AsyncIOManager | GNUS-hosted | asynchronous I/O and cancellation | independent + integration | P1 |
| gnus_upnp | GNUS-hosted | LAN discovery and UPnP inputs | independent + integration | P1 |
| soralog | GNUS-hosted | logging input and formatting | independent + integration | P2 |
| sqlite-amalgamation, sqlite_modern_cpp | GNUS-hosted upstream-derived | data parsing and storage | fork diff + integration | P2 |
| zlib | fork of madler/zlib | decompression of untrusted data | fork diff + integration | P1 |
| GSL, Boost.DI, Boost-for-Android | GNUS-hosted upstream-derived/build support | template/build and ABI correctness | diff + SBOM; independent only if material modifications | P2 |
| external pinned: boost, flutter, spdlog, hat-trie, googletest, ed25519, fmt, yaml-cpp, c-ares, openssl, libsecp256k1, xxhash, MoltenVK, Vulkan-Headers, Vulkan-Loader, libssh2, stb, nlohmann/json, snappy, protobuf, shaderc, vk-bootstrap | third-party upstream repositories | varied | SBOM/advisory + dependency integration; no GNUS enrollment | baseline |

The inventory reflects the `develop` submodule manifest; validate exact gitlink SHAs, nested submodules, licenses and diffs from upstream before implementation. `thirdparty` is a build/dependency aggregator, **not** itself proof of downstream popularity.

### Related components outside thirdparty

- `SuperGenius`: `GeniusKDF`, `ProofSystem` (including `SGProofCircuits`), `SGProcessingManager`, `evmrelay`, `gRPCForSuperGenius`. Prioritize KDF, proofs, relay, and remote input boundaries for internal independent scans.
- `GeniusCognitiveSystem`: `GNUS-NEO-SWARM`, nested `GQHSM` and its dependencies; test untrusted task/job payloads and agent isolation.
- `zkLLVM`: inspect its `.gitmodules` and generated target inventory separately; prioritize modified cryptographic, proof, assigner, blueprint and marshalling components. Existing `zkllvm-assigner` and `zkllvm-blueprint` are upstream-derived and retain their own license obligations.
- `GeniusWallet`: `banxa` and `squidrouter` are generated API clients; cover through wallet integration tests rather than hand-editing generated source.
- Smart contracts and `erc20-gnus-proxy`: retain existing Foundry/Hardhat, Semgrep, Snyk-advisory, and contract-focused checks. Anthropic rejection does not mean these security controls are unnecessary.

## Actual build environment audit

Verified source files:
- `GeniusVentures/CIDocker/almalinux-8/Dockerfile`: clang, ninja-build, CMake, Rust, Node 24 and other existing native dependencies.
- `thirdparty/.github/workflows/build.yml`: Linux sets `CMAKE_GENERATOR=Ninja`; configured build directory is `build/Linux/<Debug|Release>/<ABI>`; CI currently configures from `build/Linux` and runs `cmake --build . --config ... -j`.
- `thirdparty/build/Linux/CMakeLists.txt` and `build/CommonTargets.cmake`: dependency build graph uses CMake `ExternalProject_Add`, with distinct target names (for example `Boost`, `openssl`, `rocksdb`); **derive exact available names from the generated Ninja graph, not guesses**.
- `SuperGenius/.oss-scanner/Dockerfile`: currently repeats CMake configuration and a broad build. Narrow to verified security-relevant targets in a later, separately validated PR.
- Existing release artifacts are useful for dependencies but should be pinned by immutable digest and tied to the intended gitlinks. `latest` AlmaLinux image tags are not immutable; pin digest in implementation after CI verification.

**Build rule:** existing container + existing CI configuration is authoritative. If a configured build directory containing `build.ninja` already exists, invoke `ninja -C "$BUILD_DIR" "$TARGET"` directly. A clean Docker checkout does not magically contain a generated `build.ninja`: reproduce the **existing documented configure step once** (or reuse a verified preconfigured build artifact), never add a parallel/novel CMake configuration. Ninja may itself regenerate CMake files when necessary.

Example, after existing CI configuration has produced `build.ninja`:

```sh
BUILD_DIR=build/Linux/Release/x86_64
test -f "$BUILD_DIR/build.ninja"
ninja -C "$BUILD_DIR" -t targets all > /tmp/gnus-ninja-targets.txt
# Select a real target from the inventory; do not build an invented name.
ninja -C "$BUILD_DIR" "$VERIFIED_TARGET"
```

For a child repository, first check whether its standalone build is supported; if not, use the parent thirdparty target and preserve complete child source in the image. Build only the chosen target and its dependency closure, **not** just a single translation unit. For libraries without meaningful executable tests, add a focused test harness for parsers/protocols and exercise happy and hostile paths.

## Implementation phases and acceptance gates

### Phase 0 — machine-readable audit (no enrollment)
1. Walk `git submodule status --recursive` at pinned SHAs across parent repos; collect name, remote, fork parent, current gitlink SHA, branch, license, `SECURITY.md`, maintainers, direct and transitive consumers.
2. Classify **GNUS original**, **materially modified fork**, **unmodified upstream mirror**, **generated client**, or **external pinned** using upstream commit comparison. `../` URLs alone are insufficient.
3. Extract generated Ninja targets from the *real* AlmaLinux CI configuration and record target -> output -> dependent libraries -> test target -> expected build duration. Fail discovery if graph missing.
4. Generate CycloneDX/SPDX SBOM and vulnerability/advisory inventory for pinned dependency versions. Preserve upstream attribution and license obligations. Never blanket-relicense forks as MIT.
5. Map input trust boundaries: libp2p handshake, pubsub frames, bitswap blocks, IPFS codecs, JSON, model artifacts, wallet keys/signatures, UPnP, RPC/proofs.

Deliverables: `submodule-security-inventory.json`, `ninja-target-matrix.md`, `dependency-sbom.json`, `upstream-diff-review.md` (proposed files; not created yet).

### Phase 1 — internal P0 scanning
1. Start with `libp2p`, `ipfs-lite-cpp`, `ipfs-bitswap-cpp`, `ipfs-pubsub`, and `wallet-core`; include `GeniusKDF`, `ProofSystem`, `evmrelay` as related security-critical components.
2. Create narrowly scoped scanner Dockerfiles reusing `ghcr.io/geniusventures/almalinux-8`, documented configure/build layout and exact gitlink versions.
3. Ensure full relevant source, symbols, generated headers and runtime/test binaries are retained in the scanner image. Keep build-time network access separate from **offline runtime**.
4. Run `docker run --network none` tests and malicious-input fixtures; no real tokens, production secrets, external services, or outbound connections. Test malformed frames, truncated blocks, invalid signatures, oversized lengths, cancellations, concurrency, resource limits and valid fixtures.
5. Gate merge on Docker build + offline tests + existing functional CI; report static/SBOM advisories with triage and suppressions documented rather than silently disabling checks.

### Phase 2 — P1 and transitive coverage
1. Add MNN/model artifact parsing, RocksDB, RapidJSON, UPnP, zlib, AsyncIOManager and modified zkLLVM components.
2. Exercise integration paths in SuperGenius/GCS using the pinned dependency graph; detect duplicate scan results via component SHA and vulnerability ID.
3. Cover fuzzing (libFuzzer/AFL++ where feasible), sanitizers, protocol-specific regression corpora and memory safety, with bounded CI budgets.
4. Run complete nightly/weekly integration scans separately from fast per-PR target scans.

### Phase 3 — Anthropic eligibility (optional, evidence-first)
1. Check current upstream enrollment criteria and whether upstream forks are accepted; do not reopen the five closed submissions unchanged.
2. For each candidate, document independently verifiable downstream repositories, deployed usage, transitive dependency counts, user exposure, upstream relationship, maintenance activity, and concrete remote-attack scenarios. **Never substitute GNUS's prospective 256k-node target for deployed users.**
3. Confirm license detection on default branch, valid `SECURITY.md` contact, CLA, threat model, scanner Dockerfile, and `tools/validate.py`.
4. Seek maintainer alignment for widely used upstream projects such as libp2p/Trust Wallet rather than claim their ecosystem adoption belongs to a small fork.
5. Submit at most one strongest, well-evidenced candidate first; wait for reviewer feedback before additional submissions. If adoption is inadequate, keep internal scanning and defer Anthropic enrollment.

## Rollout and responsibility

| Milestone | Definition of done |
|---|---|
| M0 Inventory | Every recursive gitlink accounted for; license and upstream fork relation verified; exact target matrix captured |
| M1 P0 | All five thirdparty P0 components plus KDF/proofs/relay have passing isolated builds and offline tests or documented blockers |
| M2 P1 | All parser/inference/storage P1 components scanned; high-impact findings fixed or explicitly risk-accepted |
| M3 Integration | SuperGenius/GCS/Wallet coverage against pinned SHAs; no duplicated expensive full rebuild on each PR |
| M4 Anthropic | One evidence-backed application accepted **or** explicit deferral because objective eligibility remains unmet |

## Risks and non-goals

- This is a **repository inventory and implementation plan**, not a claim that a complete source-code security scan has already run.
- A scanner that builds successfully is not proof of absence of vulnerabilities.
- Pinned upstream dependencies still need SBOM/advisory monitoring even if not separately enrolled.
- Never change an upstream fork's license without legal/ownership review; `libp2p` has Apache/MIT license files, `zkllvm-assigner`/`zkllvm-blueprint` carry Boost license files, and other forks may differ.
- Keep changes on `develop`; do not merge into `main` or create Anthropic enrollment PRs without the evidence gate.
- Do not assume clean ephemeral Docker layers have a preconfigured Ninja graph; use the original configure instructions once when needed.
- Keep internal scans autonomous of Anthropic's discretionary enrollment process.

## Next implementation PR

A separate code PR should implement **M0** first: generate pinned recursive inventory and real Ninja target matrix from the AlmaLinux 8 workflow, with unit tests for missing gitlinks, unknown licenses, duplicate components, missing targets, and valid dependency closures. This planning PR deliberately changes no CI or build behavior.
