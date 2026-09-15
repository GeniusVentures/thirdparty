---
phase: quick-260829-kov
status: complete
started: 2026-08-29
completed: 2026-08-29
requirements: [KOV-UAF-02]
---

# Quick Task 260829-kov — SUMMARY

**Fix second UAF — raw `this` in the `dht_->FindProviders` lambda (AsyncIOManager)**
Status: **COMPLETE** · Commit: `AsyncIOManager@6dbad92` (branch `dev_ipfsdevice_retry_uaf`, stacked on `6f4f5ce`)

## What changed (2 files, +76/−13)

- **`src/IPFSCommon.cpp`** — `StartFindingPeers`: `auto self = shared_from_this();` before the
  call; `[=]` replaced with `[self, ioc, cid, filename, addressoffset, parse, save, handle_read]`;
  all member accesses routed through `self->` (`m_logger` ×2, `addAddresses`, `RequestBlockMain`,
  `StartFindingPeersWithRetry`). Mirrors the `RequestBlockMain`/`6f4f5ce` house pattern. No other
  code touched.
- **`test/src/ipfs_device_test.cpp`** — new `FindProvidersCallbackKeepsDeviceAlive`; file header
  `@brief` updated to cover both UAF lambdas. No CMake change (kademlia/ipld_node already linked).

## The regression test — key finding

The first version of the test asserted against an **empty** kademlia routing table and PASSED even
pre-fix. Root cause of the false negative: `FindProvidersExecutor::spawn()` calls `done()`
synchronously when `requests_in_progress_ == 0` (libp2p find_providers_executor.cpp), so with an
empty table the handler runs on the caller thread *inside* `StartFindingPeers` — before the
external reference is dropped, and the (already-fixed) retry timer then holds the device.

The committed test seeds **one unreachable peer** (`kademlia->addPeer`, PeerId derived via
`PeerId::fromHash(cid.content_address)` — the same call production code makes) so `newStream()`
dials asynchronously: the handler stays stored in the executor across `device.reset()`, which is
the in-flight window the GT crash hit. Hermetic — the dial pends on the unrun libp2p io_context;
nothing leaves the process.

## Verification

| Step | Result |
|---|---|
| RED — pre-fix source (6f4f5ce) + seeded-peer test | FAILED in 5ms: "device was freed while FindProviders query was in flight (use-after-free)" |
| GREEN — fix restored, full `ipfs_device_test` | 3/3 PASSED (`RetryTimer*` 10055/10047ms, `FindProvidersCallback*` 5ms) |
| Canonical build `build/OSX/Debug` | `ninja AsyncIOManager && ninja install` clean |
| Dependent suites (DebugTests ctest) | `mnn_loader_test` + `mnn_saver_test` + `filemanager_test` — 100% passed, 0 failed |

Build flags per `260829-gj4-SUMMARY.md` (THIRDPARTY_DIR + OpenSSL cache args + BUILD_EXAMPLES=OFF;
`TESTING` option, not the double-add `BUILD_TESTING`).

## Commits

- `AsyncIOManager@6dbad92` — fix + test, branch `dev_ipfsdevice_retry_uaf` (stacks on `6f4f5ce`)
- thirdparty — gitlink bump + docs (this PLAN/SUMMARY, STATE.md row)

Nothing pushed. User verification step (GT): rebuild `content_exchange_test` with `auto_dht=true` —
should now survive the ~20s provider-query completion (`Empty provider list received` logged, retry
re-armed) instead of SIGSEGV.

## Deviations

- None this round. (Round 1's documented roadmap/deviation notes still apply to the task family.)
