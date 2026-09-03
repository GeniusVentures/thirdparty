---
phase: quick-260829-kov
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - AsyncIOManager/src/IPFSCommon.cpp
  - AsyncIOManager/test/src/ipfs_device_test.cpp
autonomous: true
requirements: [KOV-UAF-02]
---

# Quick Task 260829-kov: Fix second UAF — raw `this` in `dht_->FindProviders` lambda

Follow-up to 260829-gj4 (same class of defect, different lambda). With the DHT actually
started (`auto_dht=true` in GT), the provider query runs ~20s async; on completion the
callback runs on a freed IPFSDevice. Crash report `content_exchange_test-2026-08-29-134615.ips`,
fault 0x38, frames `kademlia::FindProvidersExecutor::done() → callback → m_logger->error("Empty provider list received")`.

**The bug (verified):** `IPFSDevice::StartFindingPeers` (src/IPFSCommon.cpp:118-149) passes a
`[=]`-capture lambda to `dht_->FindProviders` — `[=]` copies raw `this`. Member derefs inside:
`m_logger->error` (:124, :145), `addAddresses` (:139), `RequestBlockMain` (:141),
`StartFindingPeersWithRetry` (:146). Nothing holds the device while the query is in flight.

**Verified async semantics:** `IpfsDHT::FindProviders` → `kademlia_->findProviders` → with an
empty content-routing table the handler is stored in an async `GetProvidersExecutor`
(libp2p kademlia_impl.cpp:216-219) — never invoked synchronously. So a pending query holds
the callback (and post-fix, its `self` capture) until the DHT stack is torn down.

## Fix (user-specified; mirrors 6f4f5ce / RequestBlockMain pattern)

In `StartFindingPeers`, before `dht_->FindProviders(`:
`// Capture shared_ptr to keep this object alive during callback` + `auto self = shared_from_this();`
Replace `[=]` with `[self, ioc, cid, filename, addressoffset, parse, save, handle_read]` and route
every member access through `self->` (including `self->RequestBlockMain` at :141 — required to
compile once `this` is no longer captured). Nothing else in the file changes. The unused
`peer_id` local (:117) is pre-existing and stays (out of scope).

## Regression test (extend `test/src/ipfs_device_test.cpp`, no CMake change — kademlia + ipld_node already linked)

`IPFSDeviceRetryTest.FindProvidersCallbackKeepsDeviceAlive` — instant, deterministic:
1. Build a minimal DHT stack mirroring IPFSDevice's singleton ctor: kademlia via
   `makeHostInjector(makeKademliaInjector(useKademliaConfig(default Config)))`, `IpfsDHT(kademlia, {}, runner.ioc())`
   — no bootstrap addresses (hermetic; query stays pending forever, never touches network).
2. `device = createWithBitswap(runner.ioc(), suiteNode->getBitswap(), dht)`; call
   `StartFindingPeers(...)` (takes the DHT branch, arms the async query).
3. `weak_ptr watch = device; device.reset();` — drops the last external ref mid-query (the UAF window).
4. `EXPECT_NE(watch.lock(), nullptr)` — pre-fix (`[=]` = raw this) FAILS instantly; post-fix the
   executor-stored callback holds `self`.
5. No expiry wait: a pending query legitimately keeps the device alive; teardown is by scope
   (dht/kademlia/host die before runner → callback destroyed → device dtor on the test thread).

## Build & verify

- Canonical `build/OSX/Debug`: incremental `ninja AsyncIOManager && ninja install` (configure flags
  from 260829-gj4 SUMMARY: THIRDPARTY_DIR + OpenSSL cache args + BUILD_EXAMPLES=OFF).
- `build/OSX/DebugTests`: rebuild, run `test_bin/ipfs_device_test` (3 tests), `ctest -R "mnn_loader_test|mnn_saver_test|filemanager_test"`.
- RED/GREEN: run the new test against the pre-fix IPFSCommon.cpp (checkout 6f4f5ce's copy), expect
  the weak_ptr assertion to FAIL; restore fix, expect pass.

## Commits

1. Inside AsyncIOManager on existing branch `dev_ipfsdevice_retry_uaf` (stacked on 6f4f5ce),
   exactly two files. No push.
2. Orchestrator: thirdparty gitlink bump + docs (this PLAN, SUMMARY, STATE.md row).
