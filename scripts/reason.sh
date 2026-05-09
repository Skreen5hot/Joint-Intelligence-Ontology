#!/usr/bin/env bash
# reason.sh — single-shot reasoner invocation.
# Usage:
#   bash scripts/reason.sh --tbox PATH [--abox PATH] [--probe PATH] [--out PATH]
#
# Runs ROBOT reason (HermiT) on the merged graph and prints unsatisfiable named
# classes. Exits non-zero on inconsistency or unsat. Used by ci-gate.sh and by
# Onto/SME for ad-hoc checks.
set -euo pipefail

TBOX=""
ABOX=""
PROBE=""
OUT=""
REASONER="${REASONER:-hermit}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tbox) TBOX="$2"; shift 2 ;;
    --abox) ABOX="$2"; shift 2 ;;
    --probe) PROBE="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 64 ;;
  esac
done

if [[ -z "${TBOX}" ]]; then
  echo "Required: --tbox PATH" >&2
  exit 64
fi

ROBOT_JAR="$(bash "$(dirname "$0")/install-robot.sh")"
ROBOT_RUN=(java -jar "${ROBOT_JAR}")

# Build the merge invocation.
INPUTS=("--input" "${TBOX}")
[[ -n "${ABOX}" ]] && INPUTS+=("--input" "${ABOX}")
[[ -n "${PROBE}" ]] && INPUTS+=("--input" "${PROBE}")

CATALOG=""
if [[ -f "src/imports/catalog-v001.xml" ]]; then
  CATALOG="--catalog src/imports/catalog-v001.xml"
fi

OUT_PATH="${OUT:-$(mktemp -t reasoned-XXXXXX.owl)}"

echo "[reason.sh] merging $((${#INPUTS[@]} / 2)) input(s); reasoner=${REASONER}"
"${ROBOT_RUN[@]}" ${CATALOG} \
  merge "${INPUTS[@]}" \
  reason --reasoner "${REASONER}" \
  --output "${OUT_PATH}"

echo "[reason.sh] reasoned model written: ${OUT_PATH}"
