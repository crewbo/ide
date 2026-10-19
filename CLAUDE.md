# CLAUDE.md

This file guides Claude Code (and humans) working in `crewbo/ide`, the Crewbo IDE: Code OSS with Crewbo built in, built from VSCodium's scripts. See `README.md` for what it is.

## Sources of truth (read before working)

Everything shared lives in the main repository, [crewbo/crewbo](https://github.com/crewbo/crewbo); this repository copies none of it. If this file and those documents disagree, they win.

| What | Where |
| --- | --- |
| Why the IDE exists, its scope and trade-offs | [ADR 0016](https://github.com/crewbo/crewbo/blob/main/docs/adr/0016-crewbo-ide-preview-at-launch.md) (supersedes the timeline of ADR 0012) |
| Product requirements | [PRD](https://github.com/crewbo/crewbo/blob/main/docs/product/PRD.md) |
| Plan and issues (M8) | [implementation plan](https://github.com/crewbo/crewbo/blob/main/docs/engineering/implementation-plan.md), [milestone M8](https://github.com/crewbo/crewbo/milestone/9) |
| Decisions, unknowns | [decision log](https://github.com/crewbo/crewbo/blob/main/docs/engineering/decision-log.md), [unknowns](https://github.com/crewbo/crewbo/blob/main/docs/engineering/unknowns.md) (U-37: CI time for IDE builds) |
| Brand: logo, colours, Bo, voice | [docs/brand](https://github.com/crewbo/crewbo/tree/main/docs/brand) (start with `README.md` and `01-principles.md`) |
| The extension the IDE bundles | [`extension/`](https://github.com/crewbo/crewbo/tree/main/extension) (a `.vsix` from Crewbo's releases) |
| Main repository rules | [crewbo/crewbo CLAUDE.md](https://github.com/crewbo/crewbo/blob/main/CLAUDE.md) |

Source precedence: Ronel's explicit instructions > PRD > accepted ADRs > research > own judgement.

## Current state

Builds and runs on Linux (M8-01, 2026-10-20): name, folders, app IDs, icon, Open VSX, updates off, the Crewbo extension built in. Since M8-03 (2026-10-20): Crewbo's mark in the title bar and on the Welcome tab (black on light themes, white on dark), the tagline on the Welcome page, and the crew panel open on first run (the extension does that when `env.appName` is "Crewbo IDE"). Not yet: macOS and Windows packages (M8-02), signing (M8-03), the macOS `.icns`. Still VSCodium's: the empty-editor watermark (`letterpress-*.svg`), and "CrewboIDE" without a space in strings VSCodium's patches fill from `APP_NAME`. Licence: MIT (Ronel, 2026-10-20).

## Commands

| Purpose | Command |
| --- | --- |
| Toolchain (Node, Python 3.11, Rust, pinned for VSCodium) | `mise install` (versions in `mise.toml`) |
| Build for this machine | `CREWBO_VSIX=/path/to/crewbo-<version>.vsix ./build.sh` (about 13 minutes on a 12-core laptop) |
| Run the build | `./build/vscodium/VSCode-linux-x64/bin/crewbo-ide` |
| Update VSCodium | change `VSCODIUM_REF` to a newer VSCodium commit, rebuild, check |
| Update brand icons | change `CREWBO_REF` to a crewbo/crewbo commit |

`build.sh` sources VSCodium's scripts (`get_repo.sh`, `version.sh`, `build.sh`) with its own environment (`APP_NAME=CrewboIDE`, `BINARY_NAME=crewbo-ide`, `DISABLE_UPDATE=yes`). They read unset variables, so `set -u` is off around them. Their output lands in `build/vscodium/VSCode-<os>-<arch>/`.

Changes to Code OSS itself are patch files in `patches/` (`git diff` format against the source after VSCodium's own patches). `build.sh` copies them into VSCodium's `patches/user/`, which `prepare_vscode.sh` applies last. Brand files that replace Code OSS files go into VSCodium's `src/stable/` overlay, which `prepare_vscode.sh` copies over the source; copying straight into `vscode/` is overwritten.

## Non-negotiable rules

1. Never invent an API, CLI flag, config key, path, version or behaviour. Verify against official docs (fetched), the tool's `--help`, or the source at the pinned version, and cite the URL next to non-obvious external contracts. If it cannot be verified, mark it UNVERIFIED, add it to crewbo's unknowns with a fallback, and take the fallback or ask Ronel.
2. Never claim something works unless it ran in this session; say what ran and on which OS ("untested on <OS>" otherwise).
3. Stop and ask Ronel before: changing a PRD or ADR decision, adding a paid or non-permissive dependency, paying for anything (the Apple Developer Program, certificates), changing repository settings, publishing a release, or anything irreversible.
4. No AI or tool attribution in commits, pull requests or comments: no `Co-Authored-By`, no "Generated with", no session links (`Claude-Session:` or claude.ai URLs), no emoji.
5. No em dashes in any written copy. Plain English, sentence case.
6. Never use Microsoft's trademarks for the IDE: not the "Visual Studio Code" or "VS Code" name, not its logo. Say "Code OSS" for the base, "Crewbo IDE" for the product.
7. Never point the IDE at the Visual Studio Marketplace: its terms allow its extensions only in Microsoft's products. Use Open VSX.
8. Keep the MIT copyright notices of every file taken from VSCodium. Patch Code OSS only through `product.json`, configuration and patch files, never by editing a vendored copy, so a new upstream release is a re-run.
9. Brand assets come from crewbo's `docs/brand/assets`, unchanged. Never redraw Bo or the mark; a new asset needs an entry in crewbo's `docs/brand/DECISIONS.md`.
10. Never send telemetry. Crewbo's rule: only paths, task text, branch names, vendor and presence leave a machine, and only to the team's own sync server.

## Git workflow

- Trunk-based; branch per issue: `<type>/<short-kebab-description>`; Ronel reviews and merges. Never push to `main` or force-push a shared branch.
- Conventional Commits 1.0.0: `<type>(<scope>): <imperative lower-case summary>`, body explains why, footer `Refs: crewbo/crewbo#N`.
- Types: feat, fix, docs, build, ci, chore, refactor, test. Scopes: build, product, branding, extensions, signing, ci, docs.
- Pull requests under about 400 changed lines, excluding upstream files; use the template.
- Record decisions in crewbo's decision log (or an ADR there), not here.

## Known facts and gotchas (verified 2026-10-19)

- VSCodium's README: its repository is "not a fork" but scripts (`build.sh`, `prepare_vscode.sh`, `prepare_src.sh`) that clone `microsoft/vscode`, apply a `product.json`, build, and upload; builds exit early when there is no new upstream release. It downloads some pre-built extensions at build time. ([VSCodium](https://github.com/VSCodium/vscodium))
- Platforms VSCodium ships: macOS 12+ (x64, arm64: `zip`, `dmg`), Linux x64 (`deb`, `rpm`, AppImage, snap, `tar.gz`), Linux arm64, Windows 10+ (x64, arm64). Windows signing through SignPath Foundation. Not yet verified for Crewbo's fork of the scripts.
- An unsigned macOS app is blocked on first open until the user chooses **Open Anyway** in System Settings, Privacy and Security; an unsigned Windows installer shows **Windows protected your PC** (More info, Run anyway). The download page must say so for the preview.
- Crewbo's hooks also fire when members prompt from the Claude Code and Codex extensions' panels (crewbo `docs/research/m7-agent-extensions.md`), which is why M8-05 bundles or offers them.
- CI: the organisation is on GitHub Free; public repositories run standard runners free, but how long a Code OSS build takes on them is unknown (U-37). Fallback: build Linux in CI and macOS and Windows on Ronel's and gavriel953's machines for the preview.
