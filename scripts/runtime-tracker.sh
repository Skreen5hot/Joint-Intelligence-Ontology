#!/usr/bin/env bash
# runtime-tracker.sh — track ci-gate.sh wall-clock; W2 warning if > 2× median.
#
# Usage:
#   bash scripts/runtime-tracker.sh RECORD <seconds>   # append to rolling window
#   bash scripts/runtime-tracker.sh CHECK  <seconds>   # exit 1 if > 2× median
#
# State file: tests/baselines/runtime.json — last 10 runs, JSON {"runs":[...]}.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME_FILE="${REPO_ROOT}/tests/baselines/runtime.json"
WINDOW=10
MULTIPLIER=2

mode="${1:-CHECK}"
seconds="${2:-0}"

case "${mode}" in
  RECORD)
    [[ -f "${RUNTIME_FILE}" ]] || echo '{"runs":[]}' > "${RUNTIME_FILE}"
    python3 - "${RUNTIME_FILE}" "${seconds}" "${WINDOW}" <<'PY'
import json, sys
path, sec, window = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
d = json.load(open(path))
d.setdefault("runs", []).append(sec)
d["runs"] = d["runs"][-window:]
json.dump(d, open(path, "w"), indent=2)
PY
    echo "  recorded: ${seconds}s"
    ;;
  CHECK)
    if [[ ! -f "${RUNTIME_FILE}" ]]; then
      echo "  No prior runs — baseline empty, skipping check."
      exit 0
    fi
    python3 - "${RUNTIME_FILE}" "${seconds}" "${MULTIPLIER}" <<'PY'
import json, statistics, sys
path, sec, mult = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
d = json.load(open(path))
runs = d.get("runs", [])
if len(runs) < 3:
    print(f"  Only {len(runs)} prior run(s) — insufficient baseline, skipping.")
    sys.exit(0)
median = statistics.median(runs)
print(f"  current: {sec}s  median(last {len(runs)}): {median}s")
if sec > median * mult:
    print(f"  WARN: current {sec}s > {mult}x median {median}s")
    sys.exit(1)
sys.exit(0)
PY
    ;;
  *)
    echo "Usage: $0 RECORD|CHECK <seconds>" >&2
    exit 64
    ;;
esac
