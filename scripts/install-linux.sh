#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ "$(uname -s)" != "Linux" ]]; then
	echo "This installer is only for Linux." >&2
	exit 1
fi

bun_version="$(<.bun-version)"

verify_bun_version() {
	local installed_version
	installed_version="$(bun --version)"

	if [[ "$installed_version" != "$bun_version" ]]; then
		echo "Bun $bun_version is required, but Bun $installed_version is installed." >&2
		return 1
	fi
}

if command -v bun >/dev/null 2>&1; then
	verify_bun_version
	echo "Installing dependencies with Bun..."
	bun install --frozen
	exit 0
fi

if command -v npm >/dev/null 2>&1; then
	echo "Bun was not found; installing it with npm..."
	npm install --global "bun@$bun_version" --no-audit --no-fund
	if ! command -v bun >/dev/null 2>&1; then
		echo "npm installed Bun, but the Bun executable is not on PATH." >&2
		exit 1
	fi
	verify_bun_version
	echo "Installing dependencies with Bun..."
	bun install --frozen
	exit 0
fi

cat >&2 <<'EOF'
Neither Bun nor npm was found.
Install Bun from https://bun.sh/docs/installation and run this script again,
or install Node.js (which includes npm) and run this script again.
EOF
exit 1
