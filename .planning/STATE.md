# Project State — thirdparty

> Submodule collection repo (no ROADMAP.md by design — see SUBREPOS.md for the submodule map).
> Quick tasks are tracked in this file; planning artifacts live in `.planning/quick/`.

## Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260829-gj4 | Fix use-after-free in IPFSDevice::StartFindingPeersWithRetry (AsyncIOManager): capture shared_from_this in dhtretry_ timer handler; regression test ipfs_device_test | 2026-08-29 | AsyncIOManager@6f4f5ce (dev_ipfsdevice_retry_uaf) | [260829-gj4-fix-use-after-free-in-ipfsdevice-startfi](./quick/260829-gj4-fix-use-after-free-in-ipfsdevice-startfi/) |
| 260829-kov | Fix second use-after-free in IPFSDevice::StartFindingPeers (AsyncIOManager): capture shared_from_this in FindProviders callback; regression test seeds kademlia peer for genuinely-async query | 2026-08-29 | AsyncIOManager@6dbad92 (dev_ipfsdevice_retry_uaf) | [260829-kov-fix-second-use-after-free-raw-this-in-dh](./quick/260829-kov-fix-second-use-after-free-raw-this-in-dh/) |

Last activity: 2026-08-29 - Completed quick task 260829-kov: Fix second use-after-free in IPFSDevice::StartFindingPeers FindProviders callback (AsyncIOManager)
