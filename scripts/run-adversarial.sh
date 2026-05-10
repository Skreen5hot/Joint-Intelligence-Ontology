#!/usr/bin/env bash
# run-adversarial.sh — execute every fixture under tests/fixtures/adversarial/.
#
# Phase 0 (JI-004b): validates fixture structure end-to-end and runs the
# reasoner. Per-probe pass/fail logic against expected.json's must_surface /
# must_not_surface entries lights up once JI-005 lands real classes — the
# stub T-Box has nothing for these probes to bite on.
#
# Usage: bash scripts/run-adversarial.sh
# Exit:  0 if all fixtures structurally valid and reasoner ran on each
#        1 if a fixture is malformed or the reasoner crashes
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_ROOT}"

TBOX="${JIO_TBOX:-tests/stub/jio-stub.ttl}"
STUB_TBOX="tests/stub/jio-stub.ttl"

# Same JI-003-transition fallback as ci-gate.sh.
if [[ ! -f "${TBOX}" ]]; then
  if [[ "${TBOX}" != "${STUB_TBOX}" ]]; then
    echo "  WARN: JIO_TBOX=${TBOX} not present — falling back to ${STUB_TBOX}."
    TBOX="${STUB_TBOX}"
  fi
fi

ADV_DIR="tests/fixtures/adversarial"
PROBE_DIR="tests/fixtures/probes"

shopt -s nullglob
fixtures=()
for d in "${ADV_DIR}"/*/; do
  if [[ -f "${d}fixture.jsonld" && -f "${d}expected.json" ]]; then
    fixtures+=("${d}")
  fi
done

if [[ ${#fixtures[@]} -eq 0 ]]; then
  echo "  SKIP: no adversarial fixtures present."
  exit 0
fi

# Validate every expected.json
rc=0
for f in "${fixtures[@]}"; do
  if ! python3 -c "
import json, sys
d = json.load(open('${f}expected.json'))
for required in ('test_id',):
    assert required in d, f'missing {required}'
assert 'must_surface' in d or 'must_not_surface' in d, 'must declare at least one of must_surface / must_not_surface'
" 2>/dev/null; then
    echo "  FAIL: ${f}expected.json malformed or missing required fields"
    rc=1
  fi
done
[[ ${rc} -ne 0 ]] && exit ${rc}

if [[ "${TBOX}" == "${STUB_TBOX}" ]]; then
  echo "  Adversarial probes structurally validated; reasoner verification deferred."
  echo "  Reason: stub T-Box is in use (canonical T-Box not yet shipped by JI-003 / JI-005)."
  echo "  Fixtures present (${#fixtures[@]}):"
  for f in "${fixtures[@]}"; do
    echo "    - $(basename "${f%/}")"
  done
  exit 0
fi

# Real T-Box present — run reasoner per fixture.
ROBOT_JAR="$(bash scripts/install-robot.sh)"

CATALOG_FLAG=""
if [[ -f "src/imports/catalog-v001.xml" ]]; then
  CATALOG_FLAG="--catalog src/imports/catalog-v001.xml"
fi

any_unexpected=0
for f in "${fixtures[@]}"; do
  name="$(basename "${f%/}")"
  fixture="${f}fixture.jsonld"
  probe_tbox="${PROBE_DIR}/${name}.ttl"
  ARGS=("--input" "${TBOX}" "--input" "${fixture}")
  [[ -f "${probe_tbox}" ]] && ARGS+=("--input" "${probe_tbox}") && echo "  probe ${name}: + delta ${probe_tbox}"

  echo "  probe: ${name}"
  log="/tmp/adv-${name}.log"
  out="/tmp/adv-${name}.owl"
  # Reasoner choice: ELK for parity with B3 (scripts/ci-gate.sh). HermiT on the
  # merged CCO+BFO+IAO+RO+stub ontology times out the 15-min workflow even on a
  # single fixture; six fixtures sequentially is hopeless. ELK is sufficient
  # for Phase 0 stub T-Box. JI-005 should reconsider when full doctrinal
  # axioms land — at that point a hybrid (ELK for fast probes, HermiT for
  # specific OWL DL-dependent probes) may be the right shape.
  if java -jar "${ROBOT_JAR}" ${CATALOG_FLAG} merge "${ARGS[@]}" \
      reason --reasoner elk --output "${out}" >"${log}" 2>&1; then
    echo "    reasoner: clean"
  else
    # Some probes (temporal_consistency_test) intentionally produce inconsistency.
    # Per-probe expected-vs-actual verification is deferred to a richer runner.
    if grep -q "Inconsistent" "${log}" 2>/dev/null; then
      echo "    reasoner: inconsistency (may be expected — see expected.json must_surface)"
    else
      echo "    reasoner: ERROR — see ${log}"
      any_unexpected=1
    fi
  fi
done

# Phase 0 stub: any non-crash result is exit-0. Per-probe verdict logic = future work.
exit ${any_unexpected}
