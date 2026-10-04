#!/usr/bin/env bash
# Builds the Flutter web app on Netlify.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_ROOT="$ROOT/flutter"
VERSION_FILE="$FLUTTER_ROOT/bin/cache/flutter.version.json"

# Fetch the Flutter SDK unless a usable copy is already present (e.g. from cache).
if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  rm -rf "$FLUTTER_ROOT"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_ROOT"
fi

export PATH="$PATH:$FLUTTER_ROOT/bin"

# Flutter detects its own version with `git -c ...`. In environments where git is
# restricted, that fails and the SDK reports "0.0.0-unknown", breaking pub's
# SDK constraint checks. Rebuild the version cache from read-only git commands.
flutter --version >/dev/null 2>&1 || true
sdk_git() { (cd "$FLUTTER_ROOT" && git "$@"); }
if [ -f "$VERSION_FILE" ] && grep -q '"frameworkVersion": "0.0.0-unknown"' "$VERSION_FILE"; then
  describe="$(sdk_git describe --tags --long --match '*.*.*' HEAD 2>/dev/null || true)"
  if [[ "$describe" =~ ^(.+)-0-g[0-9a-f]+$ ]]; then
    FRAMEWORK_VERSION="${BASH_REMATCH[1]}" \
    CHANNEL="$(sdk_git rev-parse --abbrev-ref HEAD)" \
    REVISION="$(sdk_git rev-parse HEAD)" \
    COMMIT_DATE="$(sdk_git log -n 1 --pretty=format:%ad --date=iso)" \
    node -e '
      const fs = require("fs");
      const file = process.argv[1];
      const v = JSON.parse(fs.readFileSync(file, "utf8"));
      Object.assign(v, {
        frameworkVersion: process.env.FRAMEWORK_VERSION,
        flutterVersion: process.env.FRAMEWORK_VERSION,
        channel: process.env.CHANNEL,
        repositoryUrl: "https://github.com/flutter/flutter.git",
        frameworkRevision: process.env.REVISION,
        frameworkCommitDate: process.env.COMMIT_DATE,
      });
      fs.writeFileSync(file, JSON.stringify(v, null, 2));
    ' "$VERSION_FILE"
  fi
fi

cd "$ROOT"
flutter build web --release
