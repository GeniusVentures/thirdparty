# Thirdparty Submodule Map

Maps each nested submodule inside `thirdparty/` to its owner. Planning artifacts for thirdparty live in `thirdparty/.planning/`.

**Rule:** GeniusVentures-owned submodules (relative `../` URLs) are maintained by us. External submodules (HTTPS URLs) are pinned to specific branches/tags and should not be modified.

---

## GeniusVentures-Owned Submodules

| Submodule Path | Remote | Notes |
|---|---|---|
| `libp2p/` | GeniusVentures/libp2p | P2P networking layer |
| `ipfs-lite-cpp/` | GeniusVentures/ipfs-lite-cpp | Embedded IPFS node (has nested tinycbor) |
| `ipfs-bitswap-cpp/` | GeniusVentures/ipfs-bitswap-cpp | IPFS bitswap protocol |
| `ipfs-pubsub/` | GeniusVentures/ipfs-pubsub | IPFS pub/sub messaging |
| `GSL/` | GeniusVentures/GSL | Guidelines Support Library |
| `Boost.DI/` | GeniusVentures/Boost.DI | Dependency injection (cpp14 branch) |
| `rapidjson/` | GeniusVentures/rapidjson | Fast JSON parser (has nested gtest) |
| `rocksdb/` | GeniusVentures/rocksdb | Persistent key-value store |
| `soralog/` | GeniusVentures/soralog | Structured logging |
| `wallet-core/` | GeniusVentures/wallet-core | TrustWalletCore fork (has nested json) |
| `MNN/` | GeniusVentures/MNN | Neural network inference engine |
| `AsyncIOManager/` | GeniusVentures/AsyncIOManager | Async I/O management |
| `gnus_upnp/` | GeniusVentures/gnus_upnp | UPnP network discovery |
| `sqlite3/` | GeniusVentures/sqlite-amalgamation | SQLite amalgamation |
| `SQLiteModernCpp/` | GeniusVentures/sqlite_modern_cpp | C++ wrapper for SQLite |
| `build/Android/Boost-for-Android/` | GeniusVentures/Boost-for-Android | Boost for Android NDK cross-compile |
| `zlib/` | GeniusVentures/zlib | zlib compression (fork of madler/zlib) |

## External Submodules (Pinned)

| Submodule Path | Remote | Branch/Tag |
|---|---|---|
| `boost/` | boostorg/boost | boost-1.85.0 |
| `flutter/` | flutter/flutter | — |
| `spdlog/` | gabime/spdlog | — |
| `hat-trie/` | masterjedy/hat-trie | — |
| `GTest/` | google/googletest | — |
| `ed25519/` | hyperledger/iroha-ed25519 | — |
| `fmt/` | fmtlib/fmt | 7.1.3 |
| `yaml-cpp/` | jbeder/yaml-cpp | yaml-cpp-0.7.0 |
| `c-ares/` | c-ares/c-ares | cares-1_17_2 |
| `openssl/` | openssl/openssl | — |
| `libsecp256k1/` | bitcoin-core/secp256k1 | — |
| `xxhash/` | Cyan4973/xxHash | — |
| `MoltenVK/` | KhronosGroup/MoltenVK | — |
| `Vulkan-Headers/` | KhronosGroup/Vulkan-Headers | — |
| `Vulkan-Loader/` | KhronosGroup/Vulkan-Loader | — |
| `libssh2/` | libssh2/libssh2 | — |
| `stb/` | nothings/stb | — |
| `json/` | nlohmann/json | — |
| `protobuf/` | protocolbuffers/protobuf | — |
| `snappy/` | google/snappy | — |
| `shaderc/` | google/shaderc | — |
| `vk-bootstrap/` | charles-lunarg/vk-bootstrap | — |

---

*Generated: 2026-07-06 · Updated: 2026-10-02*
