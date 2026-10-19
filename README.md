# Crewbo IDE

The Crewbo IDE is a code editor with [Crewbo](https://github.com/crewbo/crewbo) built in: Code OSS (the open source core of VS Code) with Crewbo's extension, its crew panel open from the first run, and telemetry off. Each teammate prompts their own agent (Claude Code, Codex) in the editor while the crew panel shows who is working on what.

**Status: planned.** Nothing is built yet. The IDE ships as a **preview** with Crewbo's first public release (about 22 November 2026); the Crewbo extension for VS Code, Cursor and other VS Code-based editors stays the main way to use Crewbo.

## How it is built

From the build scripts of [VSCodium](https://github.com/VSCodium/vscodium) (MIT), which build Microsoft's MIT-licensed `vscode` repository with a custom `product.json` and pre-built extensions. Crewbo changes only the product identity, icons, defaults and the bundled extensions, so a new VS Code release is picked up by running the scripts again. Extensions come from [Open VSX](https://open-vsx.org): the Visual Studio Marketplace's terms allow its extensions only in Microsoft's products, so some Microsoft-only extensions are not available.

The decision and its trade-offs: [ADR 0016](https://github.com/crewbo/crewbo/blob/main/docs/adr/0016-crewbo-ide-preview-at-launch.md).

## Plan

Issues live in the main repository, milestone [M8: Crewbo IDE preview](https://github.com/crewbo/crewbo/milestone/9):

| Issue | What |
| --- | --- |
| [M8-01](https://github.com/crewbo/crewbo/issues/191) | Build from VSCodium's scripts: Crewbo's `product.json`, icons, the Crewbo extension built in |
| [M8-02](https://github.com/crewbo/crewbo/issues/192) | Packages from CI: Linux (`tar.gz`, `deb`, AppImage), macOS (arm64, x64), Windows (x64), with checksums and attestations |
| [M8-03](https://github.com/crewbo/crewbo/issues/193) | Signing and first-run defaults (Windows through SignPath Foundation if approved; macOS unsigned for the preview) |
| [M8-04](https://github.com/crewbo/crewbo/issues/194) | IDE docs and download page |
| [M8-05](https://github.com/crewbo/crewbo/issues/205) | Agent extensions (Claude Code, Codex) where Open VSX and their licences allow |

## Contributing and licence

See [CONTRIBUTING.md](CONTRIBUTING.md). This repository is licensed under the [MIT License](LICENSE); files taken from VSCodium keep their own MIT notices. Crewbo itself is licensed separately (Apache-2.0, with the sync server under the AGPL-3.0).
