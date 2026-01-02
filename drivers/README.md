# Driver Payloads (Auto-downloaded)

⚠️ **Do not commit driver binaries here manually.**

All files under this directory are **automatically downloaded by CI** from the
**Microsoft Update Catalog** during the build process.

## How this works

- GitHub Actions runs `tools/fetch-cabs.ps1`
- Driver CABs are downloaded directly from:
  - `catalog.s.download.windowsupdate.com`
- Every file is **verified with a SHA-256 hash**
- Files are placed into subdirectories under `drivers/` exactly as expected by
  the NSIS installer

The authoritative source for what is downloaded is:

tools/wu-manifest.json

If a file is not listed in the manifest (with a SHA-256 hash), it **must not**
be referenced by the installer.

## Why this exists

- Keeps the repository lightweight (no large binaries committed)
- Ensures reproducible, auditable builds
- Allows anyone to independently verify driver provenance and integrity

## For contributors

- ❌ Do not add CABs or driver binaries to this directory
- ✅ Add new driver payloads by updating `tools/wu-manifest.json`
- ✅ Provide a SHA-256 hash for every new entry
- CI will fail if a referenced file is missing or does not match its hash

If you want to use your own driver payloads, fork the repository and
replace the manifest entries with your own verified sources.