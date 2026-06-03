# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Gentoo Portage overlay named `devrintalen-overlay` (see `profiles/repo_name`). `metadata/layout.conf` declares `masters = gentoo`, so all eclasses, virtuals, and base packages resolve against the user's main Gentoo tree — only ebuilds in this overlay live here.

## Layout

- `<category>/<pkgname>/<pkgname>-<version>.ebuild` — ebuild per version
- `<category>/<pkgname>/Manifest` — DIST/EBUILD/AUX hashes (regenerate with `ebuild <ebuild> manifest`)
- `<category>/<pkgname>/files/` — patches passed via `${FILESDIR}` / `PATCHES=()`
- `<category>/<pkgname>/licenses/` — package-local license texts for non-standard licenses (e.g. `lattice`, `rew`); the `LICENSE=` value must match a filename here or in the main tree
- `.gitignore` excludes `*~` (Emacs/undo-tree backups). Many `*.ebuild~` and `*.~undo-tree~` files are present in working copies — leave them alone, do not commit them.

## Common operations

These commands assume the overlay is registered in `/etc/portage/repos.conf/` on the dev machine.

```bash
# Regenerate Manifest after changing SRC_URI or adding files/ patches
ebuild <category>/<pkg>/<pkg>-<ver>.ebuild manifest

# Local sanity check
pkgcheck scan <category>/<pkg>
repoman full           # if invoked from a package dir

# Test a build end-to-end
emerge -av =<category>/<pkg>-<ver>::devrintalen-overlay
```

For `RESTRICT="fetch"` packages (most of the embedded IDEs), Portage will refuse to download — the installer must be placed in `${DISTDIR}` (typically `/var/cache/distfiles`) by hand before emerging. The `pkg_nofetch` function prints the expected filename and homepage.

## Conventions specific to this overlay

**Most packages here are repackaged proprietary vendor installers, not source builds.** This drives several patterns that look unusual versus typical Gentoo ebuilds:

- `RESTRICT="fetch strip"` is standard for vendor IDEs — `fetch` because licensing forbids redistribution, `strip` because vendor binaries often break when stripped. Keep both when adding a new vendor package.
- Installation target is `/opt/<vendor-or-tool>/` rather than `/usr` — vendor toolchains expect their own self-contained tree (Eclipse plugins, bundled JREs, signed binaries with hardcoded paths).
- Bundled JREs and toolchain binaries lose their executable bit when unpacked from `.deb`/`.rpm`/`.sh` archives. The pattern in `dev-embedded/mcuxpressoide/` is an explicit `fperms +x` per binary — when bumping versions, regenerate that list with `find ${D}/opt/<pkg> -exec file {} \; | grep "ELF.*executable"`.
- Unpack helpers vary by vendor format: `inherit unpacker` + `unpack_deb` (NXP `.deb.bin`), `inherit rpm` + `rpm_src_unpack` (Lattice `.rpm`), `unpack_zip` (ST `.sh.zip`), or running the installer's own self-extractor with `--noexec --keep --target` (NXP, ST). New vendor formats usually need their own `src_unpack`.
- IDE packages also `inherit desktop xdg-utils udev` and call `make_desktop_entry` + `udev_reload` from `pkg_postinst`/`pkg_postrm` so the GUI shows up and JLink/etc. USB rules take effect.
- Patches under `files/` for vendor installers typically rewrite the installer's own preflight checks (license prompts, MD5 self-checks) — see `dev-embedded/stm32cubeide/files/00{1,2,3}-*.diff`. They are wrapper-script patches, not source patches.

The non-vendor packages (`gui-apps/wprintidle-c`, `sci-visualization/gr`) are normal source builds and follow upstream Gentoo style — no special handling.

## Version bumps

Typical workflow when a new vendor release drops:

1. Copy the previous `<pkg>-<oldver>.ebuild` to `<pkg>-<newver>.ebuild`.
2. Update `SRC_URI` to the new installer filename and any version-bearing paths in `src_unpack`/`src_install` (these often include build dates and timestamps, e.g. `com.nxp.mcuxpresso.tools.linux_11.8.1.202308071233`).
3. Drop the new installer into `${DISTDIR}` and run `ebuild ... manifest`.
4. Test with `emerge`. Vendor installers frequently change internal paths between minor versions — expect to update `fperms` lists and any patches under `files/`.

## Things to leave alone

- The boilerplate skeleton comments in `dev-embedded/{stm32cubeide,embedded-studio,mcuxpressoide}/*.ebuild` (long block comments inherited from the Gentoo ebuild template) are intentionally preserved as in-place documentation — don't strip them as part of unrelated changes.
- The `~` suffixed backup files are working-copy artifacts, not part of the repo.
